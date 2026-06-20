using Microsoft.AspNetCore.Mvc;
using Sovenire_Collenction_Backend.Helpers;

namespace Sovenire_Collenction_Backend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ReviewsController : ControllerBase
    {
        private readonly ReviewService _reviewService;

        public ReviewsController(ReviewService reviewService)
        {
            _reviewService = reviewService;
        }

        // GET api/reviews
        [HttpGet]
        public async Task<IActionResult> GetAllReviews()
        {
            var reviews = await _reviewService.GetAllReviewsAsync() ?? new List<Review>();
            return Ok(ApiResponse<List<Review>>.SuccessResult(reviews, "Reviews retrieved successfully."));
        }

        // GET api/reviews/{id}
        [HttpGet("{id}")]
        public async Task<IActionResult> GetReviewById(Guid id)
        {
            var review = await _reviewService.GetReviewByIdAsync(id);
            if (review == null)
                return NotFound(ApiResponse<Review>.FailureResult($"Review with ID {id} not found."));

            return Ok(ApiResponse<Review>.SuccessResult(review, "Review details retrieved successfully."));
        }

        // GET api/reviews/product/{productId}
        [HttpGet("product/{productId}")]
        public async Task<IActionResult> GetReviewsByProduct(Guid productId)
        {
            var reviews = await _reviewService.GetReviewsByProductIdAsync(productId) ?? new List<Review>();
            return Ok(ApiResponse<List<Review>>.SuccessResult(reviews, "Reviews for product retrieved successfully."));
        }



        // GET api/reviews/user/{userId}
        [HttpGet("user/{userId}")]
        public async Task<IActionResult> GetReviewsByUser(Guid userId)
        {
            var reviews = await _reviewService.GetReviewsByUserIdAsync(userId) ?? new List<Review>();
            return Ok(ApiResponse<List<Review>>.SuccessResult(reviews, "Reviews by user retrieved successfully."));
        }

        // POST api/reviews
        [HttpPost]
        public async Task<IActionResult> CreateReview([FromBody] Review review)
        {
            if (!ModelState.IsValid)
                return BadRequest(ApiResponse<Review>.FailureResult("Invalid review payload."));

            var created = await _reviewService.CreateReviewAsync(review);
            var reloaded = await _reviewService.GetReviewByIdAsync(created.Id);
            if (reloaded == null)
                return BadRequest(ApiResponse<Review>.FailureResult("Failed to retrieve created review."));

            return CreatedAtAction(nameof(GetReviewById), new { id = created.Id }, ApiResponse<Review>.SuccessResult(reloaded, "Review submitted successfully."));
        }

        // PUT api/reviews/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateReview(Guid id, [FromBody] Review updated)
        {
            if (!ModelState.IsValid)
                return BadRequest(ApiResponse<Review>.FailureResult("Invalid review payload."));

            var review = await _reviewService.UpdateReviewAsync(id, updated);
            if (review == null)
                return NotFound(ApiResponse<Review>.FailureResult($"Review with ID {id} not found or update failed."));

            var reloaded = await _reviewService.GetReviewByIdAsync(id);
            if (reloaded == null)
                return NotFound(ApiResponse<Review>.FailureResult("Failed to retrieve updated review."));

            return Ok(ApiResponse<Review>.SuccessResult(reloaded, "Review updated successfully."));
        }

        // DELETE api/reviews/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteReview(Guid id)
        {
            var success = await _reviewService.DeleteReviewAsync(id);
            if (!success)
                return NotFound(ApiResponse<object>.FailureResult($"Review with ID {id} not found or delete failed."));

            return Ok(ApiResponse<object>.SuccessResult(new { id = id }, "Review deleted successfully."));
        }

        // GET api/reviews/product/{productId}/rating
        [HttpGet("product/{productId}/rating")]
        public async Task<IActionResult> GetAverageProductRating(Guid productId)
        {
            var rating = await _reviewService.GetAverageRatingByProductIdAsync(productId);
            return Ok(ApiResponse<double>.SuccessResult(rating, "Average product rating calculated."));
        }


    }
}
