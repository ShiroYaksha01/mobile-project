using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Souvenir_Collection_Backend.Models
{
    public class Order
    {
        [Key]
        public Guid Id { get; set; } = Guid.NewGuid();

        public Guid UserId { get; set; }
        [ForeignKey(nameof(UserId))]
        public User? User { get; set; }

        public OrderStatus Status { get; set; } = OrderStatus.Pending;

        [Column(TypeName = "decimal(10,2)")]
        public decimal SubTotal { get; set; } = 0.00m;

        [Column(TypeName = "decimal(10,2)")]
        public decimal DiscountAmount { get; set; } = 0.00m;

        [Column(TypeName = "decimal(10,2)")]
        public decimal GrandTotal { get; set; } = 0.00m;

        public string PaymentMethod { get; set; } = string.Empty;

        public string DeliveryMessage { get; set; } = string.Empty;

        public DateTime DeliveryDate { get; set; }

        [Required]
        public string DeliveryAddress { get; set; } = string.Empty;

        public Guid? PromotionId { get; set; }
        [ForeignKey(nameof(PromotionId))]
        public Promotion? Promotion { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        public ICollection<OrderItem> OrderItems { get; set; }
        public Payment? Payment { get; set; }
    }
}