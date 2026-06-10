using Microsoft.AspNetCore.Mvc;
using Sovenire_Collenction_Backend.Helpers;

namespace Sovenire_Collenction_Backend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class MapController : ControllerBase
    {
        private readonly AppDbContext _context;

        public MapController(AppDbContext context)
        {
            _context = context;
        }

        // GET api/map/branches
        [HttpGet("branches")]
        public async Task<IActionResult> GetBranches()
        {
            var branches = await _context.Artisans
                .Where(a => a.IsVerified)
                .Select(a => new
                {
                    a.Id,
                    ShopName = a.DisplayName,
                    Address = a.ShopAddress,
                    a.Lat,
                    a.Lng,
                    a.CraftType
                })
                .ToListAsync();

            return Ok(ApiResponse<object>.SuccessResult(branches, "Map branches retrieved successfully."));
        }
    }
}
