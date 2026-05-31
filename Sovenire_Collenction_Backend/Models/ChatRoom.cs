namespace Souvenir_Collection_Backend.Models
{

    public class ChatRoom
    {
        [Key]
        public Guid Id { get; set; } = Guid.NewGuid();

        public Guid UserId { get; set; }
        public User User { get; set; }

        public Guid ArtisanId { get; set; }
        public Artisan Artisan { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public ICollection<ChatMessage> ChatMessages { get; set; }
    }
}
