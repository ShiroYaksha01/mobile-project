namespace Sovenire_Collenction_Backend.DTOs.User
{
    public class UpdateProfileRequest
    {
        public string Name { get; set; } = string.Empty;
        public string? Phone { get; set; }
        public string Address { get; set; } = string.Empty;
        public string Avatar { get; set; } = string.Empty;
    }
}
