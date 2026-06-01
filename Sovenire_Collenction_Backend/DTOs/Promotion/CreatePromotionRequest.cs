using Sovenire_Collenction_Backend.Enums;

namespace Sovenire_Collenction_Backend.DTOs.Promotion
{
    public class CreatePromotionRequest
    {
        public string Code { get; set; } = string.Empty;
        public DiscountType DiscountType { get; set; }
        public decimal Value { get; set; }
        public decimal MinOrderAmount { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public int UsageLimit { get; set; }
        public bool IsActive { get; set; }
    }

    public class UpdatePromotionRequest : CreatePromotionRequest {}
}
