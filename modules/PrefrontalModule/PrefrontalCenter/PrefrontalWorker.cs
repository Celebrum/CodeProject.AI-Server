using CodeProject.AI.SDK;
using System.Threading.Tasks;

namespace PrefrontalCenter
{
    public class PrefrontalWorker : ModuleWorkerBase
    {
        private readonly DecisionEngine _decisionEngine;
        private readonly MemoryFormation _memoryFormation;

        public PrefrontalWorker(ILogger<PrefrontalWorker> logger,
                               DecisionEngine decisionEngine,
                               MemoryFormation memoryFormation,
                               IConfiguration configuration)
            : base(logger, configuration)
        {
            _decisionEngine = decisionEngine;
            _memoryFormation = memoryFormation;
        }

        public override BackendResponseBase ProcessRequest(BackendRequest request)
        {
            var context = request.payload.GetValue("context");
            var emotionalInput = request.payload.GetValue("emotional_input");
            var options = request.payload.GetArray("options");

            var executiveDecision = _decisionEngine.ProcessDecision(
                context, 
                options, 
                emotionalInput
            );

            _memoryFormation.StoreDecisionContext(executiveDecision);

            return new PrefrontalResponse
            {
                selected_action = executiveDecision.SelectedAction,
                confidence_score = executiveDecision.Confidence,
                risk_assessment = executiveDecision.RiskAssessment,
                emotional_regulation = executiveDecision.EmotionalRegulation,
                processMs = sw.ElapsedMilliseconds
            };
        }
    }
}
