using System;

namespace Sovenire_Collenction_Backend.DTOs.Chat
{
    public class UpdateMessageRequest
    {
        public Guid SenderId { get; set; }
        public string Body { get; set; } = string.Empty;
    }
}
