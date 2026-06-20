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
                .Where(f => f.UserId == userId)
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

        public async Task<Favorite> AddFavoriteProductAsync(Guid userId, Guid productId)
        {
            var userExists = await _context.Users.AnyAsync(u => u.Id == userId);
            if (!userExists)
                throw new ArgumentException($"User with ID {userId} does not exist.");

            var productExists = await _context.Products.AnyAsync(p => p.Id == productId);
            if (!productExists)
                throw new ArgumentException($"Product with ID {productId} does not exist.");

            var alreadyExists = await _context.Favorites
                .AnyAsync(f => f.UserId == userId && f.ProductId == productId);
            if (alreadyExists)
                throw new ArgumentException($"Product with ID {productId} is already favorited by this user.");

            var favorite = new Favorite
            {
                UserId    = userId,
                ProductId = productId,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };

            await _context.Favorites.AddAsync(favorite);
            await _context.SaveChangesAsync();

            return (await _context.Favorites
                .Include(f => f.Product)
                .FirstOrDefaultAsync(f => f.Id == favorite.Id))!;
        }

        public async Task<Favorite> AddFavoriteCollectionAsync(Guid userId, Guid collectionId)
        {
            var userExists = await _context.Users.AnyAsync(u => u.Id == userId);
            if (!userExists)
                throw new ArgumentException($"User with ID {userId} does not exist.");

            var collectionExists = await _context.Collections.AnyAsync(c => c.Id == collectionId);
            if (!collectionExists)
                throw new ArgumentException($"Collection with ID {collectionId} does not exist.");

            var alreadyExists = await _context.Favorites
                .AnyAsync(f => f.UserId == userId && f.CollectionId == collectionId);
            if (alreadyExists)
                throw new ArgumentException($"Collection with ID {collectionId} is already favorited by this user.");

            var favorite = new Favorite
            {
                UserId       = userId,
                CollectionId = collectionId,
                CreatedAt    = DateTime.UtcNow,
                UpdatedAt    = DateTime.UtcNow
            };

            await _context.Favorites.AddAsync(favorite);
            await _context.SaveChangesAsync();

            return (await _context.Favorites
                .Include(f => f.Collection)
                .FirstOrDefaultAsync(f => f.Id == favorite.Id))!;
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

        // Returns true = added, false = removed
        public async Task<(bool isFavorited, Favorite? favorite)> ToggleFavoriteProductAsync(Guid userId, Guid productId)
        {
            var userExists = await _context.Users.AnyAsync(u => u.Id == userId);
            if (!userExists)
                throw new ArgumentException($"User with ID {userId} does not exist.");

            var productExists = await _context.Products.AnyAsync(p => p.Id == productId);
            if (!productExists)
                throw new ArgumentException($"Product with ID {productId} does not exist.");

            var existing = await _context.Favorites
                .FirstOrDefaultAsync(f => f.UserId == userId && f.ProductId == productId);

            if (existing != null)
            {
                // Already favorited → remove it
                _context.Favorites.Remove(existing);
                await _context.SaveChangesAsync();
                return (false, null);
            }

            // Not favorited → add it
            var favorite = new Favorite
            {
                UserId    = userId,
                ProductId = productId,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };

            await _context.Favorites.AddAsync(favorite);
            await _context.SaveChangesAsync();

            var loaded = await _context.Favorites
                .Include(f => f.Product)
                .FirstOrDefaultAsync(f => f.Id == favorite.Id);

            return (true, loaded);
        }
    }
}