using System;

namespace Sovenire_Collenction_Backend.DTOs.Chat
{
    public class GetOrCreateRoomRequest
    {
        public Guid UserId { get; set; }
        public Guid ArtisanId { get; set; }
    }
}
