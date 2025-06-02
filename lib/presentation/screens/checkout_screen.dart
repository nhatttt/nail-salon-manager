import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/appointment.dart';
import '../../data/models/customer.dart';
import '../../data/models/employee.dart';
import '../../data/models/service.dart';
import '../../data/models/technician_assignment.dart';
import '../providers/appointment_provider.dart';
import '../providers/customer_provider.dart';
import '../providers/employee_provider.dart';
import '../providers/service_provider.dart';
import '../widgets/common_widgets.dart';

class CheckoutScreen extends StatefulWidget {
  final String appointmentId;
  
  const CheckoutScreen({
    super.key,
    required this.appointmentId,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();
  
  // Selected customer
  Customer? _selectedCustomer;
  
  // Selected date and time
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  
  // All available services
  List<Service> _allServices = [];
  
  // Selected services
  List<Service> _selectedServices = [];
  
  // Technicians and their assigned services
  List<TechnicianAssignment> _technicianAssignments = [];
  
  // Payment method options
  final List<String> _paymentMethods = ['Cash', 'Card'];
  String _selectedPaymentMethod = 'Card';
  
  // Tip options
  String _selectedTipOption = 'No tip';
  double _tipAmount = 0.0;
  
  // Custom tip controller
  final TextEditingController _customTipController = TextEditingController(text: '\$0.00');
  
  // Special requests
  final TextEditingController _specialRequestsController = TextEditingController();
  
  // Loading state
  bool _isLoading = false;
  
  // Appointment data
  Appointment? _appointment;
  
  @override
  void initState() {
    super.initState();
    
    // Load data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }
  
  Future<void> _loadData() async {
    final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
    final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
    final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
    final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
    
    if (customerProvider.customers.isEmpty) {
      await customerProvider.loadCustomers();
    }
    
    if (serviceProvider.services.isEmpty) {
      await serviceProvider.loadServices();
    }
    
    if (employeeProvider.employees.isEmpty) {
      await employeeProvider.loadEmployees();
    }
    
    // Load appointment data
    final appointment = appointmentProvider.getAppointmentById(widget.appointmentId);
    
    if (appointment != null) {
      // Load customer
      final customer = customerProvider.getCustomerById(appointment.customerId);
      
      // Load all available services
      _allServices = serviceProvider.services;
      
      // Load initially selected services from appointment
      final initialServices = appointment.serviceIds.map((id) {
        return serviceProvider.services.firstWhere(
          (s) => s.id == id,
          orElse: () => Service(
            id: '',
            name: '',
            description: '',
            price: 0,
            durationMinutes: 0,
            category: '',
          ),
        );
      }).where((service) => service.id.isNotEmpty).toList();
      
      // Load employee if assigned
      Employee? employee;
      if (appointment.employeeId.isNotEmpty) {
        employee = employeeProvider.getEmployeeById(appointment.employeeId);
      }
      
      // Create initial technician assignment
      final initialAssignment = _createTechnicianAssignment(
        employee: employee,
        assignedServices: [...initialServices],
      );
      
      setState(() {
        _appointment = appointment;
        _selectedCustomer = customer;
        _selectedDate = appointment.startTime;
        _selectedTime = TimeOfDay(
          hour: appointment.startTime.hour,
          minute: appointment.startTime.minute,
        );
        _selectedServices = initialServices;
        _technicianAssignments = [initialAssignment];
        _specialRequestsController.text = appointment.notes;
      });
    }
  }
  
  @override
  void dispose() {
    _specialRequestsController.dispose();
    _customTipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Wrap with Material to provide MaterialLocalizations
    return Material(
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text('Checkout'),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildCustomerInfo(),
                const SizedBox(height: 24),
                _buildDateTimeInfo(),
                const SizedBox(height: 24),
                _buildServicesInfo(),
                const SizedBox(height: 24),
                _buildTechnicianAssignments(),
                const SizedBox(height: 24),
                _buildSpecialRequests(),
                const SizedBox(height: 24),
                _buildPaymentMethodSection(),
                const SizedBox(height: 24),
                _buildTotalSection(),
                const SizedBox(height: 32),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildCustomerInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Customer'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.lightGrey,
            borderRadius: BorderRadius.circular(8),
          ),
          width: double.infinity,
          child: Text(
            _selectedCustomer?.name ?? 'Unknown Customer',
            style: const TextStyle(color: AppTheme.black),
          ),
        ),
      ],
    );
  }
  
  Widget _buildDateTimeInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Date & Time'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.lightGrey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  DateFormat('MMM d, yyyy').format(_selectedDate),
                  style: const TextStyle(color: AppTheme.black),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.lightGrey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _selectedTime.format(context),
                  style: const TextStyle(color: AppTheme.black),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildServicesInfo() {
    // Group services by category
    final servicesByCategory = <String, List<Service>>{};
    for (final service in _allServices) {
      if (!servicesByCategory.containsKey(service.category)) {
        servicesByCategory[service.category] = [];
      }
      servicesByCategory[service.category]!.add(service);
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SectionHeader(title: 'Services'),
            Text(
              '${_selectedServices.length} selected',
              style: TextStyle(
                color: AppTheme.darkGrey,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...servicesByCategory.entries.map((entry) {
          final category = entry.key;
          final services = entry.value;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 8, top: 8),
                child: Text(
                  category,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: services.map((service) {
                  final isSelected = _selectedServices.contains(service);
                  
                  return GestureDetector(
                    onTap: () => _toggleServiceSelection(service),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.mintGreen : AppTheme.lightGrey,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppTheme.mintGreen : AppTheme.mediumGrey,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            service.name,
                            style: TextStyle(
                              color: isSelected ? AppTheme.black : AppTheme.darkGrey,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '\$${service.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: isSelected ? AppTheme.black : AppTheme.darkGrey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }
  
  void _toggleServiceSelection(Service service) {
    setState(() {
      if (_selectedServices.contains(service)) {
        // Check if the service is assigned to any technician
        bool isAssigned = false;
        for (final assignment in _technicianAssignments) {
          if (assignment.assignedServices.contains(service)) {
            isAssigned = true;
            break;
          }
        }
        
        // If assigned, show a warning dialog
        if (isAssigned) {
          _showErrorDialog(
            'This service is assigned to a technician. Please remove the assignment first.'
          );
          return;
        }
        
        // Remove the service
        _selectedServices.remove(service);
      } else {
        // Add the service
        _selectedServices.add(service);
      }
    });
  }
  
  Widget _buildTechnicianAssignments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SectionHeader(title: 'Nail Technician(s)'),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _addTechnician,
              child: const Row(
                children: [
                  Icon(CupertinoIcons.add_circled, color: AppTheme.mintGreen),
                  SizedBox(width: 4),
                  Text(
                    'Add Technician',
                    style: TextStyle(
                      color: AppTheme.mintGreen,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._technicianAssignments.asMap().entries.map((entry) {
          final index = entry.key;
          final assignment = entry.value;
          return _buildTechnicianAssignmentCard(assignment, index);
        }),
      ],
    );
  }
  
  Widget _buildTechnicianAssignmentCard(TechnicianAssignment assignment, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.lightGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Technician ${index + 1}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              if (_technicianAssignments.length > 1)
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => _removeTechnician(index),
                  child: const Icon(
                    CupertinoIcons.xmark_circle,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => _showEmployeePicker(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.lightGrey,
                borderRadius: BorderRadius.circular(8),
              ),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    assignment.employee?.name ?? 'Select Technician',
                    style: TextStyle(
                      color: assignment.employee != null ? AppTheme.black : AppTheme.darkGrey,
                    ),
                  ),
                  const Icon(
                    CupertinoIcons.chevron_down,
                    color: AppTheme.darkGrey,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Assigned Services:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedServices.map((service) {
              final isAssigned = assignment.assignedServices.contains(service);
              final isDisabled = !isAssigned && _isServiceAssignedToOtherTechnician(service, index);
              
              return GestureDetector(
                onTap: isDisabled ? null : () => _toggleServiceAssignment(service, index),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isAssigned 
                      ? AppTheme.mintGreen 
                      : isDisabled 
                        ? Colors.grey.shade300 
                        : AppTheme.lightGrey,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isAssigned 
                        ? AppTheme.mintGreen 
                        : isDisabled 
                          ? Colors.grey.shade400 
                          : AppTheme.mediumGrey,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        service.name,
                        style: TextStyle(
                          color: isAssigned 
                            ? AppTheme.black 
                            : isDisabled 
                              ? Colors.grey.shade500 
                              : AppTheme.darkGrey,
                          fontWeight: isAssigned ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '\$${service.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: isAssigned 
                            ? AppTheme.black 
                            : isDisabled 
                              ? Colors.grey.shade500 
                              : AppTheme.darkGrey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                'Subtotal:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '\$${_calculateTechnicianSubtotal(assignment).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.mintGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildSpecialRequests() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Special Requests'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.lightGrey,
            borderRadius: BorderRadius.circular(8),
          ),
          width: double.infinity,
          child: Text(
            _specialRequestsController.text.isEmpty 
              ? 'No special requests' 
              : _specialRequestsController.text,
            style: const TextStyle(color: AppTheme.black),
          ),
        ),
      ],
    );
  }
  
  Widget _buildPaymentMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Payment Method'),
        const SizedBox(height: 16),
        const Text(
          'How would you like to pay?',
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.darkGrey,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _paymentMethods.map((method) {
            final isSelected = _selectedPaymentMethod == method;
            
            return GestureDetector(
              onTap: () => setState(() => _selectedPaymentMethod = method),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.mintGreen : AppTheme.lightGrey,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppTheme.mintGreen : AppTheme.mediumGrey,
                  ),
                ),
                child: Text(
                  method,
                  style: TextStyle(
                    color: isSelected ? AppTheme.black : AppTheme.darkGrey,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
  
  
  void _selectTipOption(String option) {
    setState(() {
      _selectedTipOption = option;
      
      // Calculate tip amount based on selection
      if (option == 'No tip') {
        _tipAmount = 0.0;
      } else if (option == 'Custom tip') {
        // Parse the current custom tip value
        _tipAmount = _parseCustomTipAmount();
      } else {
        // Parse percentage and calculate tip
        final percentage = double.parse(option.replaceAll('%', '')) / 100;
        _tipAmount = _calculateSubtotal() * percentage;
      }
    });
  }
  
  void _formatCustomTip(String value) {
    // Remove all non-digit characters
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.isEmpty) {
      _customTipController.text = '\$0.00';
      setState(() {
        _tipAmount = 0.0;
      });
      return;
    }
    
    // Convert to cents
    final cents = int.parse(digitsOnly);
    
    // Format as dollars and cents
    final dollars = cents / 100;
    
    // Update the controller with the formatted value
    _customTipController.text = '\$${dollars.toStringAsFixed(2)}';
    
    // Set the selection to the end
    _customTipController.selection = TextSelection.fromPosition(
      TextPosition(offset: _customTipController.text.length),
    );
    
    // Update the tip amount
    setState(() {
      _tipAmount = dollars;
    });
  }
  
  double _parseCustomTipAmount() {
    final text = _customTipController.text;
    final numericText = text.replaceAll(RegExp(r'[^\d.]'), '');
    
    if (numericText.isEmpty) {
      return 0.0;
    }
    
    return double.tryParse(numericText) ?? 0.0;
  }
  
  Widget _buildTotalSection() {
    final subtotal = _calculateSubtotal();
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.mintGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.mintGreen.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                '\$${subtotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: AppTheme.mintGreen,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  // Check if all requirements are met for checkout
  bool _isCheckoutValid() {
    // Check if there are any selected services
    if (_selectedServices.isEmpty) {
      return false;
    }
    
    // Check if all technicians have an employee assigned
    for (final assignment in _technicianAssignments) {
      if (assignment.employee == null && assignment.assignedServices.isNotEmpty) {
        return false;
      }
    }
    
    // Check if all services are assigned to at least one technician
    final allAssignedServices = <Service>{};
    for (final assignment in _technicianAssignments) {
      allAssignedServices.addAll(assignment.assignedServices);
    }
    
    if (allAssignedServices.length != _selectedServices.length) {
      return false;
    }
    
    // Check if there are any empty technician slots (technicians with no assigned services)
    for (final assignment in _technicianAssignments) {
      if (assignment.assignedServices.isEmpty) {
        return false;
      }
    }
    
    return true;
  }
  
  // Get validation messages for what needs to be fixed
  List<String> _getValidationMessages() {
    final messages = <String>[];
    
    // Check if there are any selected services
    if (_selectedServices.isEmpty) {
      messages.add('• Please select at least one service');
    }
    
    // Check if all technicians have an employee assigned
    for (int i = 0; i < _technicianAssignments.length; i++) {
      if (_technicianAssignments[i].employee == null && 
          _technicianAssignments[i].assignedServices.isNotEmpty) {
        messages.add('• Please select a name for Technician ${i + 1}');
      }
    }
    
    // Check if all services are assigned to at least one technician
    final allAssignedServices = <Service>{};
    for (final assignment in _technicianAssignments) {
      allAssignedServices.addAll(assignment.assignedServices);
    }
    
    if (allAssignedServices.length != _selectedServices.length) {
      final unassignedCount = _selectedServices.length - allAssignedServices.length;
      messages.add('• Please assign $unassignedCount more service${unassignedCount > 1 ? 's' : ''} to technicians');
    }
    
    // Check if there are any empty technician slots (technicians with no assigned services)
    for (int i = 0; i < _technicianAssignments.length; i++) {
      if (_technicianAssignments[i].assignedServices.isEmpty) {
        messages.add('• Please remove empty Technician ${i + 1} or assign services to them');
      }
    }
    
    return messages;
  }
  
  Widget _buildSubmitButton() {
    final isValid = _isCheckoutValid();
    final validationMessages = _getValidationMessages();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IosButton(
          text: 'Cancel Appointment',
          onPressed: _showCancelConfirmation,
          isFullWidth: true,
          icon: CupertinoIcons.xmark_circle,
          isDestructive: true,
        ),
        const SizedBox(height: 16),
        Opacity(
          opacity: isValid ? 1.0 : 0.5,
          child: IosButton(
            text: 'Proceed to Checkout',
            onPressed: isValid ? _submitForm : () {
              // Show validation messages when button is clicked but disabled
              _showValidationDialog(validationMessages);
            },
            isFullWidth: true,
            icon: CupertinoIcons.arrow_right_circle,
          ),
        ),
        if (!isValid) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Please complete the following before checkout:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                ...validationMessages.map((message) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.red,
                    ),
                  ),
                )),
              ],
            ),
          ),
        ],
      ],
    );
  }
  
  void _showValidationDialog(List<String> validationMessages) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Cannot Complete Checkout'),
          content: Column(
            children: [
              const Text('Please complete the following:'),
              const SizedBox(height: 8),
              ...validationMessages.map((message) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(message),
              )),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
  
  // Get list of already selected employees (excluding the current technician)
  List<Employee> _getAlreadySelectedEmployees(int currentTechnicianIndex) {
    final selectedEmployees = <Employee>[];
    
    for (int i = 0; i < _technicianAssignments.length; i++) {
      if (i != currentTechnicianIndex && _technicianAssignments[i].employee != null) {
        selectedEmployees.add(_technicianAssignments[i].employee!);
      }
    }
    
    return selectedEmployees;
  }
  
  void _showEmployeePicker(int technicianIndex) {
    final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
    final allEmployees = employeeProvider.employees;
    
    if (allEmployees.isEmpty) return;
    
    // Get already selected employees
    final alreadySelectedEmployees = _getAlreadySelectedEmployees(technicianIndex);
    
    // Filter out already selected employees
    final availableEmployees = allEmployees.where((employee) {
      return !alreadySelectedEmployees.any((selected) => selected.id == employee.id);
    }).toList();
    
    if (availableEmployees.isEmpty) {
      _showErrorDialog('No more available technicians. All technicians are already assigned.');
      return;
    }
    
    // Sort available employees alphabetically by name
    final sortedEmployees = List<Employee>.from(availableEmployees)
      ..sort((a, b) => a.name.compareTo(b.name));
    
    // Add a "Select Technician" option at the beginning
    final List<Widget> pickerItems = [
      const Center(child: Text('Select Technician')),
      ...sortedEmployees.map((employee) => Center(child: Text(employee.name))),
    ];
    
    // Add the current employee if it's already selected (to allow keeping the same technician)
    final currentEmployee = _technicianAssignments[technicianIndex].employee;
    if (currentEmployee != null && 
        !sortedEmployees.any((e) => e.id == currentEmployee.id)) {
      // Insert the current employee at the beginning of the list (after "Select Technician")
      pickerItems.insert(1, Center(child: Text(currentEmployee.name)));
      sortedEmployees.insert(0, currentEmployee);
    }
    
    // Determine the initial index based on the currently selected employee
    int initialIndex = 0; // Default to "Select Technician"
    if (currentEmployee != null) {
      // Find the index of the selected employee in the sorted list
      final selectedIndex = sortedEmployees.indexWhere((e) => e.id == currentEmployee.id);
      if (selectedIndex != -1) {
        initialIndex = selectedIndex + 1; // +1 because "Select Technician" is at index 0
      }
    }
    
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          color: CupertinoColors.systemBackground,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  CupertinoButton(
                    child: const Text('Done'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(initialItem: initialIndex),
                  itemExtent: 40,
                  onSelectedItemChanged: (index) {
                    setState(() {
                      // If index is 0, it's "Select Technician"
                      final employee = index == 0 ? null : sortedEmployees[index - 1];
                      _technicianAssignments[technicianIndex] = 
                        _technicianAssignments[technicianIndex].copyWith(employee: employee);
                    });
                  },
                  children: pickerItems,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  void _addTechnician() {
    // Check if there are any available technicians
    final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
    final allEmployees = employeeProvider.employees;
    
    // Get already selected employees
    final alreadySelectedEmployees = _technicianAssignments
        .where((assignment) => assignment.employee != null)
        .map((assignment) => assignment.employee!)
        .toList();
    
    // Check if all technicians are already assigned
    if (alreadySelectedEmployees.length >= allEmployees.length) {
      _showErrorDialog('No more available technicians. All technicians are already assigned.');
      return;
    }
    
    setState(() {
      _technicianAssignments.add(TechnicianAssignment(
        employee: null,
        assignedServices: [],
      ));
    });
  }
  
  void _removeTechnician(int index) {
    setState(() {
      _technicianAssignments.removeAt(index);
    });
  }
  
  void _toggleServiceAssignment(Service service, int technicianIndex) {
    setState(() {
      final assignment = _technicianAssignments[technicianIndex];
      if (assignment.assignedServices.contains(service)) {
        // Remove service from this technician
        _technicianAssignments[technicianIndex] = assignment.copyWith(
          assignedServices: assignment.assignedServices.where((s) => s.id != service.id).toList(),
        );
      } else {
        // Add service to this technician
        _technicianAssignments[technicianIndex] = assignment.copyWith(
          assignedServices: [...assignment.assignedServices, service],
        );
      }
    });
  }
  
  bool _isServiceAssignedToOtherTechnician(Service service, int currentTechnicianIndex) {
    for (int i = 0; i < _technicianAssignments.length; i++) {
      if (i != currentTechnicianIndex && 
          _technicianAssignments[i].assignedServices.contains(service)) {
        return true;
      }
    }
    return false;
  }
  
  // Helper method to create a TechnicianAssignment
  TechnicianAssignment _createTechnicianAssignment({
    Employee? employee,
    required List<Service> assignedServices,
  }) {
    return TechnicianAssignment(
      employee: employee,
      assignedServices: assignedServices,
    );
  }
  
  double _calculateTechnicianSubtotal(TechnicianAssignment assignment) {
    return assignment.assignedServices.fold(0, (sum, service) => sum + service.price);
  }
  
  double _calculateSubtotal() {
    return _selectedServices.fold(0, (sum, service) => sum + service.price);
  }
  
  void _submitForm() {
    // Validate form
    if (_selectedCustomer == null) {
      _showErrorDialog('Customer information is missing');
      return;
    }
    
    if (_selectedServices.isEmpty) {
      _showErrorDialog('No services selected');
      return;
    }
    
    // Check if all services are assigned to at least one technician
    final allAssignedServices = <Service>{};
    for (final assignment in _technicianAssignments) {
      allAssignedServices.addAll(assignment.assignedServices);
    }
    
    if (allAssignedServices.length != _selectedServices.length) {
      _showErrorDialog('Not all services have been assigned to technicians');
      return;
    }
    
    // Check if all technicians have an employee assigned
    for (int i = 0; i < _technicianAssignments.length; i++) {
      if (_technicianAssignments[i].employee == null && 
          _technicianAssignments[i].assignedServices.isNotEmpty) {
        _showErrorDialog('Please select a technician for Technician ${i + 1}');
        return;
      }
    }
    
    // Create a map of technicians and their assigned services
    final technicianServiceMap = <String, List<String>>{};
    for (final assignment in _technicianAssignments) {
      if (assignment.employee != null && assignment.assignedServices.isNotEmpty) {
        technicianServiceMap[assignment.employee?.id ?? ''] = 
          assignment.assignedServices.map((s) => s.id).toList();
      }
    }
    
    // Get the primary technician (the one with the most services)
    String primaryTechnicianId = '';
    int maxServices = 0;
    technicianServiceMap.forEach((techId, services) {
      if (services.length > maxServices) {
        maxServices = services.length;
        primaryTechnicianId = techId;
      }
    });
    
    // Handle different payment methods
    if (_selectedPaymentMethod == 'Cash') {
      // For cash payments, complete the transaction immediately
      _completeCashTransaction(technicianServiceMap, primaryTechnicianId);
    } else {
      // For card payments, navigate to the tip screen
      context.push(
        '/appointments/${widget.appointmentId}/tip',
        extra: {
          'technicianServiceMap': technicianServiceMap,
          'primaryTechnicianId': primaryTechnicianId,
          'notes': _specialRequestsController.text,
          'subtotal': _calculateSubtotal(),
        },
      );
    }
  }
  
  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
  
  void _showCancelConfirmation() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Cancel Appointment'),
          content: const Text('Are you sure you want to cancel this appointment?'),
          actions: [
            CupertinoDialogAction(
              child: const Text('No'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('Yes, Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                _cancelAppointment();
              },
            ),
          ],
        );
      },
    );
  }
  
  Future<void> _cancelAppointment() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
      // Delete the appointment entirely instead of marking it as cancelled
      await appointmentProvider.deleteAppointment(widget.appointmentId);
      
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      _showErrorDialog('Failed to cancel appointment: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _completeCashTransaction(
    Map<String, List<String>> technicianServiceMap, 
    String primaryTechnicianId
  ) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      if (_appointment == null) {
        throw Exception('Appointment data is missing');
      }
      
      // Update appointment status to completed
      final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
      
      // Update the appointment
      final updatedAppointment = _appointment!.copyWith(
        status: AppointmentStatus.completed,
        isPaid: true,
        // Store the payment method, technician assignments in the notes field
        notes: '${_appointment!.notes}\n\nPayment Method: Cash\n\nTechnician Assignments: $technicianServiceMap',
        employeeId: primaryTechnicianId,
        totalAmount: _calculateSubtotal(), // No tip for cash payments
      );
      
      await appointmentProvider.updateAppointment(updatedAppointment);
      
      // Show success dialog
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: const Text('Success'),
              content: const Text('Cash payment completed successfully!'),
              actions: [
                CupertinoDialogAction(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Go back to the dashboard
                    context.go('/');
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      _showErrorDialog('Failed to complete checkout: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
