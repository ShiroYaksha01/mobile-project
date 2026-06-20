using System;

namespace Sovenire_Collenction_Backend.DTOs.Shop
{
    public class ShopDto
    {
        public Guid Id { get; set; }
        public string ShopName { get; set; } = string.Empty;
        public string Address { get; set; } = string.Empty;
        public decimal Lat { get; set; }
        public decimal Lng { get; set; }
        public string CraftType { get; set; } = string.Empty;
        public double DistanceInKm { get; set; }
    }
}
