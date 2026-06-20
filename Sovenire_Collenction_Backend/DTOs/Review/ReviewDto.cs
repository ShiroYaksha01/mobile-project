using System;

namespace Sovenire_Collenction_Backend.DTOs.Review
{
    public class ReviewDto
    {
        public Guid Id { get; set; }
        public Guid UserId { get; set; }
        public string UserName { get; set; } = string.Empty;
        public string UserAvatar { get; set; } = string.Empty;
        public Guid? ProductId { get; set; }
        public string ProductName { get; set; } = string.Empty;

        public string ReviewText { get; set; } = string.Empty;
        public int Rating { get; set; }
        public string Image { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
    }
}
