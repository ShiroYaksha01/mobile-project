using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Souvenir_Collection_Backend.Models
{
    public class Product
    {
        [Key]
        public Guid Id { get; set; } = Guid.NewGuid();

        // Artisan FK + Navigation
        public Guid ArtisanId { get; set; }

        [ForeignKey(nameof(ArtisanId))]
        public Artisan? Artisan { get; set; }

        // Category FK + Navigation
        public Guid CategoryId { get; set; }

        [ForeignKey(nameof(CategoryId))]
        public Category? Category { get; set; }

        [Required]
        [MaxLength(200)]
        public string Name { get; set; } = string.Empty;

        public string Description { get; set; } = string.Empty;

        [Column(TypeName = "decimal(10,2)")]
        public decimal Price { get; set; } = 0.00m;

        public int StockQty { get; set; } = 0;

        public string Image { get; set; } = string.Empty;

        public bool IsAvailable { get; set; } = false;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        public ICollection<CartItem> CartItems { get; set; } = new List<CartItem>();
        public ICollection<OrderItem> OrderItems { get; set; } = new List<OrderItem>();
        public ICollection<CollectionProduct> CollectionProducts { get; set; } = new List<CollectionProduct>();
        public ICollection<Favorite> Favorites { get; set; } = new List<Favorite>();
    }
}