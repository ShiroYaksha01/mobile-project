namespace Sovenire_Collenction_Backend.DTOs.Artisan
{
    public class UpdateArtisanProfileRequest
    {
        public string? ShopName { get; set; }
        public string? Bio { get; set; }
        public string? ProfilePhoto { get; set; }
        public string? PhoneNumber { get; set; }
        public string? Location { get; set; }
    }

    public class UpdateArtisanRequest
    {
        public string? DisplayName { get; set; }
        public string? Region { get; set; }
        public string? CraftType { get; set; }
        public string? Bio { get; set; }
        public string? ProfilePhotoUrl { get; set; }
        public string? ShopAddress { get; set; }
        public decimal? Lat { get; set; }
        public decimal? Lng { get; set; }
        public bool? IsVerified { get; set; }
    }

    public class ArtisanDashboardDto 
    {
        public int TotalProducts { get; set; }
        public int TotalOrders { get; set; }
        public int PendingOrders { get; set; }
        public decimal TotalRevenue { get; set; }
        public int TotalReviews { get; set; }
    }
}
