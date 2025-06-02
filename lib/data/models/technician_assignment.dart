import '../../data/models/employee.dart';
import '../../data/models/service.dart';

// Class to represent a technician and their assigned services
class TechnicianAssignment {
  final Employee? employee;
  final List<Service> assignedServices;
  
  TechnicianAssignment({
    this.employee,
    required this.assignedServices,
  });
  
  TechnicianAssignment copyWith({
    Employee? employee,
    List<Service>? assignedServices,
  }) {
    return TechnicianAssignment(
      employee: employee ?? this.employee,
      assignedServices: assignedServices ?? this.assignedServices,
    );
  }
}
