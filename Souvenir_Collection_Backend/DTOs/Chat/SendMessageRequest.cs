using System;

namespace Sovenire_Collenction_Backend.DTOs.Chat
{
    public class SendMessageRequest
    {
        public Guid RoomId { get; set; }
        public Guid SenderId { get; set; }
        public string Body { get; set; } = string.Empty;
    }
}
