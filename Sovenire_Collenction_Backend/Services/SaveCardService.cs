using Microsoft.EntityFrameworkCore;
using Souvenir_Collection_Backend.Models;

namespace Souvenir_Collection_Backend.Services;

public class SavedCardService
{
    private readonly ApplicationDbContext _context;

    public SavedCardService(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<List<SavedCard>> GetCardsByUserIdAsync(Guid userId)
    {
        return await _context.SavedCards
            .Where(c => c.UserId == userId)
            .OrderByDescending(c => c.IsDefault)
            .ThenByDescending(c => c.CreatedAt)
            .ToListAsync();
    }

    public async Task<SavedCard?> GetCardByIdAsync(Guid id)
    {
        return await _context.SavedCards
            .Include(c => c.User)
            .Include(c => c.Payments)
            .FirstOrDefaultAsync(c => c.Id == id);
    }

    public async Task<SavedCard?> GetDefaultCardByUserIdAsync(Guid userId)
    {
        return await _context.SavedCards
            .FirstOrDefaultAsync(c => c.UserId == userId && c.IsDefault);
    }

    public async Task<SavedCard> CreateCardAsync(SavedCard card)
    {
        if (card.IsDefault)
            await UnsetAllDefaultsAsync(card.UserId);

        _context.SavedCards.Add(card);
        await _context.SaveChangesAsync();
        return card;
    }

    public async Task<SavedCard?> SetDefaultCardAsync(Guid id, Guid userId)
    {
        await UnsetAllDefaultsAsync(userId);

        var card = await _context.SavedCards.FindAsync(id);
        if (card == null || card.UserId != userId) return null;

        card.IsDefault = true;
        await _context.SaveChangesAsync();
        return card;
    }

    public async Task<bool> DeleteCardAsync(Guid id)
    {
        var card = await _context.SavedCards.FindAsync(id);
        if (card == null) return false;

        _context.SavedCards.Remove(card);
        await _context.SaveChangesAsync();
        return true;
    }

    private async Task UnsetAllDefaultsAsync(Guid userId)
    {
        var defaultCards = await _context.SavedCards
            .Where(c => c.UserId == userId && c.IsDefault)
            .ToListAsync();

        foreach (var c in defaultCards)
            c.IsDefault = false;

        await _context.SaveChangesAsync();
    }
}