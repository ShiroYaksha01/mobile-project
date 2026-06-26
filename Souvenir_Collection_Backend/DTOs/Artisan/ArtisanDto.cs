using System;

namespace Sovenire_Collenction_Backend.DTOs.Artisan
{
    public class ArtisanDto
    {
        public Guid Id { get; set; }
        public string DisplayName { get; set; } = string.Empty;
        public string Region { get; set; } = string.Empty;
        public string CraftType { get; set; } = string.Empty;
        public string Bio { get; set; } = string.Empty;
        public string ProfilePhotoUrl { get; set; } = string.Empty;
        public string ShopAddress { get; set; } = string.Empty;
        public decimal Lat { get; set; }
        public decimal Lng { get; set; }
        public bool IsVerified { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
    }
}
