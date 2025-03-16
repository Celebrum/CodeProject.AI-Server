import platform
import time
import sys

from PIL import Image

accel_mode = None
if sys.platform == 'darwin':
    if "ARM64" in platform.uname().version:
        accel_mode = 'MLX'
else:
    accel_mode = 'ONNX'


if accel_mode == 'ONNX':
    import onnxruntime_genai as og
elif accel_mode == 'MLX':
    from phi_3_vision_mlx import generate, load
else:
    from transformers import AutoModelForCausalLM, AutoProcessor, AutoConfig

user_prompt_marker      = '<|user|>\n'
image_marker            = '<|image_1|>\n'
assistant_prompt_marker = '<|assistant|>\n'
prompt_suffix           = "<|end|>\n"


class MultiModeLLM:

    def __init__(self, model_repo: str, filename: str, model_dir: str, 
                 device: str, inference_library: str = None,
                 verbose: bool = True) -> None:

        self.device     = device
        self.model      = None
        self.processor  = None
        self.model_path = None

        try:
            if accel_mode == 'ONNX':        # Non macOS
                
                # For ONNX, we download the models at install time
                self.device           = device
                self.model_path       = model_dir
                self.model            = og.Model(self.model_path)
                self.processor        = self.model.create_multimodal_processor()
                self.tokenizer_stream = self.processor.create_stream()

            elif accel_mode == 'MLX':       # macOS, Apple Silicon.

                # Hardcoded in MLX code
                # repo = "microsoft/Phi-3-vision-128k-instruct"

                self.device                = device
                self.model_path            = model_dir
                self.model, self.processor = load(model_path=model_dir, adapter_path=None)

            else:                           # macOS, Numpy, not MLX
                # For macOS (intel), we don't download at install time (yet). We download at runtime
                # TBD: Download model in installer, load the model here. If download 
                #      and load fail, fall through to download-at-runtime
                raise

        except Exception as ex:
            # A general fall-through for the case where ONNX or MLX model loading failed, or where
            # we only have non-GPU accelerated libraries (macOS on Intel) to use.

            if accel_mode == 'ONNX' or accel_mode == 'MLX':
                # We tried, but failed, and we won't fallback to CPU here (Could but won't).
                self.model      = None
                self.processor  = None
                self.model_path = None
            else:
                # For macOS we only download the model at runtime (for now - this will change)
                try:

                    # https://huggingface.co/microsoft/Phi-3.5-vision-instruct

                    # This will download the model from the repo and cache it locally
                    # Handy if we didn't download during install
                    attn_implementation = "eager" if device == "cpu" else "sdpa" # eager = manual

                    # use_flash_attention_2 = False if device == "cpu" else True
                    use_flash_attention_2 = False # Only on Windows, only on CUDA

                    config = AutoConfig.from_pretrained(model_repo, trust_remote_code=True)
                    # config.gguf_file = ...
                    config.attn_implementation   = attn_implementation
                    config.device_map            = device
                    config.torch_dtype           = 'auto'
                    # config.temperature         = 0.1 - needs do_sample=True
                    config.trust_remote_code     = True
                    config.use_flash_attention_2 = use_flash_attention_2
                    
                    self.model = AutoModelForCausalLM.from_pretrained(model_repo, 
                                                                      attn_implementation=attn_implementation,
                                                                      config=config,
                                                                      trust_remote_code=True)
                    self.processor = AutoProcessor.from_pretrained(model_repo, trust_remote_code=True) 

                    self.model_path = self.model.name_or_path

                except Exception as ex_2:
                    self.model      = None
                    self.processor  = None
                    self.model_path = None

        # get the relative path to the model file from the model itself
        # self.model_path = os.path.relpath(self.llm.model_path)


    def do_chat(self, user_prompt: str, image: Image, system_prompt: str=None,
                max_tokens: int = 1024, temperature: float = 0.4,
                stream: bool = True) -> any:
        """ 
        Generates a response from a chat / conversation prompt
        params:
            prompt:str	                    The prompt to generate text from.
            system_prompt: str=None         The description of the assistant
            max_tokens: int = 128           The maximum number of tokens to generate.
            temperature: float = 0.8        The temperature to use for sampling.
        """

        start_process_time = time.perf_counter()
        stop_reason = None

        if not system_prompt:
            system_prompt = "You're a helpful assistant who answers questions the user asks of you concisely and accurately."

        if image:
            prompt = f"{user_prompt_marker}{image_marker}\n{user_prompt}{prompt_suffix}{assistant_prompt_marker}"
        else:
            prompt = f"{user_prompt_marker}\n{user_prompt}{prompt_suffix}{assistant_prompt_marker}"
            
        inferenceMs = 0
        try:
            if accel_mode == 'ONNX':
                
                # ONNX genai API doesn't (yet) provide the means to load an image
                # from memory https://github.com/microsoft/onnxruntime-genai/issues/777
                if image:
                    import os
                    temp_name="onnx_genai_temp_image.png"
                    image.save(temp_name, icc_profile=None)
                    og_image = og.Images.open(temp_name)
                    os.remove(temp_name)
                else:
                    og_image = None

                inputs = self.processor(prompt, images=og_image)

                params = og.GeneratorParams(self.model)
                params.set_inputs(inputs)
                params.set_search_options(max_length=3072)

                response = ""

                generator = og.Generator(self.model, params)

                # If we're streaming then short circuit here and just return the
                # generator. NOTE: the caller will need to del the generator
                if stream:
                    return (generator, self.tokenizer_stream, {
                        "success": True, 
                        "reply": response,
                        "stop_reason": "None",
                        "processMs" : int((time.perf_counter() - start_process_time) * 1000),
                        "inferenceMs" : 0
                    })
                
                while not generator.is_done():
                    generator.compute_logits()
                    generator.generate_next_token()

                    new_token    = generator.get_next_tokens()[0]
                    new_response = self.tokenizer_stream.decode(new_token)
                    response += new_response

                inferenceMs = int((time.perf_counter() - start_inference_time) * 1000)

                del generator

            elif accel_mode == 'MLX':
               
                start_inference_time = time.perf_counter()

                # Using phi_3_vision_mlx v0.0.2
                # https://github.com/JosefAlbers/Phi-3-Vision-MLX/tree/v0.0.2-beta
                response = generate(self.model, self.processor, prompt, [image])

                # Using latest phi_3_vision_mlx
                # agent = Agent()
                # response = agent(prompt, images=[image])
                # agent.end()

                inferenceMs = int((time.perf_counter() - start_inference_time) * 1000)

            else:           
                inputs = self.processor(prompt, image, return_tensors="pt").to(self.device)

                start_inference_time = time.perf_counter()
                generate_ids = self.model.generate(**inputs, max_new_tokens=max_tokens,
                                                eos_token_id=self.processor.tokenizer.eos_token_id,) # note trailing ","
                inferenceMs = int((time.perf_counter() - start_inference_time) * 1000)

                generate_ids = generate_ids[:, inputs['input_ids'].shape[1]:]
                response = self.processor.batch_decode(generate_ids, skip_special_tokens=True, 
                                                       clean_up_tokenization_spaces=False)[0]
    
        except Exception as ex:
            if accel_mode == 'ONNX':
                return (None, None, {
                    "success": False, 
                    "error": str(ex),
                    "stop_reason": "Exception",
                    "processMs": int((time.perf_counter() - start_process_time) * 1000),
                    "inferenceMs": 0
                })
            
            return {
                "success": False, 
                "error": str(ex),
                "stop_reason": "Exception",
                "processMs": int((time.perf_counter() - start_process_time) * 1000),
                "inferenceMs": 0
            }

        if not accel_mode == 'ONNX' and self.device == "cuda":
            try:
                import torch
                torch.cuda.empty_cache()
            except:
                pass

        if stop_reason is None:
            stop_reason = "completed"

        return {
            "success": True, 
            "reply": response,
            "stop_reason": stop_reason,
            "processMs" : int((time.perf_counter() - start_process_time) * 1000),
            "inferenceMs" : inferenceMs
        }
