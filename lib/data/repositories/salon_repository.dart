import 'package:uuid/uuid.dart';

import '../models/appointment.dart';
import '../models/customer.dart';
import '../models/employee.dart';
import '../models/service.dart';

class SalonRepository {
  // Singleton pattern
  static final SalonRepository _instance = SalonRepository._internal();
  factory SalonRepository() => _instance;
  SalonRepository._internal();

  // In-memory storage
  final List<Service> _services = [];
  final List<Employee> _employees = [];
  final List<Customer> _customers = [];
  final List<Appointment> _appointments = [];

  // UUID generator
  final _uuid = const Uuid();

  // Initialize with mock data
  Future<void> initialize() async {
    // Add mock services
    _services.addAll([
      Service(
        id: _uuid.v4(),
        name: 'Basic Manicure',
        description: 'Nail shaping, cuticle care, and polish application.',
        price: 25.0,
        durationMinutes: 30,
        category: 'Manicure',
      ),
      Service(
        id: _uuid.v4(),
        name: 'Gel Manicure',
        description: 'Nail shaping, cuticle care, and gel polish application.',
        price: 35.0,
        durationMinutes: 45,
        category: 'Manicure',
      ),
      Service(
        id: _uuid.v4(),
        name: 'Basic Pedicure',
        description: 'Foot soak, nail shaping, cuticle care, and polish application.',
        price: 35.0,
        durationMinutes: 45,
        category: 'Pedicure',
      ),
      Service(
        id: _uuid.v4(),
        name: 'Deluxe Pedicure',
        description: 'Foot soak, exfoliation, massage, nail shaping, cuticle care, and polish application.',
        price: 50.0,
        durationMinutes: 60,
        category: 'Pedicure',
      ),
      Service(
        id: _uuid.v4(),
        name: 'Acrylic Full Set',
        description: 'Application of acrylic nails.',
        price: 60.0,
        durationMinutes: 75,
        category: 'Enhancements',
      ),
      Service(
        id: _uuid.v4(),
        name: 'Acrylic Fill',
        description: 'Fill-in for acrylic nails.',
        price: 40.0,
        durationMinutes: 60,
        category: 'Enhancements',
      ),
      Service(
        id: _uuid.v4(),
        name: 'Nail Art (per nail)',
        description: 'Custom nail art design.',
        price: 5.0,
        durationMinutes: 10,
        category: 'Add-ons',
      ),
    ]);

    // Add mock employees
    final employeeIds = [_uuid.v4(), _uuid.v4(), _uuid.v4()];
    _employees.addAll([
      Employee(
        id: employeeIds[0],
        name: 'Ivan Nguyen',
        phoneNumber: '555-123-4567',
        email: 'jane@nailsalon.com',
        role: 'Nail Technician',
        serviceIds: _services.map((s) => s.id).toList(),
        paymentInfo: {
          'method': 'Direct Deposit',
          'accountNumber': 'XXXX1234',
          'commissionRate': 0.6,
        },
      ),
      Employee(
        id: employeeIds[1],
        name: 'Michael Johnson',
        phoneNumber: '555-234-5678',
        email: 'michael@nailsalon.com',
        role: 'Nail Technician',
        serviceIds: _services.where((s) => s.category != 'Enhancements').map((s) => s.id).toList(),
        paymentInfo: {
          'method': 'Check',
          'commissionRate': 0.55,
        },
      ),
      Employee(
        id: employeeIds[2],
        name: 'Sarah Lee',
        phoneNumber: '555-345-6789',
        email: 'sarah@nailsalon.com',
        role: 'Manager',
        serviceIds: _services.map((s) => s.id).toList(),
        paymentInfo: {
          'method': 'Direct Deposit',
          'accountNumber': 'XXXX5678',
          'salary': 4000.0,
        },
      ),
    ]);

    // Add mock customers
    final customerIds = [_uuid.v4(), _uuid.v4(), _uuid.v4(), _uuid.v4()];
    _customers.addAll([
      Customer(
        id: customerIds[0],
        firstName: 'Emily',
        lastName: 'Wilson',
        phoneNumber: '555-456-7890',
        email: 'emily@example.com',
        appointmentIds: [],
        preferences: {
          'favoritePolishColor': 'Red',
          'allergies': 'None',
          'preferredTechnician': employeeIds[0],
        },
        notes: 'Prefers gel polish.',
      ),
      Customer(
        id: customerIds[1],
        firstName: 'David',
        lastName: 'Brown',
        phoneNumber: '555-567-8901',
        email: 'david@example.com',
        appointmentIds: [],
        preferences: {
          'favoritePolishColor': 'Clear',
          'allergies': 'Latex',
          'preferredTechnician': employeeIds[1],
        },
        notes: 'Usually comes in for basic manicures.',
      ),
      Customer(
        id: customerIds[2],
        firstName: 'Sophia',
        lastName: 'Martinez',
        phoneNumber: '555-678-9012',
        email: 'sophia@example.com',
        appointmentIds: [],
        preferences: {
          'favoritePolishColor': 'Pink',
          'allergies': 'None',
          'preferredTechnician': employeeIds[0],
        },
        notes: 'Regular client, comes in every 2 weeks for gel manicure.',
      ),
      Customer(
        id: customerIds[3],
        firstName: 'James',
        lastName: 'Taylor',
        phoneNumber: '555-789-0123',
        email: 'james@example.com',
        appointmentIds: [],
        preferences: {
          'favoritePolishColor': 'Black',
          'allergies': 'None',
          'preferredTechnician': employeeIds[1],
        },
        notes: 'Prefers pedicures.',
      ),
    ]);

    // Add mock appointments
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Create appointments for today
    final appointment1Id = _uuid.v4();
    final appointment2Id = _uuid.v4();
    final appointment3Id = _uuid.v4();
    
    _appointments.addAll([
      Appointment(
        id: appointment1Id,
        customerId: customerIds[0],
        employeeId: employeeIds[0],
        serviceIds: [_services[1].id], // Gel Manicure
        startTime: today.add(const Duration(hours: 10, minutes: 0)),
        endTime: today.add(const Duration(hours: 10, minutes: 45)),
        status: AppointmentStatus.completed,
        totalAmount: 35.0,
        isPaid: true,
        notes: '',
      ),
      Appointment(
        id: appointment2Id,
        customerId: customerIds[1],
        employeeId: employeeIds[1],
        serviceIds: [_services[2].id], // Basic Pedicure
        startTime: today.add(const Duration(hours: 11, minutes: 0)),
        endTime: today.add(const Duration(hours: 11, minutes: 45)),
        status: AppointmentStatus.confirmed,
        totalAmount: 35.0,
        isPaid: false,
        notes: '',
      ),
      Appointment(
        id: appointment3Id,
        customerId: customerIds[2],
        employeeId: employeeIds[0],
        serviceIds: [_services[4].id], // Acrylic Full Set
        startTime: today.add(const Duration(hours: 14, minutes: 0)),
        endTime: today.add(const Duration(hours: 15, minutes: 15)),
        status: AppointmentStatus.scheduled,
        totalAmount: 60.0,
        isPaid: false,
        notes: 'Client requested French tips.',
      ),
    ]);

    // Create appointments for tomorrow
    final tomorrow = today.add(const Duration(days: 1));
    final appointment4Id = _uuid.v4();
    final appointment5Id = _uuid.v4();
    
    _appointments.addAll([
      Appointment(
        id: appointment4Id,
        customerId: customerIds[3],
        employeeId: employeeIds[1],
        serviceIds: [_services[3].id], // Deluxe Pedicure
        startTime: tomorrow.add(const Duration(hours: 13, minutes: 0)),
        endTime: tomorrow.add(const Duration(hours: 14, minutes: 0)),
        status: AppointmentStatus.confirmed,
        totalAmount: 50.0,
        isPaid: false,
        notes: '',
      ),
      Appointment(
        id: appointment5Id,
        customerId: customerIds[0],
        employeeId: employeeIds[0],
        serviceIds: [_services[1].id, _services[6].id], // Gel Manicure + Nail Art
        startTime: tomorrow.add(const Duration(hours: 15, minutes: 0)),
        endTime: tomorrow.add(const Duration(hours: 16, minutes: 0)),
        status: AppointmentStatus.scheduled,
        totalAmount: 45.0, // 35 + 10 (2 nails)
        isPaid: false,
        notes: 'Nail art on 2 accent nails.',
      ),
    ]);
    
    // Create appointments for next week
    final nextWeek = today.add(const Duration(days: 7));
    final appointment6Id = _uuid.v4();
    final appointment7Id = _uuid.v4();
    final appointment8Id = _uuid.v4();
    
    _appointments.addAll([
      Appointment(
        id: appointment6Id,
        customerId: customerIds[2],
        employeeId: employeeIds[0],
        serviceIds: [_services[1].id], // Gel Manicure
        startTime: nextWeek.add(const Duration(hours: 9, minutes: 0)),
        endTime: nextWeek.add(const Duration(hours: 9, minutes: 45)),
        status: AppointmentStatus.scheduled,
        totalAmount: 35.0,
        isPaid: false,
        notes: '',
      ),
      Appointment(
        id: appointment7Id,
        customerId: customerIds[1],
        employeeId: employeeIds[1],
        serviceIds: [_services[3].id], // Deluxe Pedicure
        startTime: nextWeek.add(const Duration(hours: 11, minutes: 0)),
        endTime: nextWeek.add(const Duration(hours: 12, minutes: 0)),
        status: AppointmentStatus.scheduled,
        totalAmount: 50.0,
        isPaid: false,
        notes: '',
      ),
      Appointment(
        id: appointment8Id,
        customerId: customerIds[3],
        employeeId: employeeIds[2],
        serviceIds: [_services[4].id, _services[6].id], // Acrylic Full Set + Nail Art
        startTime: nextWeek.add(const Duration(hours: 14, minutes: 0)),
        endTime: nextWeek.add(const Duration(hours: 15, minutes: 30)),
        status: AppointmentStatus.scheduled,
        totalAmount: 70.0, // 60 + 10 (2 nails)
        isPaid: false,
        notes: 'Nail art on 2 accent nails.',
      ),
    ]);
    
    // Create appointments for next month
    final nextMonth = DateTime(today.year, today.month + 1, 15);
    final appointment9Id = _uuid.v4();
    final appointment10Id = _uuid.v4();
    
    _appointments.addAll([
      Appointment(
        id: appointment9Id,
        customerId: customerIds[0],
        employeeId: employeeIds[0],
        serviceIds: [_services[1].id, _services[2].id], // Gel Manicure + Basic Pedicure
        startTime: nextMonth.add(const Duration(hours: 10, minutes: 0)),
        endTime: nextMonth.add(const Duration(hours: 11, minutes: 30)),
        status: AppointmentStatus.scheduled,
        totalAmount: 70.0, // 35 + 35
        isPaid: false,
        notes: 'Monthly maintenance appointment.',
      ),
      Appointment(
        id: appointment10Id,
        customerId: customerIds[2],
        employeeId: employeeIds[1],
        serviceIds: [_services[5].id], // Acrylic Fill
        startTime: nextMonth.add(const Duration(hours: 14, minutes: 0)),
        endTime: nextMonth.add(const Duration(hours: 15, minutes: 0)),
        status: AppointmentStatus.scheduled,
        totalAmount: 40.0,
        isPaid: false,
        notes: '',
      ),
    ]);

    // Update customer appointment IDs
    _customers[0] = _customers[0].copyWith(
      appointmentIds: [appointment1Id, appointment5Id, appointment9Id],
    );
    _customers[1] = _customers[1].copyWith(
      appointmentIds: [appointment2Id, appointment7Id],
    );
    _customers[2] = _customers[2].copyWith(
      appointmentIds: [appointment3Id, appointment6Id, appointment10Id],
    );
    _customers[3] = _customers[3].copyWith(
      appointmentIds: [appointment4Id, appointment8Id],
    );
  }

  // Service methods
  List<Service> getAllServices() => List.unmodifiable(_services);
  Service? getServiceById(String id) {
    try {
      return _services.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }
  List<Service> getServicesByCategory(String category) => 
      _services.where((s) => s.category == category).toList();
  
  Future<Service> addService(Service service) async {
    final newService = service.copyWith(id: _uuid.v4());
    _services.add(newService);
    return newService;
  }
  
  Future<Service> updateService(Service service) async {
    final index = _services.indexWhere((s) => s.id == service.id);
    if (index >= 0) {
      _services[index] = service;
      return service;
    }
    throw Exception('Service not found');
  }
  
  Future<void> deleteService(String id) async {
    _services.removeWhere((s) => s.id == id);
  }

  // Employee methods
  List<Employee> getAllEmployees() => List.unmodifiable(_employees);
  Employee? getEmployeeById(String id) {
    try {
      return _employees.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }
  
  Future<Employee> addEmployee(Employee employee) async {
    final newEmployee = employee.copyWith(id: _uuid.v4());
    _employees.add(newEmployee);
    return newEmployee;
  }
  
  Future<Employee> updateEmployee(Employee employee) async {
    final index = _employees.indexWhere((e) => e.id == employee.id);
    if (index >= 0) {
      _employees[index] = employee;
      return employee;
    }
    throw Exception('Employee not found');
  }
  
  Future<void> deleteEmployee(String id) async {
    _employees.removeWhere((e) => e.id == id);
  }

  // Customer methods
  List<Customer> getAllCustomers() => List.unmodifiable(_customers);
  Customer? getCustomerById(String id) {
    try {
      return _customers.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
  
  Future<Customer> addCustomer(Customer customer) async {
    // Use the provided ID if it exists, otherwise generate a new one
    final newCustomer = customer.id.isNotEmpty 
        ? customer 
        : customer.copyWith(id: _uuid.v4());
    _customers.add(newCustomer);
    return newCustomer;
  }
  
  Future<Customer> updateCustomer(Customer customer) async {
    final index = _customers.indexWhere((c) => c.id == customer.id);
    if (index >= 0) {
      _customers[index] = customer;
      return customer;
    }
    throw Exception('Customer not found');
  }
  
  Future<void> deleteCustomer(String id) async {
    _customers.removeWhere((c) => c.id == id);
  }

  // Appointment methods
  List<Appointment> getAllAppointments() => List.unmodifiable(_appointments);
  Appointment? getAppointmentById(String id) {
    try {
      return _appointments.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }
  
  List<Appointment> getAppointmentsByDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return _appointments
        .where((a) => a.startTime.isAfter(startOfDay) && a.startTime.isBefore(endOfDay))
        .toList();
  }
  
  List<Appointment> getAppointmentsByEmployee(String employeeId) {
    return _appointments.where((a) => a.employeeId == employeeId).toList();
  }
  
  List<Appointment> getAppointmentsByCustomer(String customerId) {
    return _appointments.where((a) => a.customerId == customerId).toList();
  }
  
  Future<Appointment> addAppointment(Appointment appointment) async {
    // Use the provided ID if it exists, otherwise generate a new one
    final newAppointment = appointment.id.isNotEmpty 
        ? appointment 
        : appointment.copyWith(id: _uuid.v4());
    _appointments.add(newAppointment);
    
    // Update customer's appointment list
    final customer = getCustomerById(appointment.customerId);
    if (customer != null) {
      final updatedAppointmentIds = [...customer.appointmentIds, newAppointment.id];
      final updatedCustomer = customer.copyWith(appointmentIds: updatedAppointmentIds);
      await updateCustomer(updatedCustomer);
    }
    
    return newAppointment;
  }
  
  Future<Appointment> updateAppointment(Appointment appointment) async {
    final index = _appointments.indexWhere((a) => a.id == appointment.id);
    if (index >= 0) {
      _appointments[index] = appointment;
      return appointment;
    }
    throw Exception('Appointment not found');
  }
  
  Future<void> deleteAppointment(String id) async {
    final appointment = getAppointmentById(id);
    if (appointment != null) {
      // Remove appointment from customer's list
      final customer = getCustomerById(appointment.customerId);
      if (customer != null) {
        final updatedAppointmentIds = customer.appointmentIds.where((appId) => appId != id).toList();
        final updatedCustomer = customer.copyWith(appointmentIds: updatedAppointmentIds);
        await updateCustomer(updatedCustomer);
      }
      
      // Remove the appointment
      _appointments.removeWhere((a) => a.id == id);
    }
  }
  
  // Calculate total revenue for a given day
  double calculateDailyRevenue(DateTime date) {
    final appointments = getAppointmentsByDate(date);
    return appointments
        .where((a) => a.status == AppointmentStatus.completed && a.isPaid)
        .fold(0, (sum, a) => sum + a.totalAmount);
  }
  
  // Calculate employee earnings for a given period
  double calculateEmployeeEarnings(String employeeId, DateTime startDate, DateTime endDate) {
    final employee = getEmployeeById(employeeId);
    if (employee == null) return 0;
    
    // If employee is on salary, return prorated amount
    if (employee.paymentInfo.containsKey('salary')) {
      final monthlySalary = employee.paymentInfo['salary'] as double;
      final daysInPeriod = endDate.difference(startDate).inDays + 1;
      return (monthlySalary / 30) * daysInPeriod;
    }
    
    // If employee is on commission
    final commissionRate = employee.paymentInfo['commissionRate'] as double;
    final appointments = _appointments.where((a) => 
        a.employeeId == employeeId && 
        a.status == AppointmentStatus.completed &&
        a.isPaid &&
        a.startTime.isAfter(startDate) &&
        a.startTime.isBefore(endDate.add(const Duration(days: 1)))
    );
    
    return appointments.fold(0, (sum, a) => sum + (a.totalAmount * commissionRate));
  }
}
