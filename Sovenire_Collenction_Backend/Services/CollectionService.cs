namespace Souvenir_Collection_Backend.Services
{
    public class CollectionService
    {
        private readonly AppDbContext _context;

        public CollectionService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<List<Collection>> GetAllCollectionsAsync()
        {
            return await _context.Collections
                .Include(c => c.CollectionProducts)
                    .ThenInclude(cp => cp.Product)
                .OrderBy(c => c.DisplayOrder)
                .ToListAsync();
        }

        public async Task<Collection> GetCollectionByIdAsync(Guid collectionId)
        {
            return await _context.Collections
                .Include(c => c.CollectionProducts)
                    .ThenInclude(cp => cp.Product)
                .FirstOrDefaultAsync(c => c.Id == collectionId);
        }

        public async Task<Collection> GetCollectionBySlugAsync(string slug)
        {
            return await _context.Collections
                .Include(c => c.CollectionProducts)
                    .ThenInclude(cp => cp.Product)
                .FirstOrDefaultAsync(c => c.Slug == slug);
        }

        public async Task<List<Collection>> GetCollectionsByTypeAsync(string type)
        {
            return await _context.Collections
                .Include(c => c.CollectionProducts)
                    .ThenInclude(cp => cp.Product)
                .Where(c => c.Type == type)
                .OrderBy(c => c.DisplayOrder)
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
                DisplayOrder = request.DisplayOrder,
                CreatedAt    = DateTime.UtcNow,
                UpdatedAt    = DateTime.UtcNow
            };

            await _context.Collections.AddAsync(collection);
            await _context.SaveChangesAsync();
            return collection;
        }

        public async Task<bool> UpdateCollectionAsync(Guid collectionId, UpdateCollectionRequest request)
        {
            var collection = await _context.Collections.FindAsync(collectionId);
            if (collection == null) return false;

            var slugExists = await _context.Collections
                .AnyAsync(c => c.Slug == request.Slug && c.Id != collectionId);
            if (slugExists) return false;

            collection.Title        = request.Title;
            collection.Slug         = request.Slug;
            collection.Description  = request.Description;
            collection.Type         = request.Type;
            collection.Image        = request.Image;
            collection.DisplayOrder = request.DisplayOrder;
            collection.UpdatedAt    = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> DeleteCollectionAsync(Guid collectionId)
        {
            var collection = await _context.Collections.FindAsync(collectionId);
            if (collection == null) return false;

            _context.Collections.Remove(collection);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> AddProductToCollectionAsync(Guid collectionId, Guid productId, int displayOrder)
        {
            var collectionExists = await _context.Collections.AnyAsync(c => c.Id == collectionId);
            if (!collectionExists) return false;

            var productExists = await _context.Products.AnyAsync(p => p.Id == productId);
            if (!productExists) return false;

            var alreadyExists = await _context.CollectionProducts
                .AnyAsync(cp => cp.CollectionId == collectionId && cp.ProductId == productId);
            if (alreadyExists) return false;

            var collectionProduct = new CollectionProduct
            {
                CollectionId = collectionId,
                ProductId    = productId,
                DisplayOrder = displayOrder,
                CreatedAt    = DateTime.UtcNow,
                UpdatedAt    = DateTime.UtcNow
            };

            await _context.CollectionProducts.AddAsync(collectionProduct);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> RemoveProductFromCollectionAsync(Guid collectionId, Guid productId)
        {
            var collectionProduct = await _context.CollectionProducts
                .FirstOrDefaultAsync(cp => cp.CollectionId == collectionId && cp.ProductId == productId);

            if (collectionProduct == null) return false;

            _context.CollectionProducts.Remove(collectionProduct);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> UpdateProductDisplayOrderAsync(Guid collectionId, Guid productId, int displayOrder)
        {
            var collectionProduct = await _context.CollectionProducts
                .FirstOrDefaultAsync(cp => cp.CollectionId == collectionId && cp.ProductId == productId);

            if (collectionProduct == null) return false;

            collectionProduct.DisplayOrder = displayOrder;
            collectionProduct.UpdatedAt    = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<List<CollectionProduct>> GetCollectionProductsAsync(Guid collectionId)
        {
            return await _context.CollectionProducts
                .Include(cp => cp.Product)
                .Where(cp => cp.CollectionId == collectionId)
                .OrderBy(cp => cp.DisplayOrder)
                .ToListAsync();
        }
    }
}