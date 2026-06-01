namespace Sovenire_Collenction_Backend.Services
{
    public class CartService {
        private readonly AppDbContext _context;

        public CartService(AppDbContext context)
        {
            _context = context;
        }
        public async Task<List<CartItem>> GetCartItemAsync(Guid userId)
        {
            return await _context.CartItems
            .Include(c=>c.product)
            .Include(u=>u.user)
            .Where(c=>c.userId==userId)
            .ToListAsync();
        }
        public async Task<CartItem> AddCartItemAsync(Guid userId, Guid productId, int quantity)
        {
            
        }
    }
}