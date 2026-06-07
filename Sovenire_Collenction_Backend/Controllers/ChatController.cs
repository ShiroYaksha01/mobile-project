using Microsoft.AspNetCore.Mvc;
using Sovenire_Collenction_Backend.Helpers;
using Microsoft.AspNetCore.Authorization;
using Souvenir_Collection_Backend.Models;
using Souvenir_Collection_Backend.Services;

namespace Sovenire_Collenction_Backend.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class ChatController : ControllerBase
    {
        private readonly ChatService _chatService;

        public ChatController(ChatService chatService)
        {
            _chatService = chatService;
        }

        private Guid GetUserIdFromToken()
        {
            var userIdStr = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
            if (Guid.TryParse(userIdStr, out var userId))
                return userId;
            return Guid.Empty;
        }

        // POST api/chat/room
        [HttpPost("room")]
        public async Task<IActionResult> GetOrCreateChatRoom([FromBody] Sovenire_Collenction_Backend.DTOs.Chat.GetOrCreateRoomRequest request)
        {
            var currentUserId = GetUserIdFromToken();
            if (currentUserId == Guid.Empty || request == null || request.ArtisanId == Guid.Empty)
                return BadRequest(ApiResponse<ChatRoom>.FailureResult("Valid token and ArtisanId are required."));

            var room = await _chatService.GetOrCreateChatRoomAsync(currentUserId, request.ArtisanId);
            if (room == null)
                return BadRequest(ApiResponse<ChatRoom>.FailureResult("Failed to resolve or create chat room."));

            return Ok(ApiResponse<ChatRoom>.SuccessResult(room, "Chat room resolved successfully."));
        }

        // GET api/chat/rooms/user
        [HttpGet("rooms/user")]
        public async Task<IActionResult> GetUserChatRooms()
        {
            var currentUserId = GetUserIdFromToken();
            if (currentUserId == Guid.Empty)
                return Unauthorized(ApiResponse<List<ChatRoom>>.FailureResult("Invalid token."));

            var rooms = await _chatService.GetUserChatRoomsAsync(currentUserId) ?? new List<ChatRoom>();
            return Ok(ApiResponse<List<ChatRoom>>.SuccessResult(rooms, "User chat rooms retrieved successfully."));
        }

        // GET api/chat/rooms/artisan
        [HttpGet("rooms/artisan")]
        public async Task<IActionResult> GetArtisanChatRooms()
        {
            var currentUserId = GetUserIdFromToken();
            if (currentUserId == Guid.Empty)
                return Unauthorized(ApiResponse<List<ChatRoom>>.FailureResult("Invalid token."));

            var rooms = await _chatService.GetArtisanChatRoomsAsync(currentUserId) ?? new List<ChatRoom>();
            return Ok(ApiResponse<List<ChatRoom>>.SuccessResult(rooms, "Artisan chat rooms retrieved successfully."));
        }

        // GET api/chat/rooms/{roomId}
        [HttpGet("rooms/{roomId}")]
        public async Task<IActionResult> GetChatRoomById(Guid roomId)
        {
            var room = await _chatService.GetChatRoomByIdAsync(roomId);
            if (room == null)
                return NotFound(ApiResponse<ChatRoom>.FailureResult($"Chat room {roomId} not found."));

            return Ok(ApiResponse<ChatRoom>.SuccessResult(room, "Chat room retrieved successfully."));
        }

        // GET api/chat/rooms/{roomId}/messages
        [HttpGet("rooms/{roomId}/messages")]
        public async Task<IActionResult> GetMessages(Guid roomId)
        {
            var messages = await _chatService.GetMessagesAsync(roomId) ?? new List<ChatMessage>();
            return Ok(ApiResponse<List<ChatMessage>>.SuccessResult(messages, "Messages retrieved successfully."));
        }

        // POST api/chat/rooms/{roomId}/send
        [HttpPost("rooms/{roomId}/send")]
        public async Task<IActionResult> SendMessage(Guid roomId, [FromBody] Sovenire_Collenction_Backend.DTOs.Chat.SendMessageRequest request)
        {
            var currentUserId = GetUserIdFromToken();
            if (currentUserId == Guid.Empty || request == null || string.IsNullOrEmpty(request.Body))
                return BadRequest(ApiResponse<ChatMessage>.FailureResult("Invalid token or empty message body."));

            var message = await _chatService.SendMessageAsync(roomId, currentUserId, request.Body);
            if (message == null)
                return BadRequest(ApiResponse<ChatMessage>.FailureResult("Failed to send message. Ensure you are a participant in the room."));

            return Ok(ApiResponse<ChatMessage>.SuccessResult(message, "Message sent successfully."));
        }

        // PATCH api/chat/rooms/{roomId}/read
        [HttpPatch("rooms/{roomId}/read")]
        public async Task<IActionResult> MarkMessagesAsRead(Guid roomId)
        {
            var currentUserId = GetUserIdFromToken();
            if (currentUserId == Guid.Empty)
                return Unauthorized(ApiResponse<object>.FailureResult("Invalid token."));

            var success = await _chatService.MarkAsReadAsync(roomId, currentUserId);
            return Ok(ApiResponse<object>.SuccessResult(new { success = success }, "Messages marked as read."));
        }

        // GET api/chat/unread-count
        [HttpGet("unread-count")]
        public async Task<IActionResult> GetUnreadMessagesCount()
        {
            var currentUserId = GetUserIdFromToken();
            if (currentUserId == Guid.Empty)
                return Unauthorized(ApiResponse<int>.FailureResult("Invalid token."));

            var count = await _chatService.GetUnreadCountAsync(currentUserId);
            return Ok(ApiResponse<int>.SuccessResult(count, "Unread count calculated."));
        }

        // PUT api/chat/message/{messageId}
        [HttpPut("message/{messageId}")]
        public async Task<IActionResult> UpdateMessage(Guid messageId, [FromBody] Sovenire_Collenction_Backend.DTOs.Chat.UpdateMessageRequest request)
        {
            var currentUserId = GetUserIdFromToken();
            if (currentUserId == Guid.Empty || request == null || string.IsNullOrEmpty(request.Body))
                return BadRequest(ApiResponse<ChatMessage>.FailureResult("Invalid token or empty message body."));

            var updatedMessage = await _chatService.UpdateMessageAsync(messageId, currentUserId, request.Body);
            if (updatedMessage == null)
                return NotFound(ApiResponse<ChatMessage>.FailureResult($"Message with ID {messageId} not found, or you are not the sender."));

            return Ok(ApiResponse<ChatMessage>.SuccessResult(updatedMessage, "Message updated successfully."));
        }

        // DELETE api/chat/message/{messageId}
        [HttpDelete("message/{messageId}")]
        public async Task<IActionResult> DeleteMessage(Guid messageId)
        {
            var currentUserId = GetUserIdFromToken();
            if (currentUserId == Guid.Empty)
                return Unauthorized(ApiResponse<object>.FailureResult("Invalid token."));

            var success = await _chatService.DeleteMessageAsync(messageId, currentUserId);
            if (!success)
                return NotFound(ApiResponse<object>.FailureResult($"Message with ID {messageId} not found, or you are not the sender."));

            return Ok(ApiResponse<object>.SuccessResult(new { id = messageId }, "Message deleted successfully."));
        }

        [HttpGet("fixdb")]
        public async Task<IActionResult> FixDb([FromServices] Souvenir_Collection_Backend.Data.AppDbContext context)
        {
            try {
                // 1. Update DB Schema
                await Microsoft.EntityFrameworkCore.RelationalDatabaseFacadeExtensions.ExecuteSqlRawAsync(context.Database, "ALTER TABLE chat_messages DROP CONSTRAINT IF EXISTS chat_messages_sender_id_fkey;");
                
                // Add column without a strict foreign key constraint to avoid PostgreSQL relation errors
                await Microsoft.EntityFrameworkCore.RelationalDatabaseFacadeExtensions.ExecuteSqlRawAsync(context.Database, "ALTER TABLE artisans ADD COLUMN IF NOT EXISTS user_id uuid;");

                return Ok(new { success = true, message = "Database schema updated successfully. The user_id column was added!" });
            } catch (System.Exception ex) {
                return BadRequest(new { success = false, message = "Database error: " + ex.Message });
            }
        }
    }
}
