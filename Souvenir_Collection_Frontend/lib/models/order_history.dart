class OrderHistory {
  final String id;
  final String date;
  final double total;
  final String status;
  final int items;

  OrderHistory({
    required this.id,
    required this.date,
    required this.total,
    required this.status,
    required this.items,
  });

  factory OrderHistory.fromJson(Map<String, dynamic> json) {
    return OrderHistory(
      id: json['id']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'Processing',
      items: (json['items'] as num?)?.toInt() ?? 0,
    );
  }
}
