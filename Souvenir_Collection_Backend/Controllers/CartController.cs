using Microsoft.AspNetCore.Mvc;
using Souvenir.Backend.Models;
using Sovenire_Collenction_Backend.Helpers;

namespace Sovenire_Collenction_Backend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class CartController : ControllerBase
    {
        private readonly CartService _cartService;

        public CartController(CartService cartService)
        {
            _cartService = cartService;
        }

        // GET api/cart/user/{userId}
        [HttpGet("user/{userId}")]
        public async Task<IActionResult> GetCartItems(Guid userId)
        {
            var items = await _cartService.GetCartItemAsync(userId) ?? new List<CartItem>();
            var message = items.Any() ? "Cart items retrieved successfully." : $"No cart items found for user {userId}.";
            return Ok(ApiResponse<List<CartItem>>.SuccessResult(items, message));
        }

        // POST api/cart/user/{userId}
        [HttpPost("user/{userId}")]
        public async Task<IActionResult> AddCartItem(Guid userId, [FromQuery] Guid productId, [FromQuery] int quantity)
        {
            if (quantity <= 0)
                return BadRequest(ApiResponse<CartItem>.FailureResult("Quantity must be greater than zero."));

            var item = await _cartService.AddCartItemAsync(userId, productId, quantity);
            if (item == null)
                return BadRequest(ApiResponse<CartItem>.FailureResult($"Failed to add product {productId} to cart. Ensure product exists."));

            return Ok(ApiResponse<CartItem>.SuccessResult(item, "Product added to cart successfully."));
        }

        // PUT api/cart/user/{userId}/item/{productId}
        [HttpPut("user/{userId}/item/{productId}")]
        public async Task<IActionResult> UpdateCartItemQuantity(Guid userId, Guid productId, [FromQuery] int quantity)
        {
            var success = await _cartService.UpdateCartItemQuantityAsync(userId, productId, quantity);
            if (!success)
                return NotFound(ApiResponse<List<CartItem>>.FailureResult($"Product {productId} in cart for user {userId} not found or update failed."));

            var items = await _cartService.GetCartItemAsync(userId) ?? new List<CartItem>();
            return Ok(ApiResponse<List<CartItem>>.SuccessResult(items, "Cart item quantity updated successfully."));
        }

        // DELETE api/cart/user/{userId}/item/{productId}
        [HttpDelete("user/{userId}/item/{productId}")]
        public async Task<IActionResult> RemoveCartItem(Guid userId, Guid productId)
        {
            var success = await _cartService.RemoveCartItemAsync(userId, productId);
            if (!success)
                return NotFound(ApiResponse<List<CartItem>>.FailureResult($"Product {productId} in cart for user {userId} not found or remove failed."));

            var items = await _cartService.GetCartItemAsync(userId) ?? new List<CartItem>();
            return Ok(ApiResponse<List<CartItem>>.SuccessResult(items, "Product removed from cart successfully."));
        }

        // DELETE api/cart/user/{userId}/clear
        [HttpDelete("user/{userId}/clear")]
        public async Task<IActionResult> ClearCart(Guid userId)
        {
            var success = await _cartService.ClearCartAsync(userId);
            if (!success)
                return NotFound(ApiResponse<List<CartItem>>.FailureResult($"Failed to clear cart for user {userId}. The cart might already be empty."));

            var items = new List<CartItem>();
            return Ok(ApiResponse<List<CartItem>>.SuccessResult(items, "Cart cleared successfully."));
        }
    }
}
