using BCrypt.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;

namespace Souvenir_Collection_Backend.Services
{
    public class AuthService
    {
        private readonly Client         _supabase;
        private readonly TokenService   _tokenService;
        private readonly IHttpClientFactory _httpClientFactory;

        public AuthService(
            Client supabase,
            TokenService tokenService,
            IHttpClientFactory httpClientFactory)
        {
            _supabase           = supabase;
            _tokenService       = tokenService;
            _httpClientFactory  = httpClientFactory;
        }

        public async Task<RegisterResponse?> RegisterAsync(RegisterRequest request)
        {
            if (string.IsNullOrEmpty(request.Password))
            {
                return null;
            }

            // 1. Sign up user via Supabase Auth
            var response = await _supabase.Auth.SignUp(
                request.Email,
                request.Password
            );

            if (response?.User == null)
            {
                return null;
            }

            // 2. Hash password and save user profile via Supabase Client SDK REST API
            var user = new User
            {
                Id = Guid.Parse(response.User.Id),
                Email = request.Email,
                Name = request.Name,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
                Role = UserRole.Customer,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };

            await _supabase.From<User>().Insert(user);

            // 3. Generate our custom JWT token for the backend session
            var accessToken = _tokenService.GenerateToken(user);
            var refreshToken = response?.RefreshToken ?? "";

            return new RegisterResponse
            {
                AccessToken = accessToken,
                RefreshToken = refreshToken,
                Name = user.Name,
                Email = user.Email,
                Role = user.Role
            };
        }

        public async Task<LoginResponse?> SignInAsync(LoginRequest request)
        {
            // 1. Authenticate with Supabase Auth using password
            var response = await _supabase.Auth.SignInWithPassword(
                request.Email,
                request.Password
            );

            if (response?.User == null)
            {
                return null;
            }

            // 2. Retrieve local user record from Supabase via Client SDK
            var userResult = await _supabase.From<User>()
                .Where(u => u.Email == request.Email)
                .Get();
            var user = userResult.Model;

            if (user == null)
            {
                // If user exists in Supabase Auth but not in the user table, create it
                user = new User
                {
                    Id = Guid.Parse(response.User.Id),
                    Email = request.Email,
                    Name = response.User.UserMetadata != null && response.User.UserMetadata.ContainsKey("full_name")
                        ? response.User.UserMetadata["full_name"]?.ToString() ?? "User"
                        : "User",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
                    Role = UserRole.Customer,
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                };

                await _supabase.From<User>().Insert(user);
            }

            // 3. Generate our custom JWT token for client sessions
            var accessToken = _tokenService.GenerateToken(user);
            var refreshToken = response?.RefreshToken ?? "";

            return new LoginResponse
            {
                AccessToken = accessToken,
                RefreshToken = refreshToken,
                Name = user.Name,
                Email = user.Email,
                Role = user.Role.ToString()
            };
        }

        // ─────────────────────────────────────────────────────────────────
        // GOOGLE LOGIN via Supabase
        // Flutter uses Supabase SDK to sign in with Google.
        // Supabase returns an access_token → Flutter sends it here.
        // We verify by calling Supabase /auth/v1/user, then find/create
        // the local user and return our custom JWT.
        // ─────────────────────────────────────────────────────────────────
        public async Task<LoginResponse?> GoogleLoginAsync(string supabaseAccessToken)
        {
            // 1. Verify token by calling Supabase /auth/v1/user
            var supabaseUrl = Environment.GetEnvironmentVariable("SUPABASE_URL");
            var supabaseKey = Environment.GetEnvironmentVariable("SUPABASE_KEY");

            var http = _httpClientFactory.CreateClient();
            http.DefaultRequestHeaders.Authorization =
                new AuthenticationHeaderValue("Bearer", supabaseAccessToken);
            http.DefaultRequestHeaders.Add("apikey", supabaseKey);

            var res = await http.GetAsync($"{supabaseUrl}/auth/v1/user");
            if (!res.IsSuccessStatusCode)
                return null; // invalid or expired token

            var supabaseUser = await res.Content.ReadFromJsonAsync<SupabaseUserResponse>();
            if (supabaseUser == null || string.IsNullOrEmpty(supabaseUser.Email))
                return null;

            // 2. Find existing user or create a new one via Supabase Client SDK
            var userResult = await _supabase.From<User>()
                .Where(u => u.Email == supabaseUser.Email)
                .Get();
            var user = userResult.Model;

            if (user == null)
            {
                var avatar = supabaseUser.UserMetadata?.ContainsKey("avatar_url") == true
                    ? supabaseUser.UserMetadata["avatar_url"]?.ToString() ?? string.Empty
                    : string.Empty;

                var name = supabaseUser.UserMetadata?.ContainsKey("full_name") == true
                    ? supabaseUser.UserMetadata["full_name"]?.ToString() ?? supabaseUser.Email
                    : supabaseUser.Email;

                user = new User
                {
                    Id           = Guid.Parse(supabaseUser.Id ?? Guid.NewGuid().ToString()),
                    Email        = supabaseUser.Email,
                    Name         = name,
                    Avatar       = avatar,
                    PasswordHash = string.Empty,  // OAuth users have no password
                    Role         = UserRole.Customer,
                    CreatedAt    = DateTime.UtcNow,
                    UpdatedAt    = DateTime.UtcNow
                };

                await _supabase.From<User>().Insert(user);
            }

            // 3. Return our custom JWT
            return new LoginResponse
            {
                AccessToken  = _tokenService.GenerateToken(user),
                RefreshToken = string.Empty,
                Name         = user.Name,
                Email        = user.Email,
                Role         = user.Role.ToString()
            };
        }
    }

    // ─────────────────────────────────────────────────────────────────────
    // Supabase /auth/v1/user response shape
    // ─────────────────────────────────────────────────────────────────────
    internal sealed class SupabaseUserResponse
    {
        [System.Text.Json.Serialization.JsonPropertyName("id")]
        public string? Id { get; set; }

        [System.Text.Json.Serialization.JsonPropertyName("email")]
        public string? Email { get; set; }

        [System.Text.Json.Serialization.JsonPropertyName("user_metadata")]
        public Dictionary<string, object?>? UserMetadata { get; set; }
    }
}