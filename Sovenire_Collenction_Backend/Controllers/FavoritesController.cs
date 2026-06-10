using Microsoft.AspNetCore.Mvc;
using Sovenire_Collenction_Backend.Helpers;
using Souvenir_Collection_Backend.Models;
using Souvenir_Collection_Backend.Services;

namespace Sovenire_Collenction_Backend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class FavoritesController : ControllerBase
    {
        private readonly FavoriteService _favoriteService;

        public FavoritesController(FavoriteService favoriteService)
        {
            _favoriteService = favoriteService;
        }

        // GET api/favorites/user/{userId}/products
        [HttpGet("user/{userId}/products")]
        public async Task<IActionResult> GetFavoriteProducts(Guid userId)
        {
            var favorites = await _favoriteService.GetFavoriteProductsAsync(userId) ?? new List<Favorite>();
            return Ok(ApiResponse<List<Favorite>>.SuccessResult(favorites, "Favorite products retrieved successfully."));
        }

        // GET api/favorites/user/{userId}/collections
        [HttpGet("user/{userId}/collections")]
        public async Task<IActionResult> GetFavoriteCollections(Guid userId)
        {
            var favorites = await _favoriteService.GetFavoriteCollectionsAsync(userId) ?? new List<Favorite>();
            return Ok(ApiResponse<List<Favorite>>.SuccessResult(favorites, "Favorite collections retrieved successfully."));
        }

        // POST api/favorites
        [HttpPost]
        public async Task<IActionResult> AddFavorite([FromBody] Favorite request)
        {
            try
            {
                if (request.ProductId != null)
                {
                    var favorite = await _favoriteService.AddFavoriteProductAsync(request.UserId, request.ProductId.Value);
                    return Ok(ApiResponse<Favorite>.SuccessResult(favorite, "Product added to favorites successfully."));
                }
                else if (request.CollectionId != null)
                {
                    var favorite = await _favoriteService.AddFavoriteCollectionAsync(request.UserId, request.CollectionId.Value);
                    return Ok(ApiResponse<Favorite>.SuccessResult(favorite, "Collection added to favorites successfully."));
                }

                return BadRequest(ApiResponse<Favorite>.FailureResult("Payload must contain either a valid ProductId or CollectionId."));
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ApiResponse<Favorite>.FailureResult(ex.Message));
            }
        }

        // POST api/favorites/user/{userId}/product/{productId}
        [HttpPost("user/{userId}/product/{productId}")]
        public async Task<IActionResult> AddFavoriteProduct(Guid userId, Guid productId)
        {
            try
            {
                var favorite = await _favoriteService.AddFavoriteProductAsync(userId, productId);
                return Ok(ApiResponse<Favorite>.SuccessResult(favorite, "Product added to favorites successfully."));
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ApiResponse<Favorite>.FailureResult(ex.Message));
            }
        }

        // POST api/favorites/user/{userId}/collection/{collectionId}
        [HttpPost("user/{userId}/collection/{collectionId}")]
        public async Task<IActionResult> AddFavoriteCollection(Guid userId, Guid collectionId)
        {
            try
            {
                var favorite = await _favoriteService.AddFavoriteCollectionAsync(userId, collectionId);
                return Ok(ApiResponse<Favorite>.SuccessResult(favorite, "Collection added to favorites successfully."));
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ApiResponse<Favorite>.FailureResult(ex.Message));
            }
        }


        // GET api/favorites/user/{userId}/product/{productId}/check
        [HttpGet("user/{userId}/product/{productId}/check")]
        public async Task<IActionResult> IsProductFavorited(Guid userId, Guid productId)
        {
            var favorited = await _favoriteService.IsProductFavoritedAsync(userId, productId);
            return Ok(ApiResponse<object>.SuccessResult(new { favorited = favorited }, "Product favorite check completed."));
        }

        // GET api/favorites/user/{userId}/collection/{collectionId}/check
        [HttpGet("user/{userId}/collection/{collectionId}/check")]
        public async Task<IActionResult> IsCollectionFavorited(Guid userId, Guid collectionId)
        {
            var favorited = await _favoriteService.IsCollectionFavoritedAsync(userId, collectionId);
            return Ok(ApiResponse<object>.SuccessResult(new { favorited = favorited }, "Collection favorite check completed."));
        }

        // PATCH api/favorites/user/{userId}/product/{productId}/toggle
        [HttpPatch("user/{userId}/product/{productId}/toggle")]
        public async Task<IActionResult> ToggleFavoriteProduct(Guid userId, Guid productId)
        {
            try
            {
                var (isFavorited, favorite) = await _favoriteService.ToggleFavoriteProductAsync(userId, productId);
                var message = isFavorited
                    ? "Product added to favorites."
                    : "Product removed from favorites.";

                var result = new
                {
                    isFavorited,
                    favorite
                };

                return Ok(ApiResponse<object>.SuccessResult(result, message));
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ApiResponse<object>.FailureResult(ex.Message));
            }
        }
    }
}
