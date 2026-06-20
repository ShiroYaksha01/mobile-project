namespace Sovenire_Collenction_Backend.DTOs.Order
{
    public class GiftWrapRequest
    {
        public string WrapType { get; set; } = string.Empty;
        public string PersonalMessage { get; set; } = string.Empty;
        public decimal WrapCost { get; set; }
    }
}
