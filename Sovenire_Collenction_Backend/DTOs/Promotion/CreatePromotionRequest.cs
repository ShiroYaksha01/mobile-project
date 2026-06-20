using Sovenire_Collenction_Backend.Enums;

namespace Sovenire_Collenction_Backend.DTOs.Promotion
{
    public class CreatePromotionRequest
    {
        public string Title { get; set; } = string.Empty;
        public string Code { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public string Image { get; set; } = string.Empty;
        public DiscountType DiscountType { get; set; }
        public decimal Discount { get; set; }
        public int UsageLimit { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
    }

    public class UpdatePromotionRequest : CreatePromotionRequest {}
}
