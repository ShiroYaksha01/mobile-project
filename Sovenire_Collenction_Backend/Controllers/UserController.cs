using Microsoft.AspNetCore.Mvc;
using Sovenire_Collenction_Backend.Helpers;
using Sovenire_Collenction_Backend.DTOs.User;

namespace Sovenire_Collenction_Backend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class UserController : ControllerBase
    {
        private readonly UserService _userService;

        public UserController(UserService userService)
        {
            _userService = userService;
        }

        private static UserDto MapToDto(User user) => new()
        {
            Id = user.Id,
            Name = user.Name,
            Email = user.Email,
            Role = user.Role.ToString(),
            Phone = user.Phone,
            Address = user.Address,
            Avatar = user.Avatar,
            CreatedAt = user.CreatedAt,
            UpdatedAt = user.UpdatedAt
        };

        // GET api/user
        [HttpGet]
        public async Task<IActionResult> GetAllUsers()
        {
            var users = await _userService.GetAllUsersAsync() ?? new List<User>();
            var dtos = users.Select(MapToDto).ToList();
            return Ok(ApiResponse<List<UserDto>>.SuccessResult(dtos, "Users retrieved successfully."));
        }

        // GET api/user/{id}
        [HttpGet("{id}")]
        public async Task<IActionResult> GetUserById(Guid id)
        {
            var user = await _userService.GetUserByIdAsync(id);
            if (user == null)
                return NotFound(ApiResponse<UserDto>.FailureResult($"User with ID {id} not found."));

            return Ok(ApiResponse<UserDto>.SuccessResult(MapToDto(user), "User details retrieved successfully."));
        }

        // GET api/user/role/{role}
        [HttpGet("role/{role}")]
        public async Task<IActionResult> GetUsersByRole(UserRole role)
        {
            var users = await _userService.GetUsersByRoleAsync(role) ?? new List<User>();
            var dtos = users.Select(MapToDto).ToList();
            return Ok(ApiResponse<List<UserDto>>.SuccessResult(dtos, $"Users with role {role} retrieved successfully."));
        }

        // PUT api/user/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateUser(Guid id, [FromBody] UpdateProfileRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ApiResponse<UserDto>.FailureResult("Invalid request payload."));

            var existing = await _userService.GetUserByIdAsync(id);
            if (existing == null)
                return NotFound(ApiResponse<UserDto>.FailureResult($"User with ID {id} not found."));

            existing.Name = request.Name;
            existing.Phone = request.Phone;
            existing.Address = request.Address;
            existing.Avatar = request.Avatar;
            existing.UpdatedAt = DateTime.UtcNow;

            var user = await _userService.UpdateUserAsync(id, existing);
            if (user == null)
                return NotFound(ApiResponse<UserDto>.FailureResult($"User with ID {id} not found or update failed."));

            return Ok(ApiResponse<UserDto>.SuccessResult(MapToDto(user), "User profile updated successfully."));
        }

        // PUT api/user/{id}/password
        [HttpPut("{id}/password")]
        public async Task<IActionResult> UpdatePassword(Guid id, [FromBody] string newPassword)
        {
            if (string.IsNullOrEmpty(newPassword))
                return BadRequest(ApiResponse<object>.FailureResult("Password cannot be empty."));

            var newPasswordHash = BCrypt.Net.BCrypt.HashPassword(newPassword);
            var success = await _userService.UpdatePasswordAsync(id, newPasswordHash);
            if (!success)
                return NotFound(ApiResponse<object>.FailureResult($"User with ID {id} not found or update failed."));

            return Ok(ApiResponse<object>.SuccessResult(new { success = true, id = id }, "Password updated successfully."));
        }

        // PUT api/user/{id}/avatar
        [HttpPut("{id}/avatar")]
        public async Task<IActionResult> UpdateAvatar(Guid id, [FromBody] string avatarUrl)
        {
            var success = await _userService.UpdateAvatarAsync(id, avatarUrl);
            if (!success)
                return NotFound(ApiResponse<object>.FailureResult($"User with ID {id} not found or update failed."));

            return Ok(ApiResponse<object>.SuccessResult(new { success = true, id = id, avatar = avatarUrl }, "Avatar updated successfully."));
        }

        // DELETE api/user/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteUser(Guid id)
        {
            var success = await _userService.DeleteUserAsync(id);
            if (!success)
                return NotFound(ApiResponse<object>.FailureResult($"User with ID {id} not found or delete failed."));

            return Ok(ApiResponse<object>.SuccessResult(new { id = id }, "User deleted successfully."));
        }
    }
}
