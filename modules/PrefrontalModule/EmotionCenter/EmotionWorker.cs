using CodeProject.AI.SDK;
using System.Threading.Tasks;

namespace EmotionCenter
{
    public class EmotionWorker : ModuleWorkerBase
    {
        private readonly EmotionalProcessor _emotionalProcessor;
        private readonly EmotionalMemory _emotionalMemory;

        public EmotionWorker(ILogger<EmotionWorker> logger, 
                            EmotionalProcessor emotionalProcessor,
                            EmotionalMemory emotionalMemory,
                            IConfiguration configuration)
            : base(logger, configuration)
        {
            _emotionalProcessor = emotionalProcessor;
            _emotionalMemory = emotionalMemory;
        }

        public override BackendResponseBase ProcessRequest(BackendRequest request)
        {
            var context = request.payload.GetValue("context");
            var inputText = request.payload.GetValue("input");

            var emotionalResponse = _emotionalProcessor.ProcessEmotion(inputText, context);
            _emotionalMemory.StoreEmotionalContext(emotionalResponse);

            return new EmotionalResponse
            {
                primary_emotion = emotionalResponse.PrimaryEmotion,
                intensity = emotionalResponse.Intensity,
                empathy_response = emotionalResponse.EmpathyResponse,
                context_impact = emotionalResponse.ContextImpact,
                processMs = sw.ElapsedMilliseconds
            };
        }
    }
}
