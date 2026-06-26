using System;

namespace Sovenire_Collenction_Backend.DTOs.Artisan
{
    public class CreateArtisanRequest
    {
        public string DisplayName { get; set; } = string.Empty;
        public string Region { get; set; } = string.Empty;
        public string CraftType { get; set; } = string.Empty;
        public string Bio { get; set; } = string.Empty;
        public string ProfilePhotoUrl { get; set; } = string.Empty;
        public string ShopAddress { get; set; } = string.Empty;
        public decimal Lat { get; set; }
        public decimal Lng { get; set; }
    }
}
