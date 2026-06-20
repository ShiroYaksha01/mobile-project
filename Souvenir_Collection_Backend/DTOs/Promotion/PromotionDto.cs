using System;
using Sovenire_Collenction_Backend.Enums;

namespace Sovenire_Collenction_Backend.DTOs.Promotion
{
    public class PromotionDto
    {
        public Guid Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public string Code { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public string Image { get; set; } = string.Empty;
        public string DiscountType { get; set; } = string.Empty; 
        public decimal Discount { get; set; }
        public int UsageLimit { get; set; }
        public int UsageCount { get; set; }
        public string Status { get; set; } = string.Empty;
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
    }
}
