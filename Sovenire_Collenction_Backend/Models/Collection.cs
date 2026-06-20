using System.ComponentModel.DataAnnotations;

namespace Souvenir_Collection_Backend.Models
{
    public class Collection
    {
        [Key]
        public Guid Id { get; set; } = Guid.NewGuid();

        [Required]
        [MaxLength(150)]
        public string Title { get; set; } = string.Empty;

        [MaxLength(150)]
        public string Slug { get; set; } = string.Empty;

        public string Description { get; set; } = string.Empty;

        [MaxLength(50)]
        public string Type { get; set; } = string.Empty;

        public string Image { get; set; } = string.Empty;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        [System.Text.Json.Serialization.JsonIgnore]
        public ICollection<Product> Products { get; set; } = new List<Product>();
    }
}