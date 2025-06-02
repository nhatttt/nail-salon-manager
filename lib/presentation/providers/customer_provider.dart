import 'package:flutter/foundation.dart';
import '../../core/utils/phone_formatter.dart';
import '../../data/models/customer.dart';
import '../../data/repositories/salon_repository.dart';

class CustomerProvider with ChangeNotifier {
  final SalonRepository _repository = SalonRepository();
  List<Customer> _customers = [];
  bool _isLoading = false;
  String? _error;

  List<Customer> get customers => _customers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get all customers
  Future<void> loadCustomers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _customers = _repository.getAllCustomers();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Get customer by ID
  Customer? getCustomerById(String id) {
    return _repository.getCustomerById(id);
  }

  // Add a new customer
  Future<void> addCustomer(Customer customer) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.addCustomer(customer);
      _customers = _repository.getAllCustomers();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Update an existing customer
  Future<void> updateCustomer(Customer customer) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateCustomer(customer);
      _customers = _repository.getAllCustomers();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Delete a customer
  Future<void> deleteCustomer(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteCustomer(id);
      _customers = _repository.getAllCustomers();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Search customers by name or phone number
  List<Customer> searchCustomers(String query) {
    if (query.isEmpty) {
      return _customers;
    }
    
    // Strip non-digit characters from the query if it looks like a phone number
    final digitsOnly = PhoneFormatter.extractDigitsOnly(query);
    final lowercaseQuery = query.toLowerCase();
    
    return _customers.where((customer) {
      // Check if name contains the query
      final nameMatch = customer.name.toLowerCase().contains(lowercaseQuery);
      
      // Check if phone number contains the query
      // First try with the formatted phone number
      final formattedPhone = PhoneFormatter.formatPhone(customer.phoneNumber);
      final phoneMatch = formattedPhone.contains(query);
      
      // Then try with just the digits
      final customerPhoneDigits = PhoneFormatter.extractDigitsOnly(customer.phoneNumber);
      final phoneDigitsMatch = digitsOnly.isNotEmpty && 
          customerPhoneDigits.contains(digitsOnly);
      
      return nameMatch || phoneMatch || phoneDigitsMatch;
    }).toList();
  }
}
