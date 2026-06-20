namespace Souvenir_Collection_Backend.Services
{
    public class CollectionService
    {
        private readonly AppDbContext _context;

        public CollectionService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<List<Collection>> GetAllCollectionsAsync(string sortOrder = "asc")
        {
            bool isDescending = !string.IsNullOrEmpty(sortOrder) && 
                (sortOrder.Equals("desc", System.StringComparison.OrdinalIgnoreCase) || 
                 sortOrder.Equals("des", System.StringComparison.OrdinalIgnoreCase));

            var query = _context.Collections.AsQueryable();
            
            return await (isDescending 
                ? query.OrderByDescending(c => c.Title) 
                : query.OrderBy(c => c.Title))
                .ToListAsync();
        }

        public async Task<Collection> GetCollectionByIdAsync(Guid collectionId)
        {
            return await _context.Collections
                .FirstOrDefaultAsync(c => c.Id == collectionId);
        }

        public async Task<Collection> GetCollectionBySlugAsync(string slug)
        {
            return await _context.Collections
                .FirstOrDefaultAsync(c => c.Slug == slug);
        }

        public async Task<List<Collection>> GetCollectionsByTypeAsync(string type, string sortOrder = "asc")
        {
            bool isDescending = !string.IsNullOrEmpty(sortOrder) && 
                (sortOrder.Equals("desc", System.StringComparison.OrdinalIgnoreCase) || 
                 sortOrder.Equals("des", System.StringComparison.OrdinalIgnoreCase));

            var query = _context.Collections.Where(c => c.Type == type);
            
            return await (isDescending 
                ? query.OrderByDescending(c => c.Title) 
                : query.OrderBy(c => c.Title))
                .ToListAsync();
        }
        public async Task<Collection> CreateCollectionAsync(CreateCollectionRequest request)
        {
            var slugExists = await _context.Collections
                .AnyAsync(c => c.Slug == request.Slug);
            if (slugExists) return null;

            var collection = new Collection
            {
                Title        = request.Title,
                Slug         = request.Slug,
                Description  = request.Description,
                Type         = request.Type,
                Image        = request.Image,
                CreatedAt    = DateTime.UtcNow,
                UpdatedAt    = DateTime.UtcNow
            };

            await _context.Collections.AddAsync(collection);
            await _context.SaveChangesAsync();
            return collection;
        }

        public async Task<Collection?> UpdateCollectionAsync(Guid collectionId, UpdateCollectionRequest request)
        {
            var collection = await _context.Collections
                .FirstOrDefaultAsync(c => c.Id == collectionId);
            if (collection == null) return null;

            var slugExists = await _context.Collections
                .AnyAsync(c => c.Slug == request.Slug && c.Id != collectionId);
            if (slugExists) return null;

            collection.Title        = request.Title;
            collection.Slug         = request.Slug;
            collection.Description  = request.Description;
            collection.Type         = request.Type;
            collection.Image        = request.Image;
            collection.UpdatedAt    = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return collection;
        }

        public async Task<bool> DeleteCollectionAsync(Guid collectionId)
        {
            var collection = await _context.Collections.FindAsync(collectionId);
            if (collection == null) return false;

            // Nullify collection reference on associated products
            var products = await _context.Products.Where(p => p.CollectionId == collectionId).ToListAsync();
            foreach (var p in products)
            {
                p.CollectionId = null;
            }

            _context.Collections.Remove(collection);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> AddProductToCollectionAsync(Guid collectionId, Guid productId)
        {
            var collectionExists = await _context.Collections.AnyAsync(c => c.Id == collectionId);
            if (!collectionExists) return false;

            var product = await _context.Products.FindAsync(productId);
            if (product == null) return false;

            product.CollectionId = collectionId;
            product.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> RemoveProductFromCollectionAsync(Guid collectionId, Guid productId)
        {
            var product = await _context.Products
                .FirstOrDefaultAsync(p => p.Id == productId && p.CollectionId == collectionId);

            if (product == null) return false;

            product.CollectionId = null;
            product.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<List<Product>> GetCollectionProductsAsync(Guid collectionId, string sortOrder = "asc")
        {
            bool isDescending = !string.IsNullOrEmpty(sortOrder) && 
                (sortOrder.Equals("desc", System.StringComparison.OrdinalIgnoreCase) || 
                 sortOrder.Equals("des", System.StringComparison.OrdinalIgnoreCase));

            var query = _context.Products.Where(p => p.CollectionId == collectionId);
            
            return await (isDescending 
                ? query.OrderByDescending(p => p.Name) 
                : query.OrderBy(p => p.Name))
                .ToListAsync();
        }
    }
}