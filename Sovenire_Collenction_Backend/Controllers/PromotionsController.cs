using Microsoft.AspNetCore.Mvc;
using Sovenire_Collenction_Backend.Helpers;

namespace Sovenire_Collenction_Backend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PromotionsController : ControllerBase
    {
        private readonly PromotionService _promotionService;

        public PromotionsController(PromotionService promotionService)
        {
            _promotionService = promotionService;
        }

        // GET api/promotions
        [HttpGet]
        public async Task<IActionResult> GetAllPromotions()
        {
            var promotions = await _promotionService.GetAllPromotionsAsync() ?? new List<Promotion>();
            return Ok(ApiResponse<List<Promotion>>.SuccessResult(promotions, "Promotions retrieved successfully."));
        }

        // GET api/promotions/{id}
        [HttpGet("{id}")]
        public async Task<IActionResult> GetPromotionById(Guid id)
        {
            var promotion = await _promotionService.GetPromotionByIdAsync(id);
            if (promotion == null)
                return NotFound(ApiResponse<Promotion>.FailureResult($"Promotion with ID {id} not found."));

            return Ok(ApiResponse<Promotion>.SuccessResult(promotion, "Promotion details retrieved successfully."));
        }

        // GET api/promotions/active
        [HttpGet("active")]
        public async Task<IActionResult> GetActivePromotions()
        {
            var promotions = await _promotionService.GetActivePromotionsAsync() ?? new List<Promotion>();
            return Ok(ApiResponse<List<Promotion>>.SuccessResult(promotions, "Active promotions retrieved successfully."));
        }

        // GET api/promotions/validate
        [HttpGet("validate")]
        public async Task<IActionResult> ValidatePromoCode([FromQuery] string code, [FromQuery] decimal subTotal)
        {
            if (string.IsNullOrEmpty(code))
                return BadRequest(ApiResponse<decimal>.FailureResult("Promo code cannot be empty."));

            var discount = await _promotionService.ValidatePromoCodeAsync(code, subTotal);
            if (discount <= 0)
                return BadRequest(ApiResponse<decimal>.FailureResult("Invalid, inactive, or expired promo code, or usage limit reached."));

            return Ok(ApiResponse<decimal>.SuccessResult(discount, "Promo code is valid. Discount calculated."));
        }

        // POST api/promotions
        [HttpPost]
        public async Task<IActionResult> CreatePromotion([FromBody] CreatePromotionRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ApiResponse<Promotion>.FailureResult("Invalid request payload."));

            var promotion = await _promotionService.CreatePromotionAsync(request);
            if (promotion == null)
                return BadRequest(ApiResponse<Promotion>.FailureResult("Failed to create promotion. Ensure the code is unique and dates are valid."));

            return CreatedAtAction(nameof(GetPromotionById), new { id = promotion.Id }, ApiResponse<Promotion>.SuccessResult(promotion, "Promotion created successfully."));
        }

        // PUT api/promotions/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdatePromotion(Guid id, [FromBody] UpdatePromotionRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ApiResponse<Promotion>.FailureResult("Invalid request payload."));

            var updatedPromotion = await _promotionService.UpdatePromotionAsync(id, request);
            if (updatedPromotion == null)
                return NotFound(ApiResponse<Promotion>.FailureResult($"Promotion with ID {id} not found or update failed."));

            return Ok(ApiResponse<Promotion>.SuccessResult(updatedPromotion, "Promotion updated successfully."));
        }

        // DELETE api/promotions/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeletePromotion(Guid id)
        {
            var success = await _promotionService.DeletePromotionAsync(id);
            if (!success)
                return NotFound(ApiResponse<object>.FailureResult($"Promotion with ID {id} not found or delete failed."));

            return Ok(ApiResponse<object>.SuccessResult(new { id = id }, "Promotion deleted successfully."));
        }

        // POST api/promotions/{id}/activate
        [HttpPost("{id}/activate")]
        public async Task<IActionResult> ActivatePromotion(Guid id)
        {
            var success = await _promotionService.ActivatePromotionAsync(id);
            if (!success)
                return BadRequest(ApiResponse<object>.FailureResult($"Could not activate promotion {id}. Ensure it exists and has not expired."));

            return Ok(ApiResponse<object>.SuccessResult(new { success = true, id = id }, "Promotion activated successfully."));
        }

        // POST api/promotions/{id}/deactivate
        [HttpPost("{id}/deactivate")]
        public async Task<IActionResult> DeactivatePromotion(Guid id)
        {
            var success = await _promotionService.DeactivatePromotionAsync(id);
            if (!success)
                return NotFound(ApiResponse<object>.FailureResult($"Promotion with ID {id} not found."));

            return Ok(ApiResponse<object>.SuccessResult(new { success = true, id = id }, "Promotion deactivated successfully."));
        }
    }
}
