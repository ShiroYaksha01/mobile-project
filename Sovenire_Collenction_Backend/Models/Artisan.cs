namespace Souvenir_Collection_Backend.Models;

public class Artisan
{
    [Key]
    public Guid Id { get; set; } = Guid.NewGuid();

    public Guid UserId { get; set; }
    public User User { get; set; }

    public string DisplayName { get; set; } = string.Empty;
    public string Region { get; set; } = string.Empty;
    public string CraftType { get; set; } = string.Empty;
    public string Bio { get; set; } = string.Empty;
    public string ProfilePhotoUrl { get; set; } = string.Empty;
    public string ShopAddress { get; set; } = string.Empty;

    [Column(TypeName = "decimal(9,6)")]
    public decimal Lat { get; set; }

    [Column(TypeName = "decimal(9,6)")]
    public decimal Lng { get; set; }

    public bool IsVerified { get; set; } = false;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    public ICollection<Product> Products { get; set; }
}