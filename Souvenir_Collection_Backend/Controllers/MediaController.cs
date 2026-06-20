using Microsoft.AspNetCore.Mvc;
using Supabase;
using Sovenire_Collenction_Backend.Helpers;

namespace Sovenire_Collenction_Backend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class MediaController : ControllerBase
    {
        private readonly Client _supabase;

        public MediaController(Client supabase)
        {
            _supabase = supabase;
        }

        // POST api/media/upload
        [HttpPost("upload")]
        public async Task<IActionResult> UploadFile(IFormFile file)
        {
            if (file == null || file.Length == 0)
                return BadRequest(ApiResponse<object>.FailureResult("No file uploaded."));

            try
            {
                var extension = Path.GetExtension(file.FileName);
                var fileName = $"{Guid.NewGuid()}{extension}";

                using var stream = file.OpenReadStream();
                using var ms = new MemoryStream();
                await stream.CopyToAsync(ms);
                var fileBytes = ms.ToArray();

                // Upload to Supabase Storage bucket "media"
                await _supabase.Storage
                    .From("media")
                    .Upload(fileBytes, fileName, new Supabase.Storage.FileOptions { ContentType = file.ContentType });

                // Get public URL
                var publicUrl = _supabase.Storage
                    .From("media")
                    .GetPublicUrl(fileName);

                return Ok(ApiResponse<object>.SuccessResult(new { url = publicUrl }, "File uploaded successfully."));
            }
            catch (Exception ex)
            {
                return StatusCode(500, ApiResponse<object>.FailureResult($"File upload failed: {ex.Message}"));
            }
        }
    }
}
