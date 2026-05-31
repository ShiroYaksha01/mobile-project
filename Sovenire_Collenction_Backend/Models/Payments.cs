// Payment.cs
namespace Souvenir_Collection_Backend.Models;

public class Payment
{
    [Key]
    public Guid Id { get; set; } = Guid.NewGuid();

    public Guid OrderId { get; set; }
    public Order Order { get; set; }

    public Guid UserId { get; set; }
    public User User { get; set; }

    public Guid? SavedCardId { get; set; }
    public SavedCard SavedCard { get; set; }

    public string Method { get; set; } = string.Empty; 
    public PaymentStatus Status { get; set; } = PaymentStatus.Pending;

    [Column(TypeName = "decimal(10,2)")]
    public decimal Amount { get; set; }

    public string Currency { get; set; } = "USD";
    public string Gateway { get; set; } = string.Empty;
    public string GatewayTxnId { get; set; } = string.Empty;
    public string GatewayResponse { get; set; } = string.Empty;

    public DateTime? PaidAt { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}