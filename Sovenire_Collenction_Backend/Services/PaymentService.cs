using Microsoft.EntityFrameworkCore;
using Souvenir_Collection_Backend.Models;

namespace Souvenir_Collection_Backend.Services;

public class PaymentService
{
    private readonly ApplicationDbContext _context;

    public PaymentService(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<List<Payment>> GetAllPaymentsAsync()
    {
        return await _context.Payments
            .Include(p => p.Order)
            .Include(p => p.User)
            .Include(p => p.SavedCard)
            .OrderByDescending(p => p.CreatedAt)
            .ToListAsync();
    }

    public async Task<Payment?> GetPaymentByIdAsync(Guid id)
    {
        return await _context.Payments
            .Include(p => p.Order)
            .Include(p => p.User)
            .Include(p => p.SavedCard)
            .FirstOrDefaultAsync(p => p.Id == id);
    }

    public async Task<List<Payment>> GetPaymentsByUserIdAsync(Guid userId)
    {
        return await _context.Payments
            .Include(p => p.Order)
            .Include(p => p.SavedCard)
            .Where(p => p.UserId == userId)
            .OrderByDescending(p => p.CreatedAt)
            .ToListAsync();
    }

    public async Task<List<Payment>> GetPaymentsByOrderIdAsync(Guid orderId)
    {
        return await _context.Payments
            .Include(p => p.User)
            .Include(p => p.SavedCard)
            .Where(p => p.OrderId == orderId)
            .ToListAsync();
    }

    public async Task<List<Payment>> GetPaymentsByStatusAsync(PaymentStatus status)
    {
        return await _context.Payments
            .Include(p => p.Order)
            .Include(p => p.User)
            .Where(p => p.Status == status)
            .OrderByDescending(p => p.CreatedAt)
            .ToListAsync();
    }

    public async Task<Payment> CreatePaymentAsync(Payment payment)
    {
        _context.Payments.Add(payment);
        await _context.SaveChangesAsync();
        return payment;
    }

    public async Task<Payment?> UpdatePaymentStatusAsync(Guid id, PaymentStatus status)
    {
        var payment = await _context.Payments.FindAsync(id);
        if (payment == null) return null;

        payment.Status = status;
        if (status == PaymentStatus.Paid)
            payment.PaidAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();
        return payment;
    }

    public async Task<Payment?> UpdateGatewayResponseAsync(Guid id, string gatewayTxnId, string gatewayResponse)
    {
        var payment = await _context.Payments.FindAsync(id);
        if (payment == null) return null;

        payment.GatewayTxnId = gatewayTxnId;
        payment.GatewayResponse = gatewayResponse;

        await _context.SaveChangesAsync();
        return payment;
    }

    public async Task<bool> DeletePaymentAsync(Guid id)
    {
        var payment = await _context.Payments.FindAsync(id);
        if (payment == null) return false;

        _context.Payments.Remove(payment);
        await _context.SaveChangesAsync();
        return true;
    }
}