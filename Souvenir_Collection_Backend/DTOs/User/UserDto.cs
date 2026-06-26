using System;

namespace Sovenire_Collenction_Backend.DTOs.User
{
    public class UserDto
    {
        public Guid Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string Role { get; set; } = string.Empty; 
        public string? Phone { get; set; }
        public string Address { get; set; } = string.Empty;
        public string Avatar { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
    }
}
