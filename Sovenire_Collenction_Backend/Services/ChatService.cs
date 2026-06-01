namespace Souvenir_Collection_Backend.Services
{
    public class ChatService
    {
        private readonly AppDbContext _context;

        public ChatService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<ChatRoom> GetOrCreateChatRoomAsync(Guid userId, Guid artisanId)
        {
            var existingRoom = await _context.ChatRooms
                .Include(r => r.User)
                .Include(r => r.Artisan)
                .FirstOrDefaultAsync(r => r.UserId == userId && r.ArtisanId == artisanId);

            if (existingRoom != null) return existingRoom;

            var newRoom = new ChatRoom
            {
                UserId    = userId,
                ArtisanId = artisanId,
                CreatedAt = DateTime.UtcNow
            };

            await _context.ChatRooms.AddAsync(newRoom);
            await _context.SaveChangesAsync();
            return newRoom;
        }

        public async Task<List<ChatRoom>> GetUserChatRoomsAsync(Guid userId)
        {
            return await _context.ChatRooms
                .Include(r => r.Artisan)
                    .ThenInclude(a => a.User)
                .Include(r => r.ChatMessages.OrderByDescending(m => m.SentAt).Take(1))
                .Where(r => r.UserId == userId)
                .OrderByDescending(r => r.CreatedAt)
                .ToListAsync();
        }

        public async Task<List<ChatRoom>> GetArtisanChatRoomsAsync(Guid artisanId)
        {
            return await _context.ChatRooms
                .Include(r => r.User)
                .Include(r => r.ChatMessages.OrderByDescending(m => m.SentAt).Take(1))
                .Where(r => r.ArtisanId == artisanId)
                .OrderByDescending(r => r.CreatedAt)
                .ToListAsync();
        }

        public async Task<ChatRoom> GetChatRoomByIdAsync(Guid chatRoomId)
        {
            return await _context.ChatRooms
                .Include(r => r.User)
                .Include(r => r.Artisan)
                    .ThenInclude(a => a.User)
                .FirstOrDefaultAsync(r => r.Id == chatRoomId);
        }

        public async Task<List<ChatMessage>> GetMessagesAsync(Guid roomId)
        {
            return await _context.ChatMessages
                .Include(m => m.Sender)
                .Where(m => m.RoomId == roomId)
                .OrderBy(m => m.SentAt)
                .ToListAsync();
        }

        public async Task<ChatMessage> SendMessageAsync(Guid roomId, Guid senderId, string body)
        {
            var chatRoom = await _context.ChatRooms.FindAsync(roomId);
            if (chatRoom == null) return null;

            var artisan = await _context.Artisans
                .FirstOrDefaultAsync(a => a.Id == chatRoom.ArtisanId && a.UserId == senderId);

            var isParticipant = chatRoom.UserId == senderId || artisan != null;
            if (!isParticipant) return null;

            var message = new ChatMessage
            {
                RoomId   = roomId,
                SenderId = senderId,
                Body     = body,
                IsRead   = false,
                SentAt   = DateTime.UtcNow
            };

            await _context.ChatMessages.AddAsync(message);
            await _context.SaveChangesAsync();
            return message;
        }

        public async Task<bool> MarkAsReadAsync(Guid roomId, Guid userId)
        {
            var unreadMessages = await _context.ChatMessages
                .Where(m => m.RoomId == roomId &&
                            m.SenderId != userId &&
                            m.IsRead == false)
                .ToListAsync();

            if (!unreadMessages.Any()) return false;

            unreadMessages.ForEach(m => m.IsRead = true);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<int> GetUnreadCountAsync(Guid userId)
        {
            return await _context.ChatMessages
                .Include(m => m.ChatRoom)
                .CountAsync(m => m.ChatRoom.UserId == userId &&
                                 m.SenderId != userId &&
                                 m.IsRead == false);
        }

        public async Task<bool> DeleteMessageAsync(Guid messageId, Guid senderId)
        {
            var message = await _context.ChatMessages
                .FirstOrDefaultAsync(m => m.Id == messageId && m.SenderId == senderId);

            if (message == null) return false;

            _context.ChatMessages.Remove(message);
            await _context.SaveChangesAsync();
            return true;
        }
    }
}