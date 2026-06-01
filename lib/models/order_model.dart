class Restaurant {
  final String name;
  final String address;
  final String? phone;
  final double lat;
  final double lng;

  Restaurant({
    required this.name,
    required this.address,
    this.phone,
    required this.lat,
    required this.lng,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      name: json['name'],
      address: json['address'],
      phone: json['phone'],
      lat: (json['lat'] ?? 0).toDouble(),
      lng: (json['lng'] ?? 0).toDouble(),
    );
  }
}

class Order {
  final String id;
  final String status;
  final DateTime createdAt;
  final double deliveryFee;
  final int? estimatedTimeMinutes;
  final String customerName;
  final String customerAddress;
  final String customerPhone;
  final String? orderDetails;
  final double customerLat;
  final double customerLng;
  final Restaurant? restaurant;

  Order({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.deliveryFee,
    this.estimatedTimeMinutes,
    required this.customerName,
    required this.customerAddress,
    required this.customerPhone,
    this.orderDetails,
    required this.customerLat,
    required this.customerLng,
    this.restaurant,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      deliveryFee: (json['delivery_fee'] ?? 0).toDouble(),
      estimatedTimeMinutes: json['estimated_time_minutes'],
      customerName: json['customer_name'],
      customerAddress: json['customer_address'],
      customerPhone: json['customer_phone'],
      orderDetails: json['order_details'],
      customerLat: (json['customer_lat'] ?? 0).toDouble(),
      customerLng: (json['customer_lng'] ?? 0).toDouble(),
      restaurant: json['restaurant'] != null ? Restaurant.fromJson(json['restaurant']) : null,
    );
  }
}
