namespace Souvenir_Collection_Backend.Models
{
    public class ChatMessage
    {
        [Key]
        public Guid Id { get; set; } = Guid.NewGuid();

        public Guid RoomId { get; set; }
        public ChatRoom ChatRoom { get; set; }

        public Guid SenderId { get; set; }
        public User Sender { get; set; }

        public string Body { get; set; } = string.Empty;

        public bool IsRead { get; set; } = false;

        public DateTime SentAt { get; set; } = DateTime.UtcNow;
    }
}
