using System;
using System.Collections.Generic;

namespace Sovenire_Collenction_Backend.DTOs.Quiz
{
    public class QuizQuestionDto
    {
        public Guid Id { get; set; }
        public string QuestionText { get; set; } = string.Empty;
        public int DisplayOrder { get; set; }
        public List<QuizAnswerDto> Answers { get; set; } = new List<QuizAnswerDto>();
    }

    public class QuizAnswerDto
    {
        public Guid Id { get; set; }
        public string AnswerText { get; set; } = string.Empty;
    }
}
