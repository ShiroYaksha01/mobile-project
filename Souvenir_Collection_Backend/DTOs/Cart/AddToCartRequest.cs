using System;

namespace Sovenire_Collenction_Backend.DTOs.Cart
{
    public class AddToCartRequest
    {
        public Guid ProductId { get; set; }
        public int Quantity { get; set; }
    }
}
