namespace Sovenire_Collenction_Backend.DTOs.Auth
{
    public class LoginRequest
    {
        [Required]
        [EmailAddress]
        public string Email { get; set; } = string.Empty;

        [Required]
        public string Password { get; set; } = string.Empty;

        public string? AccessToken { get; set; }

        public AuthProvider Provider { get; set; } = AuthProvider.Local;
    }

}