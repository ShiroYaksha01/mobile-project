using System;

namespace Sovenire_Collenction_Backend.DTOs.Chat
{
    public class ChatRoomDto
    {
        public Guid Id { get; set; }
        public Guid UserId { get; set; }
        public string UserName { get; set; } = string.Empty;
        public string UserAvatar { get; set; } = string.Empty;
        public Guid ArtisanId { get; set; }
        public string ArtisanName { get; set; } = string.Empty;
        public string ArtisanAvatar { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
        public string LastMessageBody { get; set; } = string.Empty;
        public DateTime? LastMessageTime { get; set; }
        public int UnreadCount { get; set; }
    }
}
