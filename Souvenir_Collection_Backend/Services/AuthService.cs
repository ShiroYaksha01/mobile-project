using BCrypt.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using Souvenir_Collection_Backend.Data;

namespace Souvenir_Collection_Backend.Services
{
    public class AuthService
    {
        private readonly Client             _supabase;
        private readonly TokenService       _tokenService;
        private readonly IHttpClientFactory _httpClientFactory;
        private readonly AppDbContext       _context;

        public AuthService(
            Client supabase,
            TokenService tokenService,
            IHttpClientFactory httpClientFactory,
            AppDbContext context)
        {
            _supabase          = supabase;
            _tokenService      = tokenService;
            _httpClientFactory = httpClientFactory;
            _context           = context;
        }

        public async Task<RegisterResponse?> RegisterAsync(RegisterRequest request)
        {
            if (string.IsNullOrEmpty(request.Password))
                return null;

            Supabase.Gotrue.Session? response = null;
            try
            {
                response = await _supabase.Auth.SignUp(request.Email, request.Password);
            }
            catch (Exception ex)
            {
                // Self-healing: if the user already exists in Supabase Auth but is missing from our custom DB table
                if (ex.Message.Contains("user_already_exists"))
                {
                    try
                    {
                        var signInResponse = await _supabase.Auth.SignInWithPassword(request.Email, request.Password);
                        if (signInResponse?.User != null)
                        {
                            var existingResult = await _supabase.From<User>()
                                .Where(u => u.Email == request.Email)
                                .Get();
                            var existingUser = existingResult.Model;

                            if (existingUser == null)
                            {
                                // Profile record was missing! Let's insert it now to heal the account
                                // Parse the string role safely before object initialization
                                Souvenir_Collection_Backend.Enums.UserRole finalRole = Souvenir_Collection_Backend.Enums.UserRole.Customer;
                                if (!string.IsNullOrEmpty(request.Role))
                                {
                                    Enum.TryParse(request.Role, true, out finalRole);
                                }

                                var newUser = new User
                                {
                                    Id           = Guid.Parse(signInResponse.User.Id),
                                    Email        = request.Email,
                                    Name         = request.Name,
                                    PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
                                    Role         = finalRole,
                                    CreatedAt    = DateTime.UtcNow,
                                    UpdatedAt    = DateTime.UtcNow
                                };

                                await _supabase.From<User>().Insert(newUser);
                                existingUser = newUser;

                                // If they are an Artisan, create a blank artisan profile for them immediately
                                if (existingUser.Role == Souvenir_Collection_Backend.Enums.UserRole.Artisan)
                                {
                                    var artisan = new Artisan
                                    {
                                        UserId = existingUser.Id,
                                        DisplayName = existingUser.Name
                                    };
                                    await _context.Artisans.AddAsync(artisan);
                                    await _context.SaveChangesAsync();
                                }

                                return new RegisterResponse
                                {
                                    Id           = existingUser.Id,
                                    AccessToken  = _tokenService.GenerateToken(existingUser),
                                    RefreshToken = signInResponse.RefreshToken ?? "",
                                    Name         = existingUser.Name,
                                    Email        = existingUser.Email,
                                    Role         = existingUser.Role
                                };
                            }
                            else
                            {
                                // Fully-created user trying to register again! Return null to indicate the email is already in use
                                return null;
                            }
                        }
                    }
                    catch (Exception)
                    {
                        // If sign in fails (e.g. wrong password or other issue), return null to indicate duplicate user
                        return null;
                    }
                }

                return null;
            }

            if (response?.User == null)
                return null;

            // Parse the string role safely before object initialization
            Souvenir_Collection_Backend.Enums.UserRole finalRole2 = Souvenir_Collection_Backend.Enums.UserRole.Customer;
            if (!string.IsNullOrEmpty(request.Role))
            {
                Enum.TryParse(request.Role, true, out finalRole2);
            }

            var user = new User
            {
                Id           = Guid.Parse(response.User.Id),
                Email        = request.Email,
                Name         = request.Name,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
                Role         = finalRole2,
                CreatedAt    = DateTime.UtcNow,
                UpdatedAt    = DateTime.UtcNow
            };

            await _supabase.From<User>().Insert(user);

            // If they are an Artisan, create a blank artisan profile for them immediately
            if (user.Role == Souvenir_Collection_Backend.Enums.UserRole.Artisan)
            {
                var artisan = new Artisan
                {
                    UserId = user.Id,
                    DisplayName = user.Name
                };
                await _context.Artisans.AddAsync(artisan);
                await _context.SaveChangesAsync();
            }

            return new RegisterResponse
            {
                Id           = user.Id,
                AccessToken  = _tokenService.GenerateToken(user),
                RefreshToken = response.RefreshToken ?? "",
                Name         = user.Name,
                Email        = user.Email,
                Role         = user.Role
            };
        }

        public async Task<LoginResponse?> SignInAsync(LoginRequest request)
        {
            var response = await _supabase.Auth.SignInWithPassword(request.Email, request.Password);
            if (response?.User == null)
                return null;

            var userResult = await _supabase.From<User>()
                .Where(u => u.Email == request.Email)
                .Get();
            var user = userResult.Model;

            if (user == null)
            {
                user = new User
                {
                    Id           = Guid.Parse(response.User.Id),
                    Email        = request.Email,
                    Name         = response.User.UserMetadata != null && response.User.UserMetadata.ContainsKey("full_name")
                                    ? response.User.UserMetadata["full_name"]?.ToString() ?? "User"
                                    : "User",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
                    Role         = Souvenir_Collection_Backend.Enums.UserRole.Customer, // Default to Customer on auto-heal during login if not specified
                    CreatedAt    = DateTime.UtcNow,
                    UpdatedAt    = DateTime.UtcNow
                };

                await _supabase.From<User>().Insert(user);
            }

            return new LoginResponse
            {
                Id           = user.Id,
                AccessToken  = _tokenService.GenerateToken(user),
                RefreshToken = response.RefreshToken ?? "",
                Name         = user.Name,
                Email        = user.Email,
                Role         = user.Role.ToString()
            };
        }

        public async Task<LoginResponse?> GoogleLoginAsync(string supabaseAccessToken)
        {
            var supabaseUser = await GetSupabaseUserAsync(supabaseAccessToken);
            if (supabaseUser == null) return null;

            var userResult = await _supabase.From<User>()
                .Where(u => u.Email == supabaseUser.Email)
                .Get();
            var user = userResult.Model;

            if (user == null) return null;

            return new LoginResponse
            {
                Id           = user.Id,
                AccessToken  = _tokenService.GenerateToken(user),
                RefreshToken = string.Empty,
                Name         = user.Name,
                Email        = user.Email,
                Role         = user.Role.ToString()
            };
        }

        public async Task<RegisterResponse?> GoogleRegisterAsync(string supabaseAccessToken)
        {
            var supabaseUser = await GetSupabaseUserAsync(supabaseAccessToken);
            if (supabaseUser == null) return null;

            var userResult = await _supabase.From<User>()
                .Where(u => u.Email == supabaseUser.Email)
                .Get();

            if (userResult.Model != null) return null;

            var avatar = supabaseUser.UserMetadata?.ContainsKey("avatar_url") == true
                ? supabaseUser.UserMetadata["avatar_url"]?.ToString() ?? string.Empty
                : string.Empty;

            var name = supabaseUser.UserMetadata?.ContainsKey("full_name") == true
                ? supabaseUser.UserMetadata["full_name"]?.ToString() ?? supabaseUser.Email
                : supabaseUser.Email;

            var user = new User
            {
                Id           = Guid.Parse(supabaseUser.Id ?? Guid.NewGuid().ToString()),
                Email        = supabaseUser.Email!,
                Name         = name!,
                Avatar       = avatar,
                PasswordHash = string.Empty,
                Role         = UserRole.Customer,
                CreatedAt    = DateTime.UtcNow,
                UpdatedAt    = DateTime.UtcNow
            };

            await _supabase.From<User>().Insert(user);

            return new RegisterResponse
            {
                Id           = user.Id,
                AccessToken  = _tokenService.GenerateToken(user),
                RefreshToken = string.Empty,
                Name         = user.Name,
                Email        = user.Email,
                Role         = user.Role
            };
        }

        public async Task<User?> LogoutAsync(string userId)
        {
            if (!Guid.TryParse(userId, out var guid))
                return null;

            var userResult = await _supabase.From<User>()
                .Where(u => u.Id == guid)
                .Get();
            var user = userResult.Model;
            
            if (user == null)
            {
                return null;
            }

            await _supabase.Auth.SignOut();
            return user;
        }

        public async Task<LoginResponse?> VerifyOtpAsync(Sovenire_Collenction_Backend.DTOs.Auth.VerifyOtpRequest request)
        {
            var otpType = Supabase.Gotrue.Constants.EmailOtpType.Signup;
            if (!string.IsNullOrEmpty(request.Type))
            {
                Enum.TryParse(request.Type, true, out otpType);
            }

            var response = await _supabase.Auth.VerifyOTP(request.Email, request.Token, otpType);
            if (response?.User == null)
                return null;

            var userResult = await _supabase.From<User>()
                .Where(u => u.Email == request.Email)
                .Get();
            var user = userResult.Model;

            if (user == null)
            {
                user = new User
                {
                    Id           = Guid.Parse(response.User.Id),
                    Email        = request.Email,
                    Name         = response.User.UserMetadata != null && response.User.UserMetadata.ContainsKey("full_name")
                                    ? response.User.UserMetadata["full_name"]?.ToString() ?? "User"
                                    : "User",
                    PasswordHash = string.Empty,
                    Role         = Souvenir_Collection_Backend.Enums.UserRole.Customer,
                    CreatedAt    = DateTime.UtcNow,
                    UpdatedAt    = DateTime.UtcNow
                };

                await _supabase.From<User>().Insert(user);
            }

            return new LoginResponse
            {
                Id           = user.Id,
                AccessToken  = _tokenService.GenerateToken(user),
                RefreshToken = response.RefreshToken ?? "",
                Name         = user.Name,
                Email        = user.Email,
                Role         = user.Role.ToString()
            };
        }

        public async Task<Sovenire_Collenction_Backend.DTOs.Auth.RefreshTokenResponse?> RefreshTokenAsync(Sovenire_Collenction_Backend.DTOs.Auth.RefreshTokenRequest request)
        {
            await _supabase.Auth.SetSession(string.Empty, request.RefreshToken);
            var response = await _supabase.Auth.RefreshSession();
            if (response?.User == null || string.IsNullOrEmpty(response.User.Email))
                return null;

            var userResult = await _supabase.From<User>()
                .Where(u => u.Email == response.User.Email)
                .Get();
            var user = userResult.Model;

            if (user == null)
                return null;

            return new Sovenire_Collenction_Backend.DTOs.Auth.RefreshTokenResponse
            {
                AccessToken  = _tokenService.GenerateToken(user),
                RefreshToken = response.RefreshToken ?? ""
            };
        }

        private async Task<SupabaseUserResponse?> GetSupabaseUserAsync(string supabaseAccessToken)
        {
            var supabaseUrl = Environment.GetEnvironmentVariable("SUPABASE_URL");
            var supabaseKey = Environment.GetEnvironmentVariable("SUPABASE_KEY");

            var http = _httpClientFactory.CreateClient();
            http.DefaultRequestHeaders.Authorization =
                new AuthenticationHeaderValue("Bearer", supabaseAccessToken);
            http.DefaultRequestHeaders.Add("apikey", supabaseKey);

            var res = await http.GetAsync($"{supabaseUrl}/auth/v1/user");
            if (!res.IsSuccessStatusCode) return null;

            var supabaseUser = await res.Content.ReadFromJsonAsync<SupabaseUserResponse>();
            if (supabaseUser == null || string.IsNullOrEmpty(supabaseUser.Email)) return null;

            return supabaseUser;
        }
    }

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