using Microsoft.EntityFrameworkCore;
using Souvenir_Collection_Backend.Data;
using Souvenir_Collection_Backend.Models;

namespace Souvenir_Collection_Backend.Services
{
    public class UserCollectionService
    {
        private readonly AppDbContext _context;

        public UserCollectionService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<List<UserCollection>> GetUserCollectionsAsync(Guid userId)
        {
            return await _context.UserCollections
                .Include(uc => uc.Items)
                    .ThenInclude(i => i.Product)
                .Where(uc => uc.UserId == userId)
                .OrderByDescending(uc => uc.CreatedAt)
                .ToListAsync();
        }

        public async Task<UserCollection?> GetUserCollectionByIdAsync(Guid userId, Guid collectionId)
        {
            return await _context.UserCollections
                .Include(uc => uc.Items)
                    .ThenInclude(i => i.Product)
                .FirstOrDefaultAsync(uc => uc.Id == collectionId && uc.UserId == userId);
        }

        public async Task<UserCollection> CreateUserCollectionAsync(Guid userId, string name)
        {
            var collection = new UserCollection
            {
                UserId = userId,
                Name = name,
                CreatedAt = DateTime.UtcNow
            };

            await _context.UserCollections.AddAsync(collection);
            await _context.SaveChangesAsync();

            return collection;
        }

        public async Task<bool> DeleteUserCollectionAsync(Guid userId, Guid collectionId)
        {
            var collection = await _context.UserCollections
                .FirstOrDefaultAsync(uc => uc.Id == collectionId && uc.UserId == userId);

            if (collection == null) return false;

            _context.UserCollections.Remove(collection);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> AddOrUpdateItemAsync(Guid userId, Guid collectionId, Guid productId, int quantity)
        {
            var collection = await _context.UserCollections
                .Include(uc => uc.Items)
                .FirstOrDefaultAsync(uc => uc.Id == collectionId && uc.UserId == userId);

            if (collection == null) return false;

            var existingItem = collection.Items.FirstOrDefault(i => i.ProductId == productId);
            if (existingItem != null)
            {
                existingItem.Quantity = quantity;
            }
            else
            {
                collection.Items.Add(new UserCollectionItem
                {
                    UserCollectionId = collectionId,
                    ProductId = productId,
                    Quantity = quantity
                });
            }

            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> RemoveItemAsync(Guid userId, Guid collectionId, Guid productId)
        {
            var item = await _context.UserCollectionItems
                .FirstOrDefaultAsync(i => i.UserCollectionId == collectionId && i.ProductId == productId && i.UserCollection.UserId == userId);

            if (item == null) return false;

            _context.UserCollectionItems.Remove(item);
            await _context.SaveChangesAsync();
            return true;
        }
    }
}
