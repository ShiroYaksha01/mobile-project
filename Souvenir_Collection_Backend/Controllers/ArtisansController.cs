using Microsoft.AspNetCore.Mvc;
using Sovenire_Collenction_Backend.Helpers;
using Sovenire_Collenction_Backend.DTOs.Artisan;
using Sovenire_Collenction_Backend.DTOs.Product;
using Sovenire_Collenction_Backend.DTOs.Order;
using Sovenire_Collenction_Backend.DTOs.Review;
using Sovenire_Collenction_Backend.DTOs.User;

namespace Sovenire_Collenction_Backend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ArtisansController : ControllerBase
    {
        private readonly ArtisanService _artisanService;

        public ArtisansController(ArtisanService artisanService)
        {
            _artisanService = artisanService;
        }

        private static UserDto MapToUserDto(User user) => new()
        {
            Id = user.Id,
            Name = user.Name,
            Email = user.Email,
            Role = user.Role.ToString(),
            Phone = user.Phone,
            Address = user.Address,
            Avatar = user.Avatar,
            CreatedAt = user.CreatedAt,
            UpdatedAt = user.UpdatedAt
        };

        private static ArtisanDto MapToArtisanDto(Artisan a) => new()
        {
            Id = a.Id,
            DisplayName = a.DisplayName,
            Region = a.Region,
            CraftType = a.CraftType,
            Bio = a.Bio,
            ProfilePhotoUrl = a.ProfilePhotoUrl,
            ShopAddress = a.ShopAddress,
            Lat = a.Lat,
            Lng = a.Lng,
            IsVerified = a.IsVerified,
            CreatedAt = a.CreatedAt,
            UpdatedAt = a.UpdatedAt
        };

        private static ProductDto MapToProductDto(Product p) => new()
        {
            Id = p.Id,
            ArtisanId = p.ArtisanId,
            CategoryId = p.CategoryId,
            CollectionId = p.CollectionId,
            Name = p.Name,
            Description = p.Description,
            Price = p.Price,
            StockQty = p.StockQty,
            Image = p.Image,
            IsAvailable = p.IsAvailable,
            CreatedAt = p.CreatedAt,
            UpdatedAt = p.UpdatedAt
        };

        private static OrderItemDto MapToOrderItemDto(OrderItem oi) => new()
        {
            Id = oi.Id,
            OrderId = oi.OrderId,
            ProductId = oi.ProductId,
            ProductName = oi.Product?.Name ?? string.Empty,
            ProductImage = oi.Product?.Image ?? string.Empty,
            Quantity = oi.Quantity,
            UnitPrice = oi.UnitPrice,
            TotalPrice = oi.TotalPrice,
            Status = oi.Status.ToString(),
            UpdatedAt = oi.UpdatedAt
        };

        private static OrderDto MapToOrderDto(Order o) => new()
        {
            Id = o.Id,
            UserId = o.UserId,
            Status = o.Status.ToString(),
            SubTotal = o.SubTotal,
            DiscountAmount = o.DiscountAmount,
            GrandTotal = o.GrandTotal,
            PaymentMethod = o.PaymentMethod,
            DeliveryAddress = o.DeliveryAddress,
            DeliveryMessage = o.DeliveryMessage,
            DeliveryDate = o.DeliveryDate,
            PromotionId = o.PromotionId,
            PromotionCode = o.Promotion?.Code ?? string.Empty,
            CreatedAt = o.CreatedAt,
            UpdatedAt = o.UpdatedAt,
            OrderItems = o.OrderItems?.Select(MapToOrderItemDto).ToList() ?? new List<OrderItemDto>()
        };

        private static ReviewDto MapToReviewDto(Review r) => new()
        {
            Id = r.Id,
            UserId = r.UserId,
            UserName = r.User?.Name ?? string.Empty,
            UserAvatar = r.User?.Avatar ?? string.Empty,
            ProductId = r.ProductId,
            ProductName = r.Product?.Name ?? string.Empty,
            ReviewText = r.ReviewText ?? string.Empty,
            Rating = r.Rating,
            Image = r.Image,
            CreatedAt = r.CreatedAt,
            UpdatedAt = r.UpdatedAt
        };

        // 1. GET api/artisans
        [HttpGet]
        
        public async Task<IActionResult> GetAllArtisans()
        {
            var artisans = await _artisanService.GetAllArtisanAsync() ?? new List<Artisan>();
            var dtos = artisans.Select(MapToArtisanDto).ToList();
            return Ok(ApiResponse<List<ArtisanDto>>.SuccessResult(dtos, "Artisans retrieved successfully."));
        }

        [HttpPost]
        public async Task<IActionResult> CreateArtisan([FromBody] CreateArtisanRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ApiResponse<ArtisanDto>.FailureResult("Invalid request payload."));

            var artisan = await _artisanService.CreateArtisanAsync(request);
            if (artisan == null)
                return BadRequest(ApiResponse<ArtisanDto>.FailureResult("Failed to create artisan."));

            return CreatedAtAction(nameof(GetArtisanById), new { id = artisan.Id }, ApiResponse<ArtisanDto>.SuccessResult(MapToArtisanDto(artisan), "Artisan profile created successfully."));
        }

        // 2. GET api/artisans/{id}
        [HttpGet("{id}")]
        public async Task<IActionResult> GetArtisanById(Guid id)
        {
            var artisan = await _artisanService.GetArtisanByIdAsync(id);
            if (artisan == null)
                return NotFound(ApiResponse<ArtisanDto>.FailureResult($"Artisan with ID {id} not found."));

            return Ok(ApiResponse<ArtisanDto>.SuccessResult(MapToArtisanDto(artisan), "Artisan details retrieved successfully."));
        }

        // 3. POST api/artisans/{id}/verify
        [HttpPost("{id}/verify")]
        public async Task<IActionResult> VerifyArtisan(Guid id)
        {
            var artisan = await _artisanService.VerifyArtisanAsync(id);
            if (artisan == null)
                return NotFound(ApiResponse<ArtisanDto>.FailureResult($"Could not verify artisan with ID {id}."));

            return Ok(ApiResponse<ArtisanDto>.SuccessResult(MapToArtisanDto(artisan), "Artisan verified successfully."));
        }

        // 4. POST api/artisans/{id}/unverify
        [HttpPost("{id}/unverify")]
        public async Task<IActionResult> UnverifyArtisan(Guid id)
        {
            var artisan = await _artisanService.UnverifyArtisanAsync(id);
            if (artisan == null)
                return NotFound(ApiResponse<ArtisanDto>.FailureResult($"Could not unverify artisan with ID {id}."));

            return Ok(ApiResponse<ArtisanDto>.SuccessResult(MapToArtisanDto(artisan), "Artisan unverified successfully."));
        }

        // 5. GET api/artisans/{id}/profile
        [HttpGet("{id}/profile")]
        public async Task<IActionResult> GetArtisanProfile(Guid id)
        {
            var artisan = await _artisanService.GetArtisanProfileAsync(id);
            if (artisan == null)
                return NotFound(ApiResponse<ArtisanDto>.FailureResult($"Profile for Artisan with ID {id} not found."));

            return Ok(ApiResponse<ArtisanDto>.SuccessResult(MapToArtisanDto(artisan), "Artisan profile retrieved successfully."));
        }

        // 6. PATCH api/artisans/{id}/profile
        [HttpPatch("{id}/profile")]
        public async Task<IActionResult> UpdateArtisanProfile(Guid id, [FromBody] UpdateArtisanProfileRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ApiResponse<ArtisanDto>.FailureResult("Invalid request payload."));

            var artisan = await _artisanService.UpdateArtisanProfileAsync(id, request);
            if (artisan == null)
                return NotFound(ApiResponse<ArtisanDto>.FailureResult($"Could not update profile for Artisan with ID {id}."));

            var dto = MapToArtisanDto(artisan);
            return Ok(ApiResponse<ArtisanDto>.SuccessResult(dto, "Artisan profile updated successfully."));
        }

        // 6b. PATCH api/artisans/{id}
        [HttpPatch("{id}")]
        public async Task<IActionResult> UpdateArtisan(Guid id, [FromBody] UpdateArtisanRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ApiResponse<ArtisanDto>.FailureResult("Invalid request payload."));

            var artisan = await _artisanService.UpdateArtisanAsync(id, request);
            if (artisan == null)
                return NotFound(ApiResponse<ArtisanDto>.FailureResult($"Could not update Artisan with ID {id}."));

            var dto = MapToArtisanDto(artisan);
            return Ok(ApiResponse<ArtisanDto>.SuccessResult(dto, "Artisan updated successfully."));
        }


        // 11. GET api/artisans/{id}/orders
        [HttpGet("{id}/orders")]
        public async Task<IActionResult> GetMyOrders(Guid id)
        {
            var orders = await _artisanService.GetMyOrdersAsync(id) ?? new List<Order>();
            var dtos = orders.Select(MapToOrderDto).ToList();
            return Ok(ApiResponse<List<OrderDto>>.SuccessResult(dtos, "Artisan orders retrieved successfully."));
        }

        // 12. PUT api/artisans/{id}/orders/{orderItemId}/status
        [HttpPut("{id}/orders/{orderItemId}/status")]
        public async Task<IActionResult> UpdateOrderItemStatus(Guid id, Guid orderItemId, [FromQuery] OrderItemStatus status)
        {
            var success = await _artisanService.UpdateOrderItemStatusAsync(id, orderItemId, status);
            if (!success)
                return NotFound(ApiResponse<object>.FailureResult($"OrderItem with ID {orderItemId} for Artisan {id} not found or status update failed."));

            return Ok(ApiResponse<object>.SuccessResult(new { success = true }, "Order item status updated successfully."));
        }

        // 13. GET api/artisans/{id}/dashboard
        [HttpGet("{id}/dashboard")]
        public async Task<IActionResult> GetArtisanDashboard(Guid id)
        {
            var dashboard = await _artisanService.GetArtisanDashboardAsync(id);
            if (dashboard == null)
                return NotFound(ApiResponse<ArtisanDashboardDto>.FailureResult($"Dashboard for Artisan with ID {id} not found."));

            return Ok(ApiResponse<ArtisanDashboardDto>.SuccessResult(dashboard, "Artisan dashboard stats retrieved successfully."));
        }

        // 14. GET api/artisans/{id}/reviews
        [HttpGet("{id}/reviews")]
        public async Task<IActionResult> GetMyReviews(Guid id)
        {
            var reviews = await _artisanService.GetMyReviewsAsync(id) ?? new List<Review>();
            var dtos = reviews.Select(MapToReviewDto).ToList();
            return Ok(ApiResponse<List<ReviewDto>>.SuccessResult(dtos, "Artisan reviews retrieved successfully."));
        }

        // 15. DELETE api/artisans/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteArtisan(Guid id)
        {
            var success = await _artisanService.DeleteArtisanAsync(id);
            if (!success)
                return NotFound(ApiResponse<object>.FailureResult($"Artisan with ID {id} not found or delete failed."));

            return Ok(ApiResponse<object>.SuccessResult(new { id = id }, "Artisan deleted successfully."));
        }
    }
}