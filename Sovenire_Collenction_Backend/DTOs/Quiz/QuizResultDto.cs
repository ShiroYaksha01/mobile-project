using System;
using System.Collections.Generic;
using Sovenire_Collenction_Backend.DTOs.Product;

namespace Sovenire_Collenction_Backend.DTOs.Quiz
{
    public class QuizResultDto
    {
        public List<Guid> RecommendedProductIds { get; set; } = new List<Guid>();
        public List<ProductDto> RecommendedProducts { get; set; } = new List<ProductDto>();
        public List<string> MatchedTags { get; set; } = new List<string>();
        public string Feedback { get; set; } = string.Empty;
    }
}
