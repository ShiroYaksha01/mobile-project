namespace Souvenir_Collection_Backend.DTOs.Auth;

public class GoogleLoginRequest
{
    /// <summary>
    /// The Supabase access_token returned after the user completes Google OAuth
    /// via the Supabase SDK in Flutter (supabase.auth.signInWithOAuth).
    /// </summary>
    [Required]
    public string AccessToken { get; set; } = string.Empty;
}
