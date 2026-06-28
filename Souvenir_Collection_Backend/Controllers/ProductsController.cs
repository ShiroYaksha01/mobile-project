using Microsoft.AspNetCore.Mvc;
using Sovenire_Collenction_Backend.Helpers;
using Sovenire_Collenction_Backend.DTOs.Product;

namespace Sovenire_Collenction_Backend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ProductsController : ControllerBase
    {
        private readonly ProductService _productService;

        public ProductsController(ProductService productService)
        {
            _productService = productService;
        }

        private static ProductDto MapToDto(Product p) => new()
        {
            Id = p.Id,
            ArtisanId = p.ArtisanId,
            CategoryId = p.CategoryId,
            CategoryName = p.Category?.Name ?? string.Empty,
            CollectionId = p.CollectionId,
            Name = p.Name,
            Description = p.Description,
            Price = p.Price,
            StockQty = p.StockQty,
            Image = p.Image,
            IsAvailable = p.IsAvailable,
            CreatedAt = p.CreatedAt,
            UpdatedAt = p.UpdatedAt
        };

        // GET api/products
        [HttpGet]
        public async Task<IActionResult> GetAllProducts()
        {
            var products = await _productService.GetAllProductsAsync() ?? new List<Product>();
            var dtos = products.Select(MapToDto).ToList();
            var message = dtos.Any() ? "Products retrieved successfully." : "No products found.";
            return Ok(ApiResponse<List<ProductDto>>.SuccessResult(dtos, message));
        }

        // GET api/products/{id}
        [HttpGet("{id}")]
        public async Task<IActionResult> GetProductById(Guid id)
        {
            var product = await _productService.GetProductByIdAsync(id);
            if (product == null)
                return NotFound(ApiResponse<ProductDto>.FailureResult($"Product with ID {id} not found."));

            return Ok(ApiResponse<ProductDto>.SuccessResult(MapToDto(product), "Product details retrieved successfully."));
        }

        // GET api/products/category/{categoryId}
        [HttpGet("category/{categoryId}")]
        public async Task<IActionResult> GetProductsByCategory(Guid categoryId)
        {
            var products = await _productService.GetProductsByCategoryAsync(categoryId) ?? new List<Product>();
            var dtos = products.Select(MapToDto).ToList();
            var message = dtos.Any() ? "Products by category retrieved successfully." : $"No products found under Category ID {categoryId}.";
            return Ok(ApiResponse<List<ProductDto>>.SuccessResult(dtos, message));
        }

        // GET api/products/artisan/{artisanId}
        [HttpGet("artisan/{artisanId}")]
        public async Task<IActionResult> GetProductsByArtisan(Guid artisanId)
        {
            var products = await _productService.GetProductsByArtisanAsync(artisanId) ?? new List<Product>();
            var dtos = products.Select(MapToDto).ToList();
            var message = dtos.Any() ? "Products by artisan retrieved successfully." : $"No products found under Artisan ID {artisanId}.";
            return Ok(ApiResponse<List<ProductDto>>.SuccessResult(dtos, message));
        }

        // GET api/products/search
        [HttpGet("search")]
        public async Task<IActionResult> SearchProducts([FromQuery] string query)
        {
            if (string.IsNullOrEmpty(query))
                return BadRequest(ApiResponse<List<ProductDto>>.FailureResult("Query parameter cannot be empty."));

            var products = await _productService.SearchProductsAsync(query) ?? new List<Product>();
            var dtos = products.Select(MapToDto).ToList();
            var message = dtos.Any() ? "Products search completed successfully." : $"No products found matching the keyword '{query}'.";
            return Ok(ApiResponse<List<ProductDto>>.SuccessResult(dtos, message));
        }

        // POST api/products
        [HttpPost]
        public async Task<IActionResult> CreateProduct([FromBody] CreateProductRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ApiResponse<ProductDto>.FailureResult("Invalid request payload."));

            var (product, error) = await _productService.CreateProductAsync(request);
            if (product == null)
                return BadRequest(ApiResponse<ProductDto>.FailureResult(error ?? "Failed to create product."));

            return CreatedAtAction(nameof(GetProductById), new { id = product.Id }, ApiResponse<ProductDto>.SuccessResult(MapToDto(product), "Product created successfully."));
        }

        // PATCH api/products/{id}
        [HttpPatch("{id}")]
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateProduct(Guid id, [FromBody] UpdateProductRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ApiResponse<ProductDto>.FailureResult("Invalid request payload."));

            var product = await _productService.UpdateProductAsync(id, request);
            if (product == null)
                return NotFound(ApiResponse<ProductDto>.FailureResult($"Product with ID {id} not found or update failed."));

            return Ok(ApiResponse<ProductDto>.SuccessResult(MapToDto(product), "Product updated successfully."));
        }

        // DELETE api/products/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteProduct(Guid id)
        {
            var success = await _productService.DeleteProductAsync(id);
            if (!success)
                return NotFound(ApiResponse<List<ProductDto>>.FailureResult($"Product with ID {id} not found or delete failed."));

            var products = await _productService.GetAllProductsAsync() ?? new List<Product>();
            var dtos = products.Select(MapToDto).ToList();
            return Ok(ApiResponse<List<ProductDto>>.SuccessResult(dtos, "Product deleted successfully."));
        }
    }
}
