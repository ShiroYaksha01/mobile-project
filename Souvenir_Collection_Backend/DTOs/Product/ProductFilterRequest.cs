using System;

namespace Sovenire_Collenction_Backend.DTOs.Product
{
    public class ProductFilterRequest
    {
        public Guid? CategoryId { get; set; }
        public Guid? ArtisanId { get; set; }
        public decimal? MinPrice { get; set; }
        public decimal? MaxPrice { get; set; }
        public string SearchQuery { get; set; } = string.Empty;
        public string SortBy { get; set; } = string.Empty;
        public bool? IsAvailable { get; set; }
    }
}
