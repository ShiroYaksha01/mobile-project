import '../models/product.dart';
import '../models/order_history.dart';
import 'api_client.dart';

class OrderService {
  final ApiClient _apiClient;

  OrderService(this._apiClient);

  // ─── Cart ───────────────────────────────────────────────────

  /// Get all cart items for a user (returns Products with cartQty set)
  Future<List<Product>> getCartItems(String userId) async {
    try {
      final response = await _apiClient.get('/cart/user/$userId');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) {
          final productJson = json['product'] as Map<String, dynamic>? ?? json;
          final product = Product.fromJson(productJson);
          product.cartQty = (json['quantity'] as num?)?.toInt() ?? 1;
          return product;
        }).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load cart: $e');
    }
  }

  /// Get total count of items in cart
  Future<int> getCartCount(String userId) async {
    try {
      final items = await getCartItems(userId);
      return items.fold<int>(0, (sum, item) => sum + item.cartQty);
    } catch (e) {
      return 0;
    }
  }

  /// Add a product to the cart (POST with query params: productId, quantity)
  Future<void> addToCart(String userId, String productId, {int quantity = 1}) async {
    try {
      final response = await _apiClient.dioClient.post(
        '/cart/user/$userId',
        queryParameters: {
          'productId': productId,
          'quantity': quantity,
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to add to cart');
      }
    } catch (e) {
      throw Exception('Failed to add to cart: $e');
    }
  }

  /// Update cart item quantity (PUT with query param: quantity)
  Future<void> updateQuantity(String userId, String productId, int quantity) async {
    try {
      await _apiClient.dioClient.put(
        '/cart/user/$userId/item/$productId',
        queryParameters: {'quantity': quantity},
      );
    } catch (e) {
      throw Exception('Failed to update cart: $e');
    }
  }

  /// Remove an item from cart
  Future<void> removeItem(String userId, String productId) async {
    try {
      await _apiClient.delete('/cart/user/$userId/item/$productId');
    } catch (e) {
      throw Exception('Failed to remove cart item: $e');
    }
  }

  /// Clear all items from cart
  Future<void> clearCart(String userId) async {
    try {
      await _apiClient.delete('/cart/user/$userId/clear');
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }

  // ─── Orders ───────────────────────────────────────────────────

  /// Get order history for a user
  Future<List<OrderHistory>> getOrderHistory(String userId) async {
    try {
      final response = await _apiClient.get('/orders/user/$userId');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) {
          return OrderHistory.fromJson({
            'id': json['id'],
            'date': json['createdAt'] != null ? DateTime.parse(json['createdAt']).toLocal().toString().split(' ')[0] : '',
            'total': json['grandTotal'],
            'status': json['status'],
            'items': json['orderItems'] != null ? (json['orderItems'] as List).length : 0,
          });
        }).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load order history: $e');
    }
  }

  /// Create an order from the cart
  Future<void> createOrder(String userId, {
    String paymentMethod = "CreditCard",
    String deliveryAddress = "123 Main St",
    String deliveryMessage = "",
    String? promotionId,
  }) async {
    try {
      final response = await _apiClient.post(
        '/orders/user/$userId',
        data: {
          'paymentMethod': paymentMethod,
          'deliveryAddress': deliveryAddress,
          'deliveryMessage': deliveryMessage,
          'deliveryDate': DateTime.now().toUtc().add(const Duration(days: 3)).toIso8601String(),
          if (promotionId != null) 'promotionId': promotionId,
        },
      );
      // Depending on backend, might be 200 or 201
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to place order');
      }
    } catch (e) {
      throw Exception('Failed to place order: $e');
    }
  }
}
