using System;
using System.Collections.Generic;

namespace Sovenire_Collenction_Backend.DTOs.Quiz
{
    public class QuizAnswerRequest
    {
        public List<Guid> SelectedAnswerIds { get; set; } = new List<Guid>();
    }
}
