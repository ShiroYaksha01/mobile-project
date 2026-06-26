namespace Sovenire_Collenction_Backend.DTOs.Shop
{
    public class NearbyShopRequest
    {
        public decimal Lat { get; set; }
        public decimal Lng { get; set; }
        public double RadiusInKm { get; set; } = 10.0;
        public string CraftType { get; set; } = string.Empty;
    }
}
