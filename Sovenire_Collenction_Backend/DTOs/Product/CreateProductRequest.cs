namespace Sovenire_Collenction_Backend.DTOs.Product
{
    public class CreateProductRequest
    {
        public Guid CategoryId { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public decimal Price { get; set; }
        public int StockQty { get; set; }
        public string Image { get; set; } = string.Empty;
        public bool IsAvailable { get; set; }
    }

    public class UpdateProductRequest : CreateProductRequest {}
}
