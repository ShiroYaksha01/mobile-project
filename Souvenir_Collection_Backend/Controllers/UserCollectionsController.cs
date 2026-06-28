using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Souvenir_Collection_Backend.Models;
using Souvenir_Collection_Backend.Services;
using Sovenire_Collenction_Backend.Helpers;

namespace Souvenir_Collection_Backend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    // [Authorize] // Uncomment if we require JWT token everywhere, but typically we pass userId in route or query for this demo
    public class UserCollectionsController : ControllerBase
    {
        private readonly UserCollectionService _service;

        public UserCollectionsController(UserCollectionService service)
        {
            _service = service;
        }

        // GET api/usercollections/user/{userId}
        [HttpGet("user/{userId}")]
        public async Task<IActionResult> GetUserCollections(Guid userId)
        {
            var collections = await _service.GetUserCollectionsAsync(userId);
            return Ok(ApiResponse<List<UserCollection>>.SuccessResult(collections, "User collections retrieved."));
        }

        // POST api/usercollections/user/{userId}
        [HttpPost("user/{userId}")]
        public async Task<IActionResult> CreateCollection(Guid userId, [FromQuery] string name)
        {
            if (string.IsNullOrWhiteSpace(name))
                return BadRequest(ApiResponse<object>.FailureResult("Collection name is required."));

            var collection = await _service.CreateUserCollectionAsync(userId, name);
            return Ok(ApiResponse<UserCollection>.SuccessResult(collection, "Collection created."));
        }

        // DELETE api/usercollections/user/{userId}/collection/{collectionId}
        [HttpDelete("user/{userId}/collection/{collectionId}")]
        public async Task<IActionResult> DeleteCollection(Guid userId, Guid collectionId)
        {
            var success = await _service.DeleteUserCollectionAsync(userId, collectionId);
            if (!success) return NotFound(ApiResponse<object>.FailureResult("Collection not found."));

            return Ok(ApiResponse<object>.SuccessResult(null, "Collection deleted."));
        }

        // POST api/usercollections/user/{userId}/collection/{collectionId}/product/{productId}
        [HttpPost("user/{userId}/collection/{collectionId}/product/{productId}")]
        public async Task<IActionResult> AddOrUpdateItem(Guid userId, Guid collectionId, Guid productId, [FromQuery] int quantity = 1)
        {
            if (quantity < 1)
            {
                // If quantity < 1, remove it
                var remSuccess = await _service.RemoveItemAsync(userId, collectionId, productId);
                return Ok(ApiResponse<object>.SuccessResult(null, "Product removed from collection."));
            }

            var success = await _service.AddOrUpdateItemAsync(userId, collectionId, productId, quantity);
            if (!success) return NotFound(ApiResponse<object>.FailureResult("Collection not found."));

            return Ok(ApiResponse<object>.SuccessResult(null, "Product added/updated."));
        }

        // DELETE api/usercollections/user/{userId}/collection/{collectionId}/product/{productId}
        [HttpDelete("user/{userId}/collection/{collectionId}/product/{productId}")]
        public async Task<IActionResult> RemoveItem(Guid userId, Guid collectionId, Guid productId)
        {
            var success = await _service.RemoveItemAsync(userId, collectionId, productId);
            if (!success) return NotFound(ApiResponse<object>.FailureResult("Item not found."));

            return Ok(ApiResponse<object>.SuccessResult(null, "Product removed."));
        }
    }
}
