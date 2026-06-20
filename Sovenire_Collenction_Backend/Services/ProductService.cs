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

        public async Task<(Product? Product, string? Error)> CreateProductAsync(CreateProductRequest request)
        {
            var artisanExists = await _context.Artisans.AnyAsync(a => a.Id == request.ArtisanId);
            if (!artisanExists) return (null, $"Artisan with ID {request.ArtisanId} not found.");

            var categoryExists = await _context.Categories.AnyAsync(c => c.Id == request.CategoryId);
            if (!categoryExists) return (null, $"Category with ID {request.CategoryId} not found.");

            var product = new Product
            {
                Id          = Guid.NewGuid(),
                ArtisanId   = request.ArtisanId,
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

            var loadedProduct = await _context.Products
                .Include(p => p.Artisan)
                .Include(p => p.Category)
                .FirstOrDefaultAsync(p => p.Id == product.Id);

            return (loadedProduct, null);
        }

        public async Task<Product?> UpdateProductAsync(Guid productId, UpdateProductRequest request)
        {
            var product = await _context.Products
                .Include(p => p.Category)
                .Include(p => p.Artisan)
                .FirstOrDefaultAsync(p => p.Id == productId);

            if (product == null) return null;

            var artisanExists = await _context.Artisans.AnyAsync(a => a.Id == request.ArtisanId);
            if (!artisanExists) return null;

            var categoryExists = await _context.Categories.AnyAsync(c => c.Id == request.CategoryId);
            if (!categoryExists) return null;

            product.ArtisanId   = request.ArtisanId;
            product.CategoryId  = request.CategoryId;
            product.Name        = request.Name;
            product.Description = request.Description;
            product.Price       = request.Price;
            product.StockQty    = request.StockQty;
            product.Image       = request.Image;
            product.IsAvailable = request.IsAvailable;
            product.UpdatedAt   = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            var updatedProduct = await _context.Products
                .Include(p => p.Category)
                .Include(p => p.Artisan)
                .FirstOrDefaultAsync(p => p.Id == productId);

            return updatedProduct;
        }
        
        public async Task<bool> DeleteProductAsync(Guid productId)
        {
            var product = await _context.Products.FirstOrDefaultAsync(p => p.Id == productId);
            if (product == null) return false;

            _context.Products.Remove(product);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> ToggleAvailabilityAsync(Guid productId)
        {
            var product = await _context.Products.FirstOrDefaultAsync(p => p.Id == productId);
            if (product == null) return false;

            product.IsAvailable = !product.IsAvailable;
            product.UpdatedAt   = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> UpdateStockAsync(Guid productId, int quantity)
        {
            var product = await _context.Products.FirstOrDefaultAsync(p => p.Id == productId);
            if (product == null) return false;
            if (quantity < 0) return false;

            product.StockQty  = quantity;
            product.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return true;
        }
    }
}