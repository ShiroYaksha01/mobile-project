namespace Sovenire_Collenction_Backend.DTOs.Collection
{
    public class CreateCollectionRequest
    {
        public string Title { get; set; } = string.Empty;
        public string Slug { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public string Type { get; set; } = string.Empty;
        public string Image { get; set; } = string.Empty;
    }

    public class UpdateCollectionRequest : CreateCollectionRequest {}
}
