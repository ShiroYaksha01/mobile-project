using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace Souvenir_Collection_Backend.Models
{
    public class UserCollectionItem
    {
        [Key]
        public Guid Id { get; set; } = Guid.NewGuid();

        public Guid UserCollectionId { get; set; }
        [JsonIgnore]
        public UserCollection UserCollection { get; set; }

        public Guid ProductId { get; set; }
        public Product Product { get; set; }

        public int Quantity { get; set; } = 1;
    }
}
