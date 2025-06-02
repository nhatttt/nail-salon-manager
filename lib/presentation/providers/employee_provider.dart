import 'package:flutter/foundation.dart';
import '../../core/utils/phone_formatter.dart';
import '../../data/models/employee.dart';
import '../../data/repositories/salon_repository.dart';

class EmployeeProvider with ChangeNotifier {
  final SalonRepository _repository = SalonRepository();
  List<Employee> _employees = [];
  bool _isLoading = false;
  String? _error;

  List<Employee> get employees => _employees;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get all employees
  Future<void> loadEmployees() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _employees = _repository.getAllEmployees();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Get employee by ID
  Employee? getEmployeeById(String id) {
    return _repository.getEmployeeById(id);
  }

  // Add a new employee
  Future<void> addEmployee(Employee employee) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.addEmployee(employee);
      _employees = _repository.getAllEmployees();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Update an existing employee
  Future<void> updateEmployee(Employee employee) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateEmployee(employee);
      _employees = _repository.getAllEmployees();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Delete an employee
  Future<void> deleteEmployee(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteEmployee(id);
      _employees = _repository.getAllEmployees();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Calculate employee earnings for a given period
  double calculateEmployeeEarnings(String employeeId, DateTime startDate, DateTime endDate) {
    return _repository.calculateEmployeeEarnings(employeeId, startDate, endDate);
  }

  // Get employees who can perform a specific service
  List<Employee> getEmployeesForService(String serviceId) {
    return _employees.where((e) => e.serviceIds.contains(serviceId)).toList();
  }
  
  // Search employees by name or phone number
  List<Employee> searchEmployees(String query) {
    if (query.isEmpty) {
      return _employees;
    }
    
    // Strip non-digit characters from the query if it looks like a phone number
    final digitsOnly = PhoneFormatter.extractDigitsOnly(query);
    final lowercaseQuery = query.toLowerCase();
    
    return _employees.where((employee) {
      // Check if name contains the query
      final nameMatch = employee.name.toLowerCase().contains(lowercaseQuery);
      
      // Check if phone number contains the query
      // First try with the formatted phone number
      final formattedPhone = PhoneFormatter.formatPhone(employee.phoneNumber);
      final phoneMatch = formattedPhone.contains(query);
      
      // Then try with just the digits
      final employeePhoneDigits = PhoneFormatter.extractDigitsOnly(employee.phoneNumber);
      final phoneDigitsMatch = digitsOnly.isNotEmpty && 
          employeePhoneDigits.contains(digitsOnly);
      
      return nameMatch || phoneMatch || phoneDigitsMatch;
    }).toList();
  }
}
