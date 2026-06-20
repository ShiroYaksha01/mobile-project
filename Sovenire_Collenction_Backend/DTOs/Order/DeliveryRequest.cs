using System;

namespace Sovenire_Collenction_Backend.DTOs.Order
{
    public class DeliveryRequest
    {
        public string DeliveryAddress { get; set; } = string.Empty;
        public string DeliveryMessage { get; set; } = string.Empty;
        public DateTime DeliveryDate { get; set; }
    }
}
