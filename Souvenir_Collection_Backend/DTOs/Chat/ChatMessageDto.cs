using System;

namespace Sovenire_Collenction_Backend.DTOs.Chat
{
    public class ChatMessageDto
    {
        public Guid Id { get; set; }
        public Guid RoomId { get; set; }
        public Guid SenderId { get; set; }
        public string SenderName { get; set; } = string.Empty;
        public string Body { get; set; } = string.Empty;
        public bool IsRead { get; set; }
        public DateTime SentAt { get; set; }
    }
}
