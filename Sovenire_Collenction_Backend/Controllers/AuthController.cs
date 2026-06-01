using Microsoft.AspNetCore.Mvc;
using Souvenir_Collection_Backend.DTOs.Auth;

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
            {
                return BadRequest(ModelState);
            }

            var response = await _authService.RegisterAsync(request);
            if (response == null)
            {
                return BadRequest(new { message = "Registration failed. The email may already be in use or the request was invalid." });
            }

            return Ok(response);
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var response = await _authService.SignInAsync(request);
            if (response == null)
            {
                return BadRequest(new { message = "Invalid email or password." });
            }

            return Ok(response);
        }

        [HttpPost("google")]
        public async Task<IActionResult> GoogleLogin([FromBody] GoogleLoginRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var response = await _authService.GoogleLoginAsync(request.AccessToken);
            if (response == null)
                return Unauthorized(new { message = "Google token is invalid or expired. Please sign in again." });

            return Ok(response);
        }
    }
}
