namespace Souvenir_Collection_Backend.Services
{
    public class FavoriteService
    {
        private readonly AppDbContext _context;

        public FavoriteService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<List<Favorite>> GetFavoriteProductsAsync(Guid userId)
        {
            return await _context.Favorites
                .Include(f => f.Product)
                .Where(f => f.UserId == userId && f.ProductId != null)
                .OrderByDescending(f => f.CreatedAt)
                .ToListAsync();
        }

        public async Task<List<Favorite>> GetFavoriteCollectionsAsync(Guid userId)
        {
            return await _context.Favorites
                .Include(f => f.Collection)
                .Where(f => f.UserId == userId && f.CollectionId != null)
                .OrderByDescending(f => f.CreatedAt)
                .ToListAsync();
        }

        public async Task<bool> AddFavoriteProductAsync(Guid userId, Guid productId)
        {
            var productExists = await _context.Products.AnyAsync(p => p.Id == productId);
            if (!productExists) return false;
            var alreadyExists = await _context.Favorites
                .AnyAsync(f => f.UserId == userId && f.ProductId == productId);
            if (alreadyExists) return false;

            var favorite = new Favorite
            {
                UserId    = userId,
                ProductId = productId,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };

            await _context.Favorites.AddAsync(favorite);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> AddFavoriteCollectionAsync(Guid userId, Guid collectionId)
        {
            var collectionExists = await _context.Collections.AnyAsync(c => c.Id == collectionId);
            if (!collectionExists) return false;

            var alreadyExists = await _context.Favorites
                .AnyAsync(f => f.UserId == userId && f.CollectionId == collectionId);
            if (alreadyExists) return false;

            var favorite = new Favorite
            {
                UserId       = userId,
                CollectionId = collectionId,
                CreatedAt    = DateTime.UtcNow,
                UpdatedAt    = DateTime.UtcNow
            };

            await _context.Favorites.AddAsync(favorite);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> RemoveFavoriteProductAsync(Guid userId, Guid productId)
        {
            var favorite = await _context.Favorites
                .FirstOrDefaultAsync(f => f.UserId == userId && f.ProductId == productId);

            if (favorite == null) return false;

            _context.Favorites.Remove(favorite);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> RemoveFavoriteCollectionAsync(Guid userId, Guid collectionId)
        {
            var favorite = await _context.Favorites
                .FirstOrDefaultAsync(f => f.UserId == userId && f.CollectionId == collectionId);

            if (favorite == null) return false;

            _context.Favorites.Remove(favorite);
            await _context.SaveChangesAsync();
            return true;
        }


        public async Task<bool> IsProductFavoritedAsync(Guid userId, Guid productId)
        {
            return await _context.Favorites
                .AnyAsync(f => f.UserId == userId && f.ProductId == productId);
        }

        public async Task<bool> IsCollectionFavoritedAsync(Guid userId, Guid collectionId)
        {
            return await _context.Favorites
                .AnyAsync(f => f.UserId == userId && f.CollectionId == collectionId);
        }
    }
}