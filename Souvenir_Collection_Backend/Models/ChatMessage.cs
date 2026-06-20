using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;

namespace Souvenir_Collection_Backend.Models
{
    public class ChatMessage
    {
        [Key]
        public Guid Id { get; set; } = Guid.NewGuid();

        public Guid RoomId { get; set; }
        
        [JsonIgnore]
        [ForeignKey("RoomId")]
        public ChatRoom ChatRoom { get; set; }

        [ForeignKey("SenderId")]
        public Guid SenderId { get; set; }

        public string Body { get; set; } = string.Empty;

        public bool IsRead { get; set; } = false;

        public DateTime SentAt { get; set; } = DateTime.UtcNow;
    }
}
