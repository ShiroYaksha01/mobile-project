namespace Souvenir_Collection_Backend.Services
{
    public class OrderService
    {
        private readonly AppDbContext _context;

        public OrderService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<List<Order>> GetUserOrdersAsync(Guid userId)
        {
            return await _context.Orders
                .Include(o => o.OrderItems)
                    .ThenInclude(oi => oi.Product)
                .Include(o => o.Payment)
                .Include(o => o.Promotion)
                .Where(o => o.UserId == userId)
                .OrderByDescending(o => o.CreatedAt)
                .ToListAsync();
        }

        public async Task<Order> GetOrderByIdAsync(Guid orderId, Guid userId)
        {
            return await _context.Orders
                .Include(o => o.OrderItems)
                    .ThenInclude(oi => oi.Product)
                .Include(o => o.Payment)
                .Include(o => o.Promotion)
                .FirstOrDefaultAsync(o => o.Id == orderId && o.UserId == userId);
        }

        public async Task<Order> CreateOrderAsync(Guid userId, CreateOrderRequest request)
        {
            var cartItems = await _context.CartItems
                .Include(c => c.Product)
                .Where(c => c.UserId == userId)
                .ToListAsync();

            if (!cartItems.Any()) return null;

            foreach (var item in cartItems)
            {
                if (item.Product.Stock < item.Quantity) return null;
            }

            var subTotal = cartItems.Sum(c => c.Product.Price * c.Quantity);

            decimal discountAmount = 0;
            if (request.PromotionId.HasValue)
            {
                var promotion = await _context.Promotions
                    .FirstOrDefaultAsync(p => p.Id == request.PromotionId &&
                                             p.IsActive &&
                                             p.StartDate <= DateTime.UtcNow &&
                                             p.EndDate >= DateTime.UtcNow);
                if (promotion != null)
                {
                    discountAmount = promotion.DiscountType == "percentage"
                        ? subTotal * (promotion.DiscountValue / 100)
                        : promotion.DiscountValue;

                    promotion.TimesUsed += 1;
                }
            }

            var grandTotal = subTotal - discountAmount;

            var order = new Order
            {
                UserId          = userId,
                Status          = OrderStatus.Pending,
                SubTotal        = subTotal,
                DiscountAmount  = discountAmount,
                GrandTotal      = grandTotal,
                PaymentMethod   = request.PaymentMethod,
                DeliveryAddress = request.DeliveryAddress,
                DeliveryMessage = request.DeliveryMessage,
                DeliveryDate    = request.DeliveryDate,
                PromotionId     = request.PromotionId,
                CreatedAt       = DateTime.UtcNow,
                UpdatedAt       = DateTime.UtcNow
            };

            await _context.Orders.AddAsync(order);

            foreach (var item in cartItems)
            {
                var orderItem = new OrderItem
                {
                    OrderId   = order.Id,
                    ProductId = item.ProductId,
                    Quantity  = item.Quantity,
                    Price     = item.Product.Price,
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                };

                await _context.OrderItems.AddAsync(orderItem);

                item.Product.Stock -= item.Quantity;
            }

            _context.CartItems.RemoveRange(cartItems);

            await _context.SaveChangesAsync();
            return order;
        }

        public async Task<bool> UpdateOrderStatusAsync(Guid orderId, OrderStatus status)
        {
            var order = await _context.Orders.FindAsync(orderId);
            if (order == null) return false;

            order.Status    = status;
            order.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> CancelOrderAsync(Guid orderId, Guid userId)
        {
            var order = await _context.Orders
                .Include(o => o.OrderItems)
                    .ThenInclude(oi => oi.Product)
                .FirstOrDefaultAsync(o => o.Id == orderId && o.UserId == userId);

            if (order == null) return false;

            if (order.Status != OrderStatus.Pending) return false;

            order.Status    = OrderStatus.Cancelled;
            order.UpdatedAt = DateTime.UtcNow;

            foreach (var item in order.OrderItems)
            {
                item.Product.Stock += item.Quantity;
            }

            await _context.SaveChangesAsync();
            return true;
        }
    }
}