using Microsoft.AspNetCore.Mvc;
using Souvenir_Collection_Backend.DTOs.Auth;
using Sovenire_Collenction_Backend.Helpers;

namespace Sovenire_Collenction_Backend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly AuthService _authService;

        public AuthController(AuthService authService)
        {
            _authService = authService;
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ApiResponse<RegisterResponse>.FailureResult("Invalid request body."));

            var response = await _authService.RegisterAsync(request);
            if (response == null)
                return BadRequest(ApiResponse<RegisterResponse>.FailureResult("Registration failed. The email may already be in use."));

            return Ok(ApiResponse<RegisterResponse>.SuccessResult(response, "User registered successfully."));
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ApiResponse<LoginResponse>.FailureResult("Invalid login payload."));

            var response = await _authService.SignInAsync(request);
            if (response == null)
                return BadRequest(ApiResponse<LoginResponse>.FailureResult("Invalid email or password."));

            return Ok(ApiResponse<LoginResponse>.SuccessResult(response, "Logged in successfully."));
        }

        [HttpPost("google/register")]
        public async Task<IActionResult> GoogleRegister([FromBody] GoogleLoginRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ApiResponse<RegisterResponse>.FailureResult("Invalid request payload."));

            var response = await _authService.GoogleRegisterAsync(request.AccessToken);
            if (response == null)
                return BadRequest(ApiResponse<RegisterResponse>.FailureResult("Registration failed. Account may already exist."));

            return Ok(ApiResponse<RegisterResponse>.SuccessResult(response, "Google registration successful."));
        }

        [HttpPost("google/login")]
        public async Task<IActionResult> GoogleLogin([FromBody] GoogleLoginRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ApiResponse<LoginResponse>.FailureResult("Invalid request payload."));

            var response = await _authService.GoogleLoginAsync(request.AccessToken);
            if (response == null)
                return Unauthorized(ApiResponse<LoginResponse>.FailureResult("Account not found. Please register first."));

            return Ok(ApiResponse<LoginResponse>.SuccessResult(response, "Google login successful."));
        }

        [HttpPost("logout/{userId}")]
        public async Task<IActionResult> Logout(string userId)
        {
            var user = await _authService.LogoutAsync(userId);
            if (user == null)
                return NotFound(ApiResponse<object>.FailureResult("User not found or already logged out."));

            return Ok(ApiResponse<object>.SuccessResult(new { success = true, userId = userId }, "Logged out successfully."));
        }

        [HttpPost("verify-otp")]
        public async Task<IActionResult> VerifyOtp([FromBody] Sovenire_Collenction_Backend.DTOs.Auth.VerifyOtpRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ApiResponse<LoginResponse>.FailureResult("Invalid request payload."));

            var response = await _authService.VerifyOtpAsync(request);
            if (response == null)
                return BadRequest(ApiResponse<LoginResponse>.FailureResult("OTP verification failed. Email/code may be incorrect or expired."));

            return Ok(ApiResponse<LoginResponse>.SuccessResult(response, "OTP verification successful."));
        }

        [HttpPost("refresh-token")]
        public async Task<IActionResult> RefreshToken([FromBody] Sovenire_Collenction_Backend.DTOs.Auth.RefreshTokenRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ApiResponse<Sovenire_Collenction_Backend.DTOs.Auth.RefreshTokenResponse>.FailureResult("Invalid request payload."));

            var response = await _authService.RefreshTokenAsync(request);
            if (response == null)
                return BadRequest(ApiResponse<Sovenire_Collenction_Backend.DTOs.Auth.RefreshTokenResponse>.FailureResult("Failed to refresh token. It may have expired or is invalid."));

            return Ok(ApiResponse<Sovenire_Collenction_Backend.DTOs.Auth.RefreshTokenResponse>.SuccessResult(response, "Token refreshed successfully."));
        }
    }
}