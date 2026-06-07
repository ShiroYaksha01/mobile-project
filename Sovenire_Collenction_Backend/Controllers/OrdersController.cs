using Microsoft.AspNetCore.Mvc;
using Sovenire_Collenction_Backend.Helpers;

namespace Sovenire_Collenction_Backend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class OrdersController : ControllerBase
    {
        private readonly OrderService _orderService;

        public OrdersController(OrderService orderService)
        {
            _orderService = orderService;
        }

        // GET api/orders/user/{userId}
        [HttpGet("user/{userId}")]
        public async Task<IActionResult> GetUserOrders(Guid userId)
        {
            var orders = await _orderService.GetUserOrdersAsync(userId) ?? new List<Order>();
            var message = orders.Any() ? "Orders retrieved successfully." : $"No orders found for User ID {userId}.";
            return Ok(ApiResponse<List<Order>>.SuccessResult(orders, message));
        }

        // GET api/orders/{id}/user/{userId}
        [HttpGet("{id}/user/{userId}")]
        public async Task<IActionResult> GetOrderById(Guid id, Guid userId)
        {
            var order = await _orderService.GetOrderByIdAsync(id, userId);
            if (order == null)
                return NotFound(ApiResponse<Order>.FailureResult($"Order ID {id} not found for User ID {userId}."));

            return Ok(ApiResponse<Order>.SuccessResult(order, "Order details retrieved successfully."));
        }

        // POST api/orders/user/{userId}
        [HttpPost("user/{userId}")]
        public async Task<IActionResult> CreateOrder(Guid userId, [FromBody] CreateOrderRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ApiResponse<Order>.FailureResult("Invalid order payload."));

            var order = await _orderService.CreateOrderAsync(userId, request);
            if (order == null)
                return BadRequest(ApiResponse<Order>.FailureResult("Could not place order. Make sure stock is available and your cart is not empty."));

            return CreatedAtAction(nameof(GetOrderById), new { id = order.Id, userId = userId }, ApiResponse<Order>.SuccessResult(order, "Order placed successfully."));
        }

        // PUT api/orders/{id}/status
        [HttpPut("{id}/status")]
        public async Task<IActionResult> UpdateOrderStatus(Guid id, [FromQuery] OrderStatus status)
        {
            var success = await _orderService.UpdateOrderStatusAsync(id, status);
            if (!success)
                return NotFound(ApiResponse<object>.FailureResult($"Order with ID {id} not found or status update failed."));

            return Ok(ApiResponse<object>.SuccessResult(new { success = true, id = id }, "Order status updated successfully."));
        }

        // POST api/orders/{id}/cancel/user/{userId}
        [HttpPost("{id}/cancel/user/{userId}")]
        public async Task<IActionResult> CancelOrder(Guid id, Guid userId)
        {
            var success = await _orderService.CancelOrderAsync(id, userId);
            if (!success)
                return BadRequest(ApiResponse<object>.FailureResult($"Order with ID {id} not found, does not belong to user {userId}, or is no longer in 'Pending' status."));

            return Ok(ApiResponse<object>.SuccessResult(new { success = true, id = id }, "Order cancelled successfully."));
        }
    }
}
