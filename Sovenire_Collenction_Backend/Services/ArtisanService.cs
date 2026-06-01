namespace Souvenir_Collection_Backend.Services
{
    public class ArtisanService
    {
        private readonly AppDbContext _context;

        public ArtisanService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<List<User>> GetAllArtisanAsync()
        {
            return await _context.Users
                .Include(u => u.Artisan)
                    .ThenInclude(a => a.Products)
                .Where(u => u.ArtisanId != null)
                .OrderByDescending(u => u.CreatedAt)
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

        public async Task<bool> UnverifyArtisanAsync(Guid artisanId)
        {
            var artisan = await _context.Artisans.FindAsync(artisanId);
            if (artisan == null) return false;

            artisan.IsVerified = false;
            artisan.VerifiedAt = null;

            await _context.SaveChangesAsync();
            return true;
        }


        public async Task<Artisan> GetArtisanProfileAsync(Guid artisanId)
        {
            return await _context.Artisans
                .Include(a => a.User)
                .Include(a => a.Products)
                .FirstOrDefaultAsync(a => a.Id == artisanId);
        }

        public async Task<bool> UpdateArtisanProfileAsync(Guid artisanId, UpdateArtisanProfileRequest request)
        {
            var artisan = await _context.Artisans
                .Include(a => a.User)
                .FirstOrDefaultAsync(a => a.Id == artisanId);

            if (artisan == null) return false;

            artisan.ShopName        = request.ShopName;
            artisan.Bio             = request.Bio;
            artisan.ProfilePhoto    = request.ProfilePhoto;
            artisan.PhoneNumber     = request.PhoneNumber;
            artisan.Location        = request.Location;
            artisan.UpdatedAt       = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return true;
        }


        public async Task<List<Product>> GetMyProductsAsync(Guid artisanId)
        {
            return await _context.Products
                .Include(p => p.Category)
                .Include(p => p.Collection)
                .Where(p => p.ArtisanId == artisanId)
                .OrderByDescending(p => p.CreatedAt)
                .ToListAsync();
        }

        public async Task<Product> CreateProductAsync(Guid artisanId, CreateProductRequest request)
        {
            var artisan = await _context.Artisans.FindAsync(artisanId);
            if (artisan == null) return null;

            var product = new Product
            {
                Id           = Guid.NewGuid(),
                ArtisanId    = artisanId,
                Name         = request.Name,
                Description  = request.Description,
                Price        = request.Price,
                Stock        = request.Stock,
                ImageUrl     = request.ImageUrl,
                CategoryId   = request.CategoryId,
                CollectionId = request.CollectionId,
                CreatedAt    = DateTime.UtcNow,
                UpdatedAt    = DateTime.UtcNow
            };

            await _context.Products.AddAsync(product);
            await _context.SaveChangesAsync();
            return product;
        }

        public async Task<bool> UpdateProductAsync(Guid artisanId, Guid productId, UpdateProductRequest request)
        {
            var product = await _context.Products
                .FirstOrDefaultAsync(p => p.Id == productId && p.ArtisanId == artisanId);

            if (product == null) return false;

            product.Name         = request.Name;
            product.Description  = request.Description;
            product.Price        = request.Price;
            product.Stock        = request.Stock;
            product.ImageUrl     = request.ImageUrl;
            product.CategoryId   = request.CategoryId;
            product.CollectionId = request.CollectionId;
            product.UpdatedAt    = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> DeleteProductAsync(Guid artisanId, Guid productId)
        {
            var product = await _context.Products
                .FirstOrDefaultAsync(p => p.Id == productId && p.ArtisanId == artisanId);

            if (product == null) return false;

            _context.Products.Remove(product);
            await _context.SaveChangesAsync();
            return true;
        }
        public async Task<List<Order>> GetMyOrdersAsync(Guid artisanId)
        {
            return await _context.Orders
                .Include(o => o.User)
                .Include(o => o.OrderItems)
                    .ThenInclude(oi => oi.Product)
                .Where(o => o.OrderItems.Any(oi => oi.Product.ArtisanId == artisanId))
                .OrderByDescending(o => o.OrderDate)
                .ToListAsync();
        }

        public async Task<bool> UpdateOrderItemStatusAsync(Guid artisanId, Guid orderItemId, OrderItemStatus status)
        {
            var orderItem = await _context.OrderItems
                .Include(oi => oi.Product)
                .FirstOrDefaultAsync(oi => oi.Id == orderItemId && oi.Product.ArtisanId == artisanId);

            if (orderItem == null) return false;

            orderItem.Status    = status;
            orderItem.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return true;
        }


        public async Task<ArtisanDashboardDto> GetArtisanDashboardAsync(Guid artisanId)
        {
            var totalProducts = await _context.Products
                .CountAsync(p => p.ArtisanId == artisanId);

            var totalOrders = await _context.Orders
                .CountAsync(o => o.OrderItems.Any(oi => oi.Product.ArtisanId == artisanId));

            var pendingOrders = await _context.Orders
                .CountAsync(o => o.Status == OrderStatus.Pending &&
                                 o.OrderItems.Any(oi => oi.Product.ArtisanId == artisanId));

            var totalRevenue = await _context.OrderItems
                .Where(oi => oi.Product.ArtisanId == artisanId &&
                             oi.Order.Payment.Status == PaymentStatus.Success)
                .SumAsync(oi => oi.Price * oi.Quantity);

            var totalReviews = await _context.Reviews
                .CountAsync(r => r.Product.ArtisanId == artisanId);

            return new ArtisanDashboardDto
            {
                TotalProducts = totalProducts,
                TotalOrders   = totalOrders,
                PendingOrders = pendingOrders,
                TotalRevenue  = totalRevenue,
                TotalReviews  = totalReviews
            };
        }

        public async Task<List<Review>> GetMyReviewsAsync(Guid artisanId)
        {
            return await _context.Reviews
                .Include(r => r.User)
                .Include(r => r.Product)
                .Where(r => r.Product.ArtisanId == artisanId)
                .OrderByDescending(r => r.CreatedAt)
                .ToListAsync();
        }
    }
}