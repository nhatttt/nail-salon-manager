class Customer {
  final String id;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String email;
  final List<String> appointmentIds; // IDs of past and upcoming appointments
  final Map<String, dynamic> preferences; // Customer preferences
  final String notes; // Additional notes about the customer

  Customer({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.email,
    required this.appointmentIds,
    required this.preferences,
    required this.notes,
  });

  // Get full name
  String get name => lastName.isEmpty ? firstName : '$firstName $lastName';

  // Create a copy of the customer with some fields changed
  Customer copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? email,
    List<String>? appointmentIds,
    Map<String, dynamic>? preferences,
    String? notes,
  }) {
    return Customer(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      appointmentIds: appointmentIds ?? this.appointmentIds,
      preferences: preferences ?? this.preferences,
      notes: notes ?? this.notes,
    );
  }

  // Convert customer to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'email': email,
      'appointmentIds': appointmentIds,
      'preferences': preferences,
      'notes': notes,
    };
  }

  // Create customer from a map
  factory Customer.fromMap(Map<String, dynamic> map) {
    // Handle legacy data that might have only 'name' field
    String firstName = '';
    String lastName = '';
    
    if (map.containsKey('firstName')) {
      firstName = map['firstName'] ?? '';
      lastName = map['lastName'] ?? '';
    } else if (map.containsKey('name')) {
      // Split the name into first and last name
      final nameParts = (map['name'] as String).split(' ');
      firstName = nameParts.first;
      lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
    }
    
    return Customer(
      id: map['id'] ?? '',
      firstName: firstName,
      lastName: lastName,
      phoneNumber: map['phoneNumber'] ?? '',
      email: map['email'] ?? '',
      appointmentIds: List<String>.from(map['appointmentIds'] ?? []),
      preferences: Map<String, dynamic>.from(map['preferences'] ?? {}),
      notes: map['notes'] ?? '',
    );
  }

  @override
  String toString() {
    return 'Customer(id: $id, name: $name, phone: $phoneNumber)';
  }
}
