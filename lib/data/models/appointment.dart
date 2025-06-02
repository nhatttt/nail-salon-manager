import 'package:flutter/material.dart';

class Appointment {
  final String id;
  final String customerId;
  final String employeeId;
  final List<String> serviceIds;
  final DateTime startTime;
  final DateTime endTime;
  final AppointmentStatus status;
  final double totalAmount;
  final bool isPaid;
  final String notes;

  Appointment({
    required this.id,
    required this.customerId,
    required this.employeeId,
    required this.serviceIds,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.totalAmount,
    required this.isPaid,
    required this.notes,
  });

  // Create a copy of the appointment with some fields changed
  Appointment copyWith({
    String? id,
    String? customerId,
    String? employeeId,
    List<String>? serviceIds,
    DateTime? startTime,
    DateTime? endTime,
    AppointmentStatus? status,
    double? totalAmount,
    bool? isPaid,
    String? notes,
  }) {
    return Appointment(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      employeeId: employeeId ?? this.employeeId,
      serviceIds: serviceIds ?? this.serviceIds,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      isPaid: isPaid ?? this.isPaid,
      notes: notes ?? this.notes,
    );
  }

  // Convert appointment to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'employeeId': employeeId,
      'serviceIds': serviceIds,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
      'status': status.index,
      'totalAmount': totalAmount,
      'isPaid': isPaid,
      'notes': notes,
    };
  }

  // Create appointment from a map
  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'] ?? '',
      customerId: map['customerId'] ?? '',
      employeeId: map['employeeId'] ?? '',
      serviceIds: List<String>.from(map['serviceIds'] ?? []),
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime'] ?? 0),
      endTime: DateTime.fromMillisecondsSinceEpoch(map['endTime'] ?? 0),
      status: AppointmentStatus.values[map['status'] ?? 0],
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      isPaid: map['isPaid'] ?? false,
      notes: map['notes'] ?? '',
    );
  }
  
  // Check if the appointment has an assigned employee
  bool get hasAssignedEmployee => employeeId.isNotEmpty;

  // Get the duration of the appointment in minutes
  int get durationMinutes => endTime.difference(startTime).inMinutes;

  // Get the color associated with the appointment status
  Color get statusColor {
    switch (status) {
      case AppointmentStatus.scheduled:
        return Colors.blue;
      case AppointmentStatus.confirmed:
        return Colors.green;
      case AppointmentStatus.completed:
        return Colors.purple;
      case AppointmentStatus.cancelled:
        return Colors.red;
      case AppointmentStatus.noShow:
        return Colors.grey;
    }
  }

  @override
  String toString() {
    return 'Appointment(id: $id, status: ${status.name}, startTime: $startTime)';
  }
}

enum AppointmentStatus {
  scheduled,
  confirmed,
  completed,
  cancelled,
  noShow,
}
