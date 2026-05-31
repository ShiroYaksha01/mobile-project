using System.ComponentModel.DataAnnotations;

namespace Sovenire_Collenction_Backend.DTOs.Auth
{
    public class RegisterRequest
    {
        [Required]
        public string Name { get; set; } = string.Empty;

        [Required]
        [EmailAddress]
        public string Email { get; set; } = string.Empty;

        public string? Password { get; set; }

        public string? ConfirmPassword { get; set; }

        public string? AccessToken { get; set; }

        public AuthProvider Provider { get; set; } = AuthProvider.Local;
    }
}