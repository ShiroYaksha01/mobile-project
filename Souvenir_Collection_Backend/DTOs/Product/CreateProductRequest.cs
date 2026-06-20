using System;
using System.ComponentModel.DataAnnotations;

namespace Sovenire_Collenction_Backend.DTOs.Product
{
    public class CreateProductRequest
    {
        [Required(ErrorMessage = "ArtisanId is required.")]
        public Guid ArtisanId { get; set; }

        [Required(ErrorMessage = "CategoryId is required.")]
        public Guid CategoryId { get; set; }

        [Required(ErrorMessage = "Product name is required.")]
        [StringLength(100, MinimumLength = 2, ErrorMessage = "Product name must be between 2 and 100 characters.")]
        public string Name { get; set; } = string.Empty;

        public string Description { get; set; } = string.Empty;

        [Range(0.01, double.MaxValue, ErrorMessage = "Price must be greater than 0.")]
        public decimal Price { get; set; }

        [Range(0, int.MaxValue, ErrorMessage = "Stock quantity cannot be negative.")]
        public int StockQty { get; set; }

        public string Image { get; set; } = string.Empty;

        public bool IsAvailable { get; set; }
    }
}
