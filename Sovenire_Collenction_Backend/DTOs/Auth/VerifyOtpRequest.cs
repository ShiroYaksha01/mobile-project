using System.ComponentModel.DataAnnotations;

namespace Sovenire_Collenction_Backend.DTOs.Auth
{
    public class VerifyOtpRequest
    {
        [Required]
        [EmailAddress]
        public string Email { get; set; } = string.Empty;

        [Required]
        public string Token { get; set; } = string.Empty;

        public string Type { get; set; } = "signup"; // "signup", "recovery", "magiclink", "email_change", etc.
    }
}
