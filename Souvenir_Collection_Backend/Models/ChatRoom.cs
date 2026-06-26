using System.Text.Json.Serialization;

namespace Souvenir_Collection_Backend.Models
{

    public class ChatRoom
    {
        [Key]
        public Guid Id { get; set; } = Guid.NewGuid();

        public Guid UserId { get; set; }
        
        [JsonIgnore]
        public User User { get; set; }

        public Guid ArtisanId { get; set; }
        
        [JsonIgnore]
        public Artisan Artisan { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [JsonIgnore]
        public ICollection<ChatMessage> ChatMessages { get; set; }
    }
}
