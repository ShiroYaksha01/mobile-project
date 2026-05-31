namespace Sovenire_Collenction_Backend.Models
{
    public class Promotion
    {
        [Key]
        public Guid Id { get; set; } = Guid.NewGuid();

        [Required]
        [MaxLength(150)]
        public string Title { get; set; } = string.Empty;

        [Required]
        [MaxLength(50)]
        public string Code { get; set; } = string.Empty;

        public string Description { get; set; } = string.Empty;

        public string Image { get; set; } = string.Empty;

        public DiscountType DiscountType { get; set; } = DiscountType.Percentage;

        [Required]
        [Column(TypeName = "decimal(10,2)")]
        public decimal Discount { get; set; } = 0.00m;

        
        [Required]
        public int UsageLimit { get; set; } = 0;

        [Required]
        public int UsageCount { get; set; } = 0;


        public PromotionStatus Status { get; set; } = PromotionStatus.Inactive;

        [Required]
        public DateTime StartDate { get; set; }   

        [Required]
        public DateTime EndDate { get; set; }    

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    }
}