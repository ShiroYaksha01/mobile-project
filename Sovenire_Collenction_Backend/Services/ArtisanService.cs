namespace Souvenir_Collection_Backend.Services
{
    public class ArtisanService
    {
        private readonly AppDbContext _context;

        public ArtisanService(AppDbContext context)
        {
            _context = context;
        }

        // ✅ Fixed: query Artisans directly instead of Users
        public async Task<List<Artisan>> GetAllArtisanAsync()
        {
            return await _context.Artisans
                .Include(a => a.Products)
                .OrderByDescending(a => a.CreatedAt)
                .ToListAsync();
        }

        public async Task<Artisan?> CreateArtisanAsync(CreateArtisanRequest request)
        {
            var artisan = new Artisan
            {
                Id = Guid.NewGuid(),
                DisplayName = request.DisplayName,
                Region = request.Region,
                CraftType = request.CraftType,
                Bio = request.Bio,
                ProfilePhotoUrl = request.ProfilePhotoUrl,
                ShopAddress = request.ShopAddress,
                Lat = request.Lat,
                Lng = request.Lng,
                IsVerified = false,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };

            await _context.Artisans.AddAsync(artisan);
            await _context.SaveChangesAsync();
            return artisan;
        }

        public async Task<Artisan> GetArtisanByIdAsync(Guid artisanId)
        {
            return await _context.Artisans
                .Include(a => a.Products)
                .FirstOrDefaultAsync(a => a.Id == artisanId);
        }

        public async Task<Artisan?> VerifyArtisanAsync(Guid artisanId)
        {
            var artisan = await _context.Artisans.FindAsync(artisanId);
            if (artisan == null) return null;

            artisan.IsVerified = true;

            await _context.SaveChangesAsync();
            return artisan;
        }

        public async Task<Artisan?> UnverifyArtisanAsync(Guid artisanId)
        {
            var artisan = await _context.Artisans.FindAsync(artisanId);
            if (artisan == null) return null;

            artisan.IsVerified = false;

            await _context.SaveChangesAsync();
            return artisan;
        }

        public async Task<Artisan> GetArtisanProfileAsync(Guid artisanId)
        {
            return await _context.Artisans
                .Include(a => a.Products)
                .FirstOrDefaultAsync(a => a.Id == artisanId);
        }

        public async Task<Artisan?> UpdateArtisanProfileAsync(Guid artisanId, UpdateArtisanProfileRequest request)
        {
            var artisan = await _context.Artisans
                .FirstOrDefaultAsync(a => a.Id == artisanId);

            if (artisan == null) return null;

            if (request.ShopName != null) artisan.DisplayName = request.ShopName;
            if (request.Bio != null) artisan.Bio = request.Bio;
            if (request.ProfilePhoto != null) artisan.ProfilePhotoUrl = request.ProfilePhoto;
            if (request.Location != null) artisan.ShopAddress = request.Location;
            artisan.UpdatedAt       = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return artisan;
        }

        public async Task<Artisan?> UpdateArtisanAsync(Guid id, UpdateArtisanRequest request)
        {
            var artisan = await _context.Artisans
                .FirstOrDefaultAsync(a => a.Id == id);

            if (artisan == null) return null;

            if (request.DisplayName != null) artisan.DisplayName = request.DisplayName;
            if (request.Region != null) artisan.Region = request.Region;
            if (request.CraftType != null) artisan.CraftType = request.CraftType;
            if (request.Bio != null) artisan.Bio = request.Bio;
            if (request.ProfilePhotoUrl != null) artisan.ProfilePhotoUrl = request.ProfilePhotoUrl;
            if (request.ShopAddress != null) artisan.ShopAddress = request.ShopAddress;
            if (request.Lat.HasValue) artisan.Lat = request.Lat.Value;
            if (request.Lng.HasValue) artisan.Lng = request.Lng.Value;
            if (request.IsVerified.HasValue) artisan.IsVerified = request.IsVerified.Value;

            artisan.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return artisan;
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
                Id          = Guid.NewGuid(),
                ArtisanId   = artisanId,
                Name        = request.Name,
                Description = request.Description,
                Price       = request.Price,
                StockQty    = request.StockQty,
                Image       = request.Image,
                CategoryId  = request.CategoryId,
                IsAvailable = request.IsAvailable,
                CreatedAt   = DateTime.UtcNow,
                UpdatedAt   = DateTime.UtcNow
            };

            await _context.Products.AddAsync(product);
            await _context.SaveChangesAsync();
            return product;
        }

        public async Task<Product?> UpdateProductAsync(Guid artisanId, Guid productId, UpdateProductRequest request)
        {
            var product = await _context.Products
                .Include(p => p.Category)
                .FirstOrDefaultAsync(p => p.Id == productId && p.ArtisanId == artisanId);

            if (product == null) return null;

            product.Name        = request.Name;
            product.Description = request.Description;
            product.Price       = request.Price;
            product.StockQty    = request.StockQty;
            product.Image       = request.Image;
            product.CategoryId  = request.CategoryId;
            product.IsAvailable = request.IsAvailable;
            product.UpdatedAt   = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return product;
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
                .OrderByDescending(o => o.CreatedAt)
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
                             oi.Order.Payment != null &&
                             oi.Order.Payment.Status == PaymentStatus.Paid)
                .SumAsync(oi => oi.TotalPrice);

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

        public async Task<bool> DeleteArtisanAsync(Guid artisanId)
        {
            var artisan = await _context.Artisans.FindAsync(artisanId);
            if (artisan == null) return false;

            _context.Artisans.Remove(artisan);
            await _context.SaveChangesAsync();
            return true;
        }
    }
}