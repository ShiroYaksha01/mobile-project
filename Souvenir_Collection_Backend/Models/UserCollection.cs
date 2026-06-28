using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace Souvenir_Collection_Backend.Models
{
    public class UserCollection
    {
        [Key]
        public Guid Id { get; set; } = Guid.NewGuid();

        public Guid UserId { get; set; }
        [JsonIgnore]
        public User User { get; set; }

        [Required]
        [MaxLength(150)]
        public string Name { get; set; } = string.Empty;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public ICollection<UserCollectionItem> Items { get; set; } = new List<UserCollectionItem>();
    }
}
