namespace Souvenir_Collection_Backend.Services
{
    public class PromotionService
    {
        private readonly AppDbContext _context;

        public PromotionService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<List<Promotion>> GetAllPromotionsAsync()
        {
            return await _context.Promotions
                .OrderByDescending(p => p.CreatedAt)
                .ToListAsync();
        }
        public async Task<Promotion> GetPromotionByIdAsync(Guid promotionId)
        {
            return await _context.Promotions
                .FirstOrDefaultAsync(p => p.Id == promotionId);
        }

        public async Task<List<Promotion>> GetActivePromotionsAsync()
        {
            return await _context.Promotions
                .Where(p => p.Status == PromotionStatus.Active &&
                            p.StartDate <= DateTime.UtcNow &&
                            p.EndDate >= DateTime.UtcNow &&
                            p.UsageCount < p.UsageLimit)
                .OrderByDescending(p => p.StartDate)
                .ToListAsync();
        }

        public async Task<decimal> ValidatePromoCodeAsync(string code, decimal subTotal)
        {
            var promotion = await _context.Promotions
                .FirstOrDefaultAsync(p => p.Code == code &&
                                         p.Status == PromotionStatus.Active &&
                                         p.StartDate <= DateTime.UtcNow &&
                                         p.EndDate >= DateTime.UtcNow &&
                                         p.UsageCount < p.UsageLimit);

            if (promotion == null) return 0;

            var discountAmount = promotion.DiscountType == DiscountType.Percentage
                ? subTotal * (promotion.Discount / 100)
                : promotion.Discount;

            return discountAmount;
        }

        public async Task<Promotion> CreatePromotionAsync(CreatePromotionRequest request)
        {
            var codeExists = await _context.Promotions
                .AnyAsync(p => p.Code == request.Code);
            if (codeExists) return null;

            if (request.StartDate >= request.EndDate) return null;

            var promotion = new Promotion
            {
                Title       = request.Title,
                Code        = request.Code,
                Description = request.Description,
                Image       = request.Image,
                DiscountType= request.DiscountType,
                Discount    = request.Discount,
                UsageLimit  = request.UsageLimit,
                UsageCount  = 0,
                Status      = PromotionStatus.Inactive,
                StartDate   = request.StartDate,
                EndDate     = request.EndDate,
                CreatedAt   = DateTime.UtcNow,
                UpdatedAt   = DateTime.UtcNow
            };

            await _context.Promotions.AddAsync(promotion);
            await _context.SaveChangesAsync();
            return promotion;
        }

        public async Task<bool> UpdatePromotionAsync(Guid promotionId, UpdatePromotionRequest request)
        {
            var promotion = await _context.Promotions.FindAsync(promotionId);
            if (promotion == null) return false;

            var codeExists = await _context.Promotions
                .AnyAsync(p => p.Code == request.Code && p.Id != promotionId);
            if (codeExists) return false;

            if (request.StartDate >= request.EndDate) return false;

            promotion.Title        = request.Title;
            promotion.Code         = request.Code;
            promotion.Description  = request.Description;
            promotion.Image        = request.Image;
            promotion.DiscountType = request.DiscountType;
            promotion.Discount     = request.Discount;
            promotion.UsageLimit   = request.UsageLimit;
            promotion.StartDate    = request.StartDate;
            promotion.EndDate      = request.EndDate;
            promotion.UpdatedAt    = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> DeletePromotionAsync(Guid promotionId)
        {
            var promotion = await _context.Promotions.FindAsync(promotionId);
            if (promotion == null) return false;

            _context.Promotions.Remove(promotion);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> ActivatePromotionAsync(Guid promotionId)
        {
            var promotion = await _context.Promotions.FindAsync(promotionId);
            if (promotion == null) return false;

            if (promotion.EndDate < DateTime.UtcNow) return false;

            promotion.Status    = PromotionStatus.Active;
            promotion.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> DeactivatePromotionAsync(Guid promotionId)
        {
            var promotion = await _context.Promotions.FindAsync(promotionId);
            if (promotion == null) return false;

            promotion.Status    = PromotionStatus.Inactive;
            promotion.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> ApplyPromoCodeAsync(string code)
        {
            var promotion = await _context.Promotions
                .FirstOrDefaultAsync(p => p.Code == code &&
                                         p.Status == PromotionStatus.Active &&
                                         p.UsageCount < p.UsageLimit);

            if (promotion == null) return false;

            promotion.UsageCount += 1;
            promotion.UpdatedAt   = DateTime.UtcNow;

            if (promotion.UsageCount >= promotion.UsageLimit)
            {
                promotion.Status = PromotionStatus.Inactive;
            }

            await _context.SaveChangesAsync();
            return true;
        }
    }
}