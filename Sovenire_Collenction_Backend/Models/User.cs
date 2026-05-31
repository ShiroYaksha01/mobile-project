using Supabase.Postgrest.Models;

namespace Sovenire_Collenction_Backend.Models
{
    [Supabase.Postgrest.Attributes.Table("users")]
    public class User : BaseModel
    {
        [Supabase.Postgrest.Attributes.PrimaryKey("id", false)]
        public Guid Id { get; set; } = Guid.NewGuid();

        [Supabase.Postgrest.Attributes.Column("name")]
        public string Name { get; set; } = string.Empty;

        [Supabase.Postgrest.Attributes.Column("email")]
        public string Email { get; set; } = string.Empty;

        [Supabase.Postgrest.Attributes.Column("password_hash")]
        public string PasswordHash { get; set; } = string.Empty;

        [Supabase.Postgrest.Attributes.Column("role")]
        [Newtonsoft.Json.JsonConverter(typeof(Newtonsoft.Json.Converters.StringEnumConverter))]
        [System.Text.Json.Serialization.JsonConverter(typeof(System.Text.Json.Serialization.JsonStringEnumConverter))]
        public UserRole Role { get; set; } = UserRole.Customer;

        [Supabase.Postgrest.Attributes.Column("phone")]
        public string Phone { get; set; } = string.Empty;

        [Supabase.Postgrest.Attributes.Column("address")]
        public string Address { get; set; } = string.Empty;

        [Supabase.Postgrest.Attributes.Column("avatar")]
        public string Avatar { get; set; } = string.Empty;

        [Supabase.Postgrest.Attributes.Column("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [Supabase.Postgrest.Attributes.Column("updated_at")]
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        
        // Navigation properties (not mapped directly by Postgrest column attributes)
        [Newtonsoft.Json.JsonIgnore]
        [System.Text.Json.Serialization.JsonIgnore]
        public Artisan? Artisan { get; set; }

        [Newtonsoft.Json.JsonIgnore]
        [System.Text.Json.Serialization.JsonIgnore]
        public ICollection<Order> Orders { get; set; } = new List<Order>();

        [Newtonsoft.Json.JsonIgnore]
        [System.Text.Json.Serialization.JsonIgnore]
        public ICollection<Favorite> Favorites { get; set; } = new List<Favorite>();

        [Newtonsoft.Json.JsonIgnore]
        [System.Text.Json.Serialization.JsonIgnore]
        public ICollection<Review> Reviews { get; set; } = new List<Review>();

        [Newtonsoft.Json.JsonIgnore]
        [System.Text.Json.Serialization.JsonIgnore]
        public ICollection<CartItem> CartItems { get; set; } = new List<CartItem>();
    }
}