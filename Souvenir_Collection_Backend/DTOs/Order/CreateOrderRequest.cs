namespace Sovenire_Collenction_Backend.DTOs.Order
{
    public class CreateOrderRequest
    {
        public Guid? PromotionId { get; set; }
        public string PaymentMethod { get; set; } = string.Empty;
        public string DeliveryAddress { get; set; } = string.Empty;
        public string DeliveryMessage { get; set; } = string.Empty;
        public DateTime DeliveryDate { get; set; }
    }
}
