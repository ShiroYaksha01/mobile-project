using System;

namespace Sovenire_Collenction_Backend.DTOs.Product
{
    public class ProductDto
    {
        public Guid Id { get; set; }
        public Guid ArtisanId { get; set; }
        public Guid CategoryId { get; set; }
        public Guid? CollectionId { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public decimal Price { get; set; }
        public int StockQty { get; set; }
        public string Image { get; set; } = string.Empty;
        public bool IsAvailable { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
    }
}
