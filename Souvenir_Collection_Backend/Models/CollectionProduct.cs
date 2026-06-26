using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Souvenir_Collection_Backend.Models
{
    public class CollectionProduct
    {
        [Key]
        public Guid Id { get; set; } = Guid.NewGuid();

        public Guid CollectionId { get; set; }

        [ForeignKey("CollectionId")]
        public Collection? Collection { get; set; }

        public Guid ProductId { get; set; }

        [ForeignKey("ProductId")]
        public Product? Product { get; set; }

        public int DisplayOrder { get; set; } = 1;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    }
}