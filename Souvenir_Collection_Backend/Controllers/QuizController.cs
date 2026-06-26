using Microsoft.AspNetCore.Mvc;
using Sovenire_Collenction_Backend.Helpers;

namespace Sovenire_Collenction_Backend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class QuizController : ControllerBase
    {
        private readonly QuizService _quizService;

        public QuizController(QuizService quizService)
        {
            _quizService = quizService;
        }

        // GET api/quiz
        [HttpGet]
        public async Task<IActionResult> GetAllQuestions()
        {
            var questions = await _quizService.GetAllQuestionsAsync() ?? new List<QuizQuestion>();
            var message = questions.Any() ? "Quiz questions retrieved successfully." : "No quiz questions found.";
            return Ok(ApiResponse<List<QuizQuestion>>.SuccessResult(questions, message));
        }

        // GET api/quiz/{id}
        [HttpGet("{id}")]
        public async Task<IActionResult> GetQuestionById(Guid id)
        {
            var question = await _quizService.GetQuestionByIdAsync(id);
            if (question == null)
                return NotFound(ApiResponse<QuizQuestion>.FailureResult($"Quiz question with ID {id} not found."));

            return Ok(ApiResponse<QuizQuestion>.SuccessResult(question, "Quiz question details retrieved successfully."));
        }

        // POST api/quiz
        [HttpPost]
        public async Task<IActionResult> CreateQuestion([FromBody] QuizQuestion question)
        {
            if (!ModelState.IsValid)
                return BadRequest(ApiResponse<QuizQuestion>.FailureResult("Invalid question payload."));

            var created = await _quizService.CreateQuestionAsync(question);
            return CreatedAtAction(nameof(GetQuestionById), new { id = created.Id }, ApiResponse<QuizQuestion>.SuccessResult(created, "Quiz question created successfully."));
        }

        // PUT/PATCH api/quiz/{id}
        [HttpPut("{id}")]
        [HttpPatch("{id}")]
        public async Task<IActionResult> UpdateQuestion(Guid id, [FromBody] QuizQuestion updated)
        {
            if (!ModelState.IsValid)
                return BadRequest(ApiResponse<QuizQuestion>.FailureResult("Invalid question payload."));

            var question = await _quizService.UpdateQuestionAsync(id, updated);
            if (question == null)
                return NotFound(ApiResponse<QuizQuestion>.FailureResult($"Quiz question with ID {id} not found or update failed."));

            return Ok(ApiResponse<QuizQuestion>.SuccessResult(question, "Quiz question updated successfully."));
        }

        // DELETE api/quiz/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteQuestion(Guid id)
        {
            var success = await _quizService.DeleteQuestionAsync(id);
            if (!success)
                return NotFound(ApiResponse<object>.FailureResult($"Quiz question with ID {id} not found or delete failed."));

            return Ok(ApiResponse<object>.SuccessResult(new { id = id }, "Quiz question deleted successfully."));
        }

        // GET api/quiz/{questionId}/answer
        [HttpGet("{questionId}/answer")]
        public async Task<IActionResult> GetAnswersByQuestion(Guid questionId)
        {
            var answers = await _quizService.GetAnswersByQuestionIdAsync(questionId) ?? new List<QuizAnswer>();
            var message = answers.Any() ? "Answers retrieved successfully." : $"No answers found for Question ID {questionId}.";
            return Ok(ApiResponse<List<QuizAnswer>>.SuccessResult(answers, message));
        }

        // GET api/quiz/answer/{id}
        [HttpGet("answer/{id}")]
        public async Task<IActionResult> GetAnswerById(Guid id)
        {
            var answer = await _quizService.GetAnswerByIdAsync(id);
            if (answer == null)
                return NotFound(ApiResponse<QuizAnswer>.FailureResult($"Quiz answer with ID {id} not found."));

            return Ok(ApiResponse<QuizAnswer>.SuccessResult(answer, "Quiz answer retrieved successfully."));
        }

        // POST api/quiz/answer
        [HttpPost("answer")]
        public async Task<IActionResult> CreateAnswer([FromBody] QuizAnswer answer)
        {
            if (!ModelState.IsValid)
                return BadRequest(ApiResponse<QuizAnswer>.FailureResult("Invalid answer payload."));

            var created = await _quizService.CreateAnswerAsync(answer);
            return Ok(ApiResponse<QuizAnswer>.SuccessResult(created, "Quiz answer created successfully."));
        }

        // PUT/PATCH api/quiz/answer/{id}
        [HttpPut("answer/{id}")]
        [HttpPatch("answer/{id}")]
        public async Task<IActionResult> UpdateAnswer(Guid id, [FromBody] QuizAnswer updated)
        {
            if (!ModelState.IsValid)
                return BadRequest(ApiResponse<QuizAnswer>.FailureResult("Invalid answer payload."));

            var answer = await _quizService.UpdateAnswerAsync(id, updated);
            if (answer == null)
                return NotFound(ApiResponse<QuizAnswer>.FailureResult($"Quiz answer with ID {id} not found or update failed."));

            return Ok(ApiResponse<QuizAnswer>.SuccessResult(answer, "Quiz answer updated successfully."));
        }

        // DELETE api/quiz/answer/{id}
        [HttpDelete("answer/{id}")]
        public async Task<IActionResult> DeleteAnswer(Guid id)
        {
            var success = await _quizService.DeleteAnswerAsync(id);
            if (!success)
                return NotFound(ApiResponse<object>.FailureResult($"Quiz answer with ID {id} not found or delete failed."));

            return Ok(ApiResponse<object>.SuccessResult(new { id = id }, "Quiz answer deleted successfully."));
        }
    }
}
