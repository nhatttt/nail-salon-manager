class Service {
  final String id;
  final String name;
  final String description;
  final double price;
  final int durationMinutes;
  final String category;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationMinutes,
    required this.category,
  });

  // Create a copy of the service with some fields changed
  Service copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    int? durationMinutes,
    String? category,
  }) {
    return Service(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      category: category ?? this.category,
    );
  }

  // Convert service to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'durationMinutes': durationMinutes,
      'category': category,
    };
  }

  // Create service from a map
  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      durationMinutes: map['durationMinutes']?.toInt() ?? 0,
      category: map['category'] ?? '',
    );
  }

  @override
  String toString() {
    return 'Service(id: $id, name: $name, price: \$${price.toStringAsFixed(2)}, duration: $durationMinutes min)';
  }
}
