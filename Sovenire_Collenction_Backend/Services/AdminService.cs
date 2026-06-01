namespace Souvenir_Collection_Backend.Services
{
    public class AdminService
    {
        private readonly AppDbContext _context;

        public AdminService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<DashboardStatDto> GetDashboardsState()
        {
            var totalUsers = await _context.Users.CountAsync(u => u.Role == UserRole.Customer);

            var totalArtisans = await _context.Artisans
                .CountAsync();

            var totalProducts = await _context.Products
                .CountAsync();

            var totalOrders = await _context.Orders
                .CountAsync();

            var pendingOrders = await _context.Orders
                .CountAsync(o => o.Status == OrderStatus.Pending);

            var totalRevenue = await _context.Payments
                .Where(p => p.Status == PaymentStatus.Success)
                .SumAsync(p => p.Amount);

            var totalReviews = await _context.Reviews
                .CountAsync();

            return new DashboardStatDto
            {
                TotalUsers    = totalUsers,
                TotalArtisans = totalArtisans,
                TotalProducts = totalProducts,
                TotalOrders   = totalOrders,
                PendingOrders = pendingOrders,
                TotalRevenue  = totalRevenue,
                TotalReviews  = totalReviews
            };
        }

        public async Task<List<User>> GetAllUserAsync()
        {
            return await _context.Users
                .Where(u => u.Role == UserRole.Customer)
                .ToListAsync();
        }

        public async Task<bool> BanUserAsync(Guid userId)
        {
            var user = await _context.Users.FindAsync(userId);
            if (user == null) return false;

            user.IsBanned = true;
            user.BannedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> UnbanUserAsync(Guid userId)
        {
            var user = await _context.Users.FindAsync(userId);
            if (user == null) return false;

            user.IsBanned = false;
            user.BannedAt = null;

            await _context.SaveChangesAsync();
            return true;
        }


        public async Task<List<Artisan>> GetAllArtisanAsync()
        {
            return await _context.Artisans
                .Include(a => a.User)
                .Include(a => a.Products)
                .ToListAsync();
        }


        public async Task<Artisan> GetArtisanByIdAsync(Guid artisanId)
        {
            return await _context.Artisans
                .Include(a => a.User)
                .Include(a => a.Products)
                .FirstOrDefaultAsync(a => a.Id == artisanId);
        }


        public async Task<bool> VerifyArtisanAsync(Guid artisanId)
        {
            var artisan = await _context.Artisans.FindAsync(artisanId);
            if (artisan == null) return false;

            artisan.IsVerified = true;
            artisan.VerifiedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<List<Product>> GetAllProductAsync()
        {
            return await _context.Products
                .Include(p => p.Collection)
                .Include(p => p.Artisan)
                .OrderByDescending(p => p.CreatedAt)
                .ToListAsync();
        }

        public async Task<Product> GetProductByIdAsync(Guid productId)
        {
            return await _context.Products
                .Include(p => p.Collection)
                .Include(p => p.Artisan)
                .FirstOrDefaultAsync(p => p.Id == productId);
        }

        public async Task<List<Category>> GetAllCategoryAsync()
        {
            return await _context.Categories
                .Include(c => c.Collection)
                .Include(c => c.Products)
                .OrderByDescending(c => c.CreatedAt)
                .ToListAsync();
        }

        public async Task<Category> GetCategoryByIdAsync(Guid categoryId)
        {
            return await _context.Categories
                .Include(c => c.Collection)
                .Include(c => c.Products)
                .FirstOrDefaultAsync(c => c.Id == categoryId);
        }

        public async Task<List<Collection>> GetAllCollectionAsync()
        {
            return await _context.Collections
                .Include(c => c.Categories)
                .Include(c => c.Products)
                .OrderByDescending(c => c.CreatedAt)
                .ToListAsync();
        }

        public async Task<Collection> GetCollectionByIdAsync(Guid collectionId)
        {
            return await _context.Collections
                .Include(c => c.Categories)
                .Include(c => c.Products)
                .FirstOrDefaultAsync(c => c.Id == collectionId);
        }

        public async Task<List<User>> GetAllCustomerAsync()
        {
            return await _context.Users
                .Where(u => u.Role == UserRole.Customer)
                .OrderByDescending(u => u.CreatedAt)
                .ToListAsync();
        }

        public async Task<User> GetCustomerByIdAsync(Guid customerId)
        {
            return await _context.Users
                .Include(u => u.Addresses)
                .Include(u => u.Orders)
                .FirstOrDefaultAsync(u => u.Id == customerId);
        }

        public async Task<List<Order>> GetAllOrderAsync()
        {
            return await _context.Orders
                .Include(o => o.User)
                .Include(o => o.OrderItems)
                .OrderByDescending(o => o.OrderDate)
                .ToListAsync();
        }


        public async Task<bool> UpdateOrderStatusAsync(Guid orderId, OrderStatus status)
        {
            var order = await _context.Orders.FirstOrDefaultAsync(o => o.Id == orderId);
            if (order == null) return false;

            order.Status = status;
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<List<Promotion>> GetAllPromotionAsync()
        {
            return await _context.Promotions
                .OrderByDescending(p => p.StartDate)
                .ToListAsync();
        }

        public async Task<Promotion> GetPromotionByIdAsync(Guid promotionId)
        {
            return await _context.Promotions
                .Include(p => p.Orders)
                .FirstOrDefaultAsync(promo => promo.Id == promotionId);
        }

        public async Task<bool> UpdatePromotionAsync(Guid promotionId, CreatePromotionRequest request)
        {
            var promotion = await _context.Promotions
                .FirstOrDefaultAsync(promo => promo.Id == promotionId);
            if (promotion == null) return false;

            promotion.Title         = request.Title;
            promotion.Description   = request.Description;
            promotion.DiscountType  = request.DiscountType;
            promotion.DiscountValue = request.DiscountValue;
            promotion.StartDate     = request.StartDate;
            promotion.EndDate       = request.EndDate;
            promotion.MaxUses       = request.MaxUses;
            promotion.TimesUsed     = request.TimesUsed;
            promotion.IsActive      = request.IsActive;
            promotion.Code          = request.Code;
            promotion.Occasion      = request.Occasion;

            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> DeletePromotionAsync(Guid promotionId)
        {
            var promo = await _context.Promotions.FindAsync(promotionId);
            if (promo == null) return false;

            _context.Promotions.Remove(promo);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<List<Review>> GetAllReviewsAsync()
        {
            return await _context.Reviews
                .Include(r => r.User)
                .Include(r => r.Product)
                .OrderByDescending(r => r.CreatedAt)
                .ToListAsync();
        }

        public async Task<bool> DeleteReviewAsync(Guid reviewId)
        {
            var review = await _context.Reviews.FindAsync(reviewId);
            if (review == null) return false;

            _context.Reviews.Remove(review);
            await _context.SaveChangesAsync();
            return true;
        }
    }
}