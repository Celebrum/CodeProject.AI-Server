#!/usr/bin/env python
# coding: utf-8

# Import our general libraries
import os
import time

# SEE https://github.com/microsoft/onnxruntime-genai/blob/main/examples/python/phi3v.py 
#    for CPU / ONNX code

from PIL import Image

# Import CodeProject.AI SDK
from codeproject_ai_sdk import RequestData, ModuleRunner, ModuleOptions, LogMethod, LogVerbosity, JSON

from multimode_llm import MultiModeLLM, accel_mode

class MultiModeLLM_adapter(ModuleRunner):

    def initialise(self) -> None:

        if accel_mode == 'ONNX':
            (cuda_major, cuda_minor) = self.system_info.getCudaVersion
            if cuda_major and (cuda_major >= 12 or (cuda_major == 11 and cuda_minor == 8)) :
                self.inference_device  = "GPU"
                self.inference_library = "ONNX/CUDA"
                self.device            = "cuda"
                self.model_repo        = "microsoft/Phi-3-vision-128k-instruct-onnx-cuda"
                self.model_filename    = None # "Phi-3-vision-128k-instruct.gguf"
                self.models_dir        = "cuda-int4-rtn-block-32"
            else:
                print("*** Multi-modal LLM using CPU only: This module requires > 16Gb RAM")
                self.inference_device  = "CPU"
                self.device            = "cpu"
                self.inference_library = "ONNX/DML" if self.system_info.os == "Windows" else "ONNX"
                self.model_repo        = "microsoft/Phi-3-vision-128k-instruct-onnx-cpu"
                self.model_filename    = None # "Phi-3-vision-128k-instruct.gguf"
                self.models_dir        = "cpu-int4-rtn-block-32-acc-level-4"

        elif accel_mode == 'MLX':           # macOS
            self.inference_device  = "GPU"
            self.inference_library = "MLX"
            self.device            = "mps"
            self.model_repo        = "microsoft/Phi-3.5-vision-instruct"
            self.model_filename    = None # "Phi-3.5-vision-instruct.gguf"
            self.models_dir        = "models"

        else:
            print("*** Multi-modal LLM using CPU only: This module requires > 16Gb RAM")
            # If only...
            # if self.system_info.cpu_vendor == 'Apple' and self.system_info.cpu_arch == 'arm64':
            #     self.inference_device  = "GPU"
            #     self.inference_library = "Metal"
            #     self.device            = "mps"
            self.inference_device = "CPU"
            self.device           = "cpu"
            self.model_repo       = "microsoft/Phi-3-vision-128k-instruct"
            self.model_filename    = None # "Phi-3-vision-128k-instruct.gguf"
            self.models_dir       = "./models"


        if False and self._performing_self_test and self.device == "cpu":
            self.log(LogMethod.Error|LogMethod.Server, {
                "message": f"Unable to perform self-text without acceleration",
                "loglevel": "error"
            })
        else:        
            verbose = self.log_verbosity != LogVerbosity.Quiet
            self.multimode_chat = MultiModeLLM(model_repo=self.model_repo,
                                               filename=self.model_filename,
                                               model_dir=os.path.join(ModuleOptions.module_path,self.models_dir),
                                               device=self.device, 
                                               inference_library=self.inference_library,
                                               verbose=verbose)
            
            if self.multimode_chat.model_path:
                self.log(LogMethod.Info|LogMethod.Server, {
                    "message": f"Using model from '{self.multimode_chat.model_path}'",
                    "loglevel": "information"
                })
            else:
                self.log(LogMethod.Error|LogMethod.Server, {
                    "message": f"Unable to load Multi-mode model",
                    "loglevel": "error"
                })

        self.reply_text  = ""
        self.cancelled   = False


    def process(self, data: RequestData) -> JSON:
        return self.long_process


    def long_process(self, data: RequestData) -> JSON:

        self.reply_text = ""
        stop_reason = None

        user_prompt: str   = data.get_value("prompt")
        system_prompt: str = data.get_value("system_prompt")
        image: Image       = data.get_image(0)
        max_tokens: int    = data.get_int("max_tokens", 0) #0 means model default
        temperature: float = data.get_float("temperature", 0.4)

        # If a PDF is passed in:
        # import pymupdf
        # file_bytes = data.get_file_bytes(0)
        # doc = pymupdf.Document(stream=file_bytes)
        # for page in doc:  # iterate through the pages
        #    pix = page.get_pixmap()  # render page to an image
        #    pix.save("page-%i.png" % page.number)  # store image as a PNG
        #    # To scale 2X:
        #    # zoom_x = 2.0  # horizontal zoom
        #    # zoom_y = 2.0  # vertical zoom
        #    # mat = pymupdf.Matrix(zoom_x, zoom_y)  # zoom factor 2 in each dimension
        #    # pix = page.get_pixmap(matrix=mat)  # use 'mat' instead of the identity matrix

        start_process_time = time.perf_counter()
        start_inference_time = time.perf_counter()

        error = None

        try:
            if accel_mode == 'ONNX':
                (generator,
                 tokenizer_stream,
                  response)        = self.multimode_chat.do_chat(user_prompt, image,
                                                                 system_prompt,
                                                                 max_tokens=max_tokens,
                                                                temperature=temperature,
                                                                stream=True)
                if generator:
                    while not generator.is_done():
                        if self.cancelled:
                            self.cancelled = False
                            stop_reason = "cancelled"
                            break

                        generator.compute_logits()
                        generator.generate_next_token()

                        next_tokens   = generator.get_next_tokens()
                        next_token    = next_tokens[0]
                        next_response = tokenizer_stream.decode(next_token)

                        self.reply_text += next_response
                    
                inferenceMs : int = int((time.perf_counter() - start_inference_time) * 1000)

                if generator:                   
                    del generator

            else:
                llm_response = self.multimode_chat.do_chat(user_prompt, image, system_prompt,
                                                           max_tokens=max_tokens,
                                                           temperature=temperature,
                                                           stream=False)
                if llm_response["success"]:
                    inferenceMs     = llm_response["inferenceMs"]
                    self.reply_text = llm_response["reply"]
                else:
                    error       = llm_response["error"] if "error" in llm_response["error"] else "Error generating reply"
                    inferenceMs = 0

            if stop_reason == "cancelled" and not self.reply_text and not error:
                error = "Operation cancelled"
                
            if stop_reason is None:
                stop_reason = "completed"

            if error:
                response = {
                    "success": False, 
                    "error": error,
                    "reply": "",
                    "stop_reason": stop_reason,
                    "processMs": int((time.perf_counter() - start_process_time) * 1000),
                }
            else:
                response = {
                    "success": True, 
                    "reply": self.reply_text,
                    "stop_reason": stop_reason,
                    "processMs": int((time.perf_counter() - start_process_time) * 1000),
                    "inferenceMs" : inferenceMs
                }

        except Exception as ex:
            self.report_error(ex, __file__)
            response = { "success": False, "error": f"Unable to generate text ({ex})" }

        return response
    

    def command_status(self) -> JSON:
        return {
            "success": True, 
            "reply":   self.reply_text
        }


    def cancel_command_task(self):
        self.cancelled      = True   # We will cancel this long process ourselves
        self.force_shutdown = False  # Tell ModuleRunner not to go ballistic


    def selftest(self) -> JSON:

        if accel_mode == None:
            return { "success": False, "message": "Not performing self-test on CPU due to time taken" }
        
        request_data = RequestData()
        request_data.queue   = self.queue_name
        request_data.command = "prompt"

        # file_name = os.path.join("test", "home-office.jpg")
        # request_data.add_file(file_name)
        # request_data.add_value("prompt", "What is shown in this image?")

        request_data.add_value("prompt", "Please tell me a joke")

        request_data.add_value("max_tokens", 1024)
        request_data.add_value("temperature", 0.2)

        # result = self.process(request_data)
        result = self.long_process(request_data)

        print(f"Info: Self-test for {self.module_id}. Success: {result['success']}")
        # print(f"Info: Self-test output for {self.module_id}: {result}")

        return { "success": result['success'], "message": "MultiModal LLM test successful" }


if __name__ == "__main__":
    MultiModeLLM_adapter().start_loop()
