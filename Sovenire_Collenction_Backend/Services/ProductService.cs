namespace Souvenir_Collection_Backend.Services
{
    public class ProductService
    {
        private readonly AppDbContext _context;

        public ProductService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<List<Product>> GetAllProductsAsync()
        {
            return await _context.Products
                .Include(p => p.Artisan)
                .Include(p => p.Category)
                .Where(p => p.IsAvailable == true)
                .OrderByDescending(p => p.CreatedAt)
                .ToListAsync();
        }

        public async Task<Product> GetProductByIdAsync(Guid productId)
        {
            return await _context.Products
                .Include(p => p.Artisan)
                .Include(p => p.Category)
                .Include(p => p.CollectionProducts)
                    .ThenInclude(cp => cp.Collection)
                .FirstOrDefaultAsync(p => p.Id == productId);
        }

        public async Task<List<Product>> GetProductsByCategoryAsync(Guid categoryId)
        {
            return await _context.Products
                .Include(p => p.Artisan)
                .Include(p => p.Category)
                .Where(p => p.CategoryId == categoryId && p.IsAvailable == true)
                .OrderByDescending(p => p.CreatedAt)
                .ToListAsync();
        }

        public async Task<List<Product>> GetProductsByArtisanAsync(Guid artisanId)
        {
            return await _context.Products
                .Include(p => p.Category)
                .Where(p => p.ArtisanId == artisanId && p.IsAvailable == true)
                .OrderByDescending(p => p.CreatedAt)
                .ToListAsync();
        }

        public async Task<List<Product>> SearchProductsAsync(string keyword)
        {
            return await _context.Products
                .Include(p => p.Artisan)
                .Include(p => p.Category)
                .Where(p => p.Name.Contains(keyword) && p.IsAvailable == true)
                .OrderByDescending(p => p.CreatedAt)
                .ToListAsync();
        }

        public async Task<Product> CreateProductAsync(Guid artisanId, CreateProductRequest request)
        {
            var artisanExists = await _context.Artisans.AnyAsync(a => a.Id == artisanId);
            if (!artisanExists) return null;

            var categoryExists = await _context.Categories.AnyAsync(c => c.Id == request.CategoryId);
            if (!categoryExists) return null;

            var product = new Product
            {
                ArtisanId   = artisanId,
                CategoryId  = request.CategoryId,
                Name        = request.Name,
                Description = request.Description,
                Price       = request.Price,
                StockQty    = request.StockQty,
                Image       = request.Image,
                IsAvailable = request.IsAvailable,
                CreatedAt   = DateTime.UtcNow,
                UpdatedAt   = DateTime.UtcNow
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

            var categoryExists = await _context.Categories.AnyAsync(c => c.Id == request.CategoryId);
            if (!categoryExists) return false;

            product.CategoryId  = request.CategoryId;
            product.Name        = request.Name;
            product.Description = request.Description;
            product.Price       = request.Price;
            product.StockQty    = request.StockQty;
            product.Image       = request.Image;
            product.IsAvailable = request.IsAvailable;
            product.UpdatedAt   = DateTime.UtcNow;

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

        public async Task<bool> ToggleAvailabilityAsync(Guid artisanId, Guid productId)
        {
            var product = await _context.Products
                .FirstOrDefaultAsync(p => p.Id == productId && p.ArtisanId == artisanId);

            if (product == null) return false;

            product.IsAvailable = !product.IsAvailable;
            product.UpdatedAt   = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> UpdateStockAsync(Guid artisanId, Guid productId, int quantity)
        {
            var product = await _context.Products
                .FirstOrDefaultAsync(p => p.Id == productId && p.ArtisanId == artisanId);

            if (product == null) return false;
            if (quantity < 0) return false;

            product.StockQty  = quantity;
            product.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return true;
        }
    }
}