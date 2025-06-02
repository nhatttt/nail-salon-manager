import 'package:flutter/foundation.dart';
import '../../data/models/appointment.dart';
import '../../data/repositories/salon_repository.dart';

class AppointmentProvider with ChangeNotifier {
  final SalonRepository _repository = SalonRepository();
  List<Appointment> _appointments = [];
  bool _isLoading = false;
  String? _error;
  DateTime _selectedDate = DateTime.now();

  List<Appointment> get appointments => _appointments;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime get selectedDate => _selectedDate;

  // Set selected date
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    loadAppointmentsByDate(date);
  }

  // Get all appointments
  Future<void> loadAllAppointments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _appointments = _repository.getAllAppointments();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Get appointments for a specific date
  Future<void> loadAppointmentsByDate(DateTime date) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _appointments = _repository.getAppointmentsByDate(date);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Get appointment by ID
  Appointment? getAppointmentById(String id) {
    return _repository.getAppointmentById(id);
  }

  // Get appointments for a specific employee
  List<Appointment> getAppointmentsByEmployee(String employeeId) {
    return _repository.getAppointmentsByEmployee(employeeId);
  }

  // Get appointments for a specific customer
  List<Appointment> getAppointmentsByCustomer(String customerId) {
    return _repository.getAppointmentsByCustomer(customerId);
  }

  // Add a new appointment
  Future<void> addAppointment(Appointment appointment) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.addAppointment(appointment);
      _appointments = _repository.getAppointmentsByDate(_selectedDate);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Update an existing appointment
  Future<void> updateAppointment(Appointment appointment) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateAppointment(appointment);
      _appointments = _repository.getAppointmentsByDate(_selectedDate);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Delete an appointment
  Future<void> deleteAppointment(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteAppointment(id);
      _appointments = _repository.getAppointmentsByDate(_selectedDate);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Update appointment status
  Future<void> updateAppointmentStatus(String id, AppointmentStatus status) async {
    final appointment = getAppointmentById(id);
    if (appointment != null) {
      final updatedAppointment = appointment.copyWith(status: status);
      await updateAppointment(updatedAppointment);
    }
  }

  // Mark appointment as paid
  Future<void> markAppointmentAsPaid(String id) async {
    final appointment = getAppointmentById(id);
    if (appointment != null) {
      final updatedAppointment = appointment.copyWith(isPaid: true);
      await updateAppointment(updatedAppointment);
    }
  }

  // Calculate daily revenue
  double calculateDailyRevenue(DateTime date) {
    return _repository.calculateDailyRevenue(date);
  }

  // Get appointments by status
  List<Appointment> getAppointmentsByStatus(AppointmentStatus status) {
    return _appointments.where((a) => a.status == status).toList();
  }

  // Check if a time slot is available for an employee
  bool isTimeSlotAvailable(String employeeId, DateTime startTime, DateTime endTime, {String? excludeAppointmentId}) {
    // If no employee ID is provided (unassigned appointment), always return true
    if (employeeId.isEmpty) {
      return true;
    }
    
    final employeeAppointments = getAppointmentsByEmployee(employeeId);
    
    for (final appointment in employeeAppointments) {
      // Skip the current appointment if we're checking for an update
      if (excludeAppointmentId != null && appointment.id == excludeAppointmentId) {
        continue;
      }
      
      // Check if the appointment overlaps with the requested time slot
      // Note: We no longer need to check for cancelled appointments since they are deleted
      if (appointment.status != AppointmentStatus.noShow) {
        if ((startTime.isAfter(appointment.startTime) && 
             startTime.isBefore(appointment.endTime)) ||
            (endTime.isAfter(appointment.startTime) && 
             endTime.isBefore(appointment.endTime)) ||
            (startTime.isBefore(appointment.startTime) && 
             endTime.isAfter(appointment.endTime)) ||
            (startTime.isAtSameMomentAs(appointment.startTime) || 
             endTime.isAtSameMomentAs(appointment.endTime))) {
          return false;
        }
      }
    }
    
    return true;
  }
}
