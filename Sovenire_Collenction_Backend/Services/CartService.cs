using Souvenir.Backend.Models;

namespace Sovenire_Collenction_Backend.Services
{
    public class CartService
    {
        private readonly AppDbContext _context;

        public CartService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<List<CartItem>> GetCartItemAsync(Guid userId)
        {
            return await _context.CartItems
                .Include(c => c.Product)
                .Include(c => c.User)
                .Where(c => c.UserId == userId)
                .ToListAsync();
        }

        public async Task<CartItem?> AddCartItemAsync(Guid userId, Guid productId, int quantity)
        {
            var productExists = await _context.Products.AnyAsync(p => p.Id == productId);
            if (!productExists) return null;

            var existingItem = await _context.CartItems
                .FirstOrDefaultAsync(c => c.UserId == userId && c.ProductId == productId);

            if (existingItem != null)
            {
                existingItem.Quantity += quantity;
            }
            else
            {
                existingItem = new CartItem
                {
                    UserId    = userId,
                    ProductId = productId,
                    Quantity  = quantity,
                    AddedAt   = DateTime.UtcNow
                };
                await _context.CartItems.AddAsync(existingItem);
            }

            await _context.SaveChangesAsync();
            return existingItem;
        }

        public async Task<bool> UpdateCartItemQuantityAsync(Guid userId, Guid productId, int quantity)
        {
            if (quantity <= 0)
            {
                return await RemoveCartItemAsync(userId, productId);
            }

            var item = await _context.CartItems
                .FirstOrDefaultAsync(c => c.UserId == userId && c.ProductId == productId);

            if (item == null) return false;

            item.Quantity = quantity;
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> RemoveCartItemAsync(Guid userId, Guid productId)
        {
            var item = await _context.CartItems
                .FirstOrDefaultAsync(c => c.UserId == userId && c.ProductId == productId);

            if (item == null) return false;

            _context.CartItems.Remove(item);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> ClearCartAsync(Guid userId)
        {
            var items = await _context.CartItems
                .Where(c => c.UserId == userId)
                .ToListAsync();

            if (!items.Any()) return false;

            _context.CartItems.RemoveRange(items);
            await _context.SaveChangesAsync();
            return true;
        }
    }
}