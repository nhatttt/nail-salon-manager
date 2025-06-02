import 'package:flutter/foundation.dart';
import '../../data/models/service.dart';
import '../../data/repositories/salon_repository.dart';

class ServiceProvider with ChangeNotifier {
  final SalonRepository _repository = SalonRepository();
  List<Service> _services = [];
  bool _isLoading = false;
  String? _error;

  List<Service> get services => _services;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get all services
  Future<void> loadServices() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _services = _repository.getAllServices();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Get services by category
  List<Service> getServicesByCategory(String category) {
    return _repository.getServicesByCategory(category);
  }

  // Add a new service
  Future<void> addService(Service service) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.addService(service);
      _services = _repository.getAllServices();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Update an existing service
  Future<void> updateService(Service service) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateService(service);
      _services = _repository.getAllServices();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Delete a service
  Future<void> deleteService(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteService(id);
      _services = _repository.getAllServices();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Get unique service categories
  List<String> getUniqueCategories() {
    final categories = _services.map((s) => s.category).toSet().toList();
    categories.sort();
    return categories;
  }
}
