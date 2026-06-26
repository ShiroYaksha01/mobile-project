using System;

namespace Sovenire_Collenction_Backend.DTOs.Review
{
    public class CreateReviewRequest
    {
        public Guid UserId { get; set; }
        public Guid? ProductId { get; set; }
        public Guid? CollectionId { get; set; }
        public string ReviewText { get; set; } = string.Empty;
        public int Rating { get; set; }
        public string Image { get; set; } = string.Empty;
    }
}
