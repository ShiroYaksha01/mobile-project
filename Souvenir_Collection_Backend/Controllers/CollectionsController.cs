using Microsoft.AspNetCore.Mvc;
using Sovenire_Collenction_Backend.Helpers;

namespace Sovenire_Collenction_Backend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class CollectionsController : ControllerBase
    {
        private readonly CollectionService _collectionService;

        public CollectionsController(CollectionService collectionService)
        {
            _collectionService = collectionService;
        }

        // GET api/collections
        [HttpGet]
        public async Task<IActionResult> GetAllCollections([FromQuery] string sortOrder = "asc")
        {
            var collections = await _collectionService.GetAllCollectionsAsync(sortOrder) ?? new List<Collection>();
            return Ok(ApiResponse<List<Collection>>.SuccessResult(collections, "Collections retrieved successfully."));
        }

        // GET api/collections/{id}
        [HttpGet("{id}")]
        public async Task<IActionResult> GetCollectionById(Guid id)
        {
            var collection = await _collectionService.GetCollectionByIdAsync(id);
            if (collection == null)
                return NotFound(ApiResponse<Collection>.FailureResult($"Collection with ID {id} not found."));

            return Ok(ApiResponse<Collection>.SuccessResult(collection, "Collection details retrieved successfully."));
        }

        // GET api/collections/slug/{slug}
        [HttpGet("slug/{slug}")]
        public async Task<IActionResult> GetCollectionBySlug(string slug)
        {
            var collection = await _collectionService.GetCollectionBySlugAsync(slug);
            if (collection == null)
                return NotFound(ApiResponse<Collection>.FailureResult($"Collection with slug '{slug}' not found."));

            return Ok(ApiResponse<Collection>.SuccessResult(collection, "Collection details by slug retrieved successfully."));
        }

        // GET api/collections/type/{type}
        [HttpGet("type/{type}")]
        public async Task<IActionResult> GetCollectionsByType(string type, [FromQuery] string sortOrder = "asc")
        {
            var collections = await _collectionService.GetCollectionsByTypeAsync(type, sortOrder) ?? new List<Collection>();
            return Ok(ApiResponse<List<Collection>>.SuccessResult(collections, "Collections by type retrieved successfully."));
        }

        // POST api/collections
        [HttpPost]
        public async Task<IActionResult> CreateCollection([FromBody] CreateCollectionRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ApiResponse<Collection>.FailureResult("Invalid request payload."));

            var collection = await _collectionService.CreateCollectionAsync(request);
            if (collection == null)
                return BadRequest(ApiResponse<Collection>.FailureResult("Failed to create collection. The slug might already be in use."));

            return CreatedAtAction(nameof(GetCollectionById), new { id = collection.Id }, ApiResponse<Collection>.SuccessResult(collection, "Collection created successfully."));
        }

        // PUT/PATCH api/collections/{id}
        [HttpPut("{id}")]
        [HttpPatch("{id}")]
        public async Task<IActionResult> UpdateCollection(Guid id, [FromBody] UpdateCollectionRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ApiResponse<Collection>.FailureResult("Invalid request payload."));

            var collection = await _collectionService.UpdateCollectionAsync(id, request);
            if (collection == null)
                return NotFound(ApiResponse<Collection>.FailureResult($"Collection with ID {id} not found, or slug is already in use."));

            return Ok(ApiResponse<Collection>.SuccessResult(collection, "Collection updated successfully."));
        }

        // DELETE api/collections/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteCollection(Guid id)
        {
            var success = await _collectionService.DeleteCollectionAsync(id);
            if (!success)
                return NotFound(ApiResponse<object>.FailureResult($"Collection with ID {id} not found or delete failed."));

            return Ok(ApiResponse<object>.SuccessResult(new { id = id }, "Collection deleted successfully."));
        }

        // POST api/collections/{id}/products
        [HttpPost("{id}/products")]
        public async Task<IActionResult> AddProductToCollection(Guid id, [FromQuery] Guid productId)
        {
            var success = await _collectionService.AddProductToCollectionAsync(id, productId);
            if (!success)
                return BadRequest(ApiResponse<object>.FailureResult($"Failed to add product {productId} to collection {id}. Ensure both exist and are not already linked."));

            return Ok(ApiResponse<object>.SuccessResult(new { success = true, collectionId = id, productId = productId }, "Product added to collection successfully."));
        }

        // DELETE api/collections/{id}/products/{productId}
        [HttpDelete("{id}/products/{productId}")]
        public async Task<IActionResult> RemoveProductFromCollection(Guid id, Guid productId)
        {
            var success = await _collectionService.RemoveProductFromCollectionAsync(id, productId);
            if (!success)
                return NotFound(ApiResponse<object>.FailureResult($"Product {productId} in collection {id} not found or remove failed."));

            return Ok(ApiResponse<object>.SuccessResult(new { success = true, collectionId = id, productId = productId }, "Product removed from collection successfully."));
        }

        // GET api/collections/{id}/products
        [HttpGet("{id}/products")]
        public async Task<IActionResult> GetCollectionProducts(Guid id, [FromQuery] string sortOrder = "asc")
        {
            var products = await _collectionService.GetCollectionProductsAsync(id, sortOrder) ?? new List<Product>();
            return Ok(ApiResponse<List<Product>>.SuccessResult(products, "Collection products retrieved successfully."));
        }
    }
}
