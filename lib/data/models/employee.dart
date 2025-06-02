class Employee {
  final String id;
  final String name;
  final String phoneNumber;
  final String email;
  final String role;
  final List<String> serviceIds; // No longer used for specialties - all employees can perform all services
  final Map<String, dynamic> paymentInfo; // Payment preferences

  Employee({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.role,
    required this.serviceIds,
    required this.paymentInfo,
  });

  // Create a copy of the employee with some fields changed
  Employee copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? email,
    String? role,
    List<String>? serviceIds,
    Map<String, dynamic>? paymentInfo,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      role: role ?? this.role,
      serviceIds: serviceIds ?? this.serviceIds,
      paymentInfo: paymentInfo ?? this.paymentInfo,
    );
  }

  // Convert employee to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'role': role,
      'serviceIds': serviceIds,
      'paymentInfo': paymentInfo,
    };
  }

  // Create employee from a map
  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? '',
      serviceIds: List<String>.from(map['serviceIds'] ?? []),
      paymentInfo: Map<String, dynamic>.from(map['paymentInfo'] ?? {}),
    );
  }

  @override
  String toString() {
    return 'Employee(id: $id, name: $name, role: $role)';
  }
}
