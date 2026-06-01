using Microsoft.EntityFrameworkCore;
using Souvenir_Collection_Backend.Models;

namespace Souvenir_Collection_Backend.Services;

public class ReviewService
{
    private readonly ApplicationDbContext _context;

    public ReviewService(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<List<Review>> GetAllReviewsAsync()
    {
        return await _context.Reviews
            .Include(r => r.User)
            .Include(r => r.Product)
            .Include(r => r.Collection)
            .OrderByDescending(r => r.CreatedAt)
            .ToListAsync();
    }

    public async Task<Review?> GetReviewByIdAsync(Guid id)
    {
        return await _context.Reviews
            .Include(r => r.User)
            .Include(r => r.Product)
            .Include(r => r.Collection)
            .FirstOrDefaultAsync(r => r.Id == id);
    }

    public async Task<List<Review>> GetReviewsByProductIdAsync(Guid productId)
    {
        return await _context.Reviews
            .Include(r => r.User)
            .Where(r => r.ProductId == productId)
            .OrderByDescending(r => r.CreatedAt)
            .ToListAsync();
    }

    public async Task<List<Review>> GetReviewsByCollectionIdAsync(Guid collectionId)
    {
        return await _context.Reviews
            .Include(r => r.User)
            .Where(r => r.CollectionId == collectionId)
            .OrderByDescending(r => r.CreatedAt)
            .ToListAsync();
    }

    public async Task<List<Review>> GetReviewsByUserIdAsync(Guid userId)
    {
        return await _context.Reviews
            .Include(r => r.Product)
            .Include(r => r.Collection)
            .Where(r => r.UserId == userId)
            .OrderByDescending(r => r.CreatedAt)
            .ToListAsync();
    }

    public async Task<Review> CreateReviewAsync(Review review)
    {
        _context.Reviews.Add(review);
        await _context.SaveChangesAsync();
        return review;
    }

    public async Task<Review?> UpdateReviewAsync(Guid id, Review updated)
    {
        var review = await _context.Reviews.FindAsync(id);
        if (review == null) return null;

        review.ReviewText = updated.ReviewText;
        review.Rating = updated.Rating;
        review.Image = updated.Image;
        review.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();
        return review;
    }

    public async Task<bool> DeleteReviewAsync(Guid id)
    {
        var review = await _context.Reviews.FindAsync(id);
        if (review == null) return false;

        _context.Reviews.Remove(review);
        await _context.SaveChangesAsync();
        return true;
    }

    public async Task<double> GetAverageRatingByProductIdAsync(Guid productId)
    {
        var ratings = await _context.Reviews
            .Where(r => r.ProductId == productId)
            .Select(r => r.Rating)
            .ToListAsync();

        return ratings.Any() ? ratings.Average() : 0;
    }

    public async Task<double> GetAverageRatingByCollectionIdAsync(Guid collectionId)
    {
        var ratings = await _context.Reviews
            .Where(r => r.CollectionId == collectionId)
            .Select(r => r.Rating)
            .ToListAsync();

        return ratings.Any() ? ratings.Average() : 0;
    }
}