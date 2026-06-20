using System;

namespace Sovenire_Collenction_Backend.DTOs.Favorites
{
    public class FavoriteDto
    {
        public Guid Id { get; set; }
        public Guid UserId { get; set; }
        
        public Guid? ProductId { get; set; }
        public string ProductName { get; set; } = string.Empty;
        public string ProductImage { get; set; } = string.Empty;
        public decimal? ProductPrice { get; set; }

        public Guid? CollectionId { get; set; }
        public string CollectionTitle { get; set; } = string.Empty;
        public string CollectionImage { get; set; } = string.Empty;

        public DateTime CreatedAt { get; set; }
    }
}
