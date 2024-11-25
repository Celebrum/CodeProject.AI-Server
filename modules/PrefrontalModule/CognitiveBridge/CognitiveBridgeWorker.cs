using CodeProject.AI.SDK;

namespace CognitiveBridge
{
    public class CognitiveBridgeWorker : ModuleWorkerBase
    {
        private readonly EmotionWorker _emotionWorker;
        private readonly PrefrontalWorker _prefrontalWorker;

        public override BackendResponseBase ProcessRequest(BackendRequest request)
        {
            var emotionalResponse = _emotionWorker.ProcessRequest(request);
            
            // Enrich request with emotional data
            request.payload.Add("emotional_input", emotionalResponse);
            
            var executiveResponse = _prefrontalWorker.ProcessRequest(request);

            return new CognitiveResponse
            {
                emotional_response = emotionalResponse,
                executive_decision = executiveResponse,
                integrated_response = CombineResponses(
                    emotionalResponse, 
                    executiveResponse
                ),
                processMs = sw.ElapsedMilliseconds
            };
        }
    }
}
