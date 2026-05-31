// SavedCard.cs
namespace Souvenir_Collection_Backend.Models;

public class SavedCard
{
    [Key]
    public Guid Id { get; set; } = Guid.NewGuid();

    public Guid UserId { get; set; }
    public User User { get; set; }

    public string Gateway { get; set; } = string.Empty; 
    public string GatewayCustomerId { get; set; } = string.Empty;
    public string GatewayPaymentMethodId { get; set; } = string.Empty;

    public string CardBrand { get; set; } = string.Empty; 
    public string Last4 { get; set; } = string.Empty;
    public int ExpMonth { get; set; }
    public int ExpYear { get; set; }

    public bool IsDefault { get; set; } = false;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public ICollection<Payment> Payments { get; set; }
}