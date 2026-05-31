namespace Sovenire_Collenction_Backend.DTOs.Collection
{
    public class CreateCollectionRequest
    {
        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
    }

    public class UpdateCollectionRequest : CreateCollectionRequest {}
}
