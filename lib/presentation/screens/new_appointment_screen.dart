import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/appointment.dart';
import '../../data/models/customer.dart';
import '../../data/models/employee.dart';
import '../../data/models/service.dart';
import '../providers/appointment_provider.dart';
import '../providers/customer_provider.dart';
import '../providers/employee_provider.dart';
import '../providers/service_provider.dart';
import '../widgets/common_widgets.dart';

class NewAppointmentScreen extends StatefulWidget {
  final String? appointmentId;
  
  const NewAppointmentScreen({
    super.key,
    this.appointmentId,
  });

  @override
  State<NewAppointmentScreen> createState() => _NewAppointmentScreenState();
}

class _NewAppointmentScreenState extends State<NewAppointmentScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();
  
  // Selected customer
  Customer? _selectedCustomer;
  
  // Selected date and time
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  
  // Selected services
  List<Service> _selectedServices = [];
  
  // Selected employee
  Employee? _selectedEmployee;
  
  // Special requests
  final TextEditingController _specialRequestsController = TextEditingController();
  
  // Loading state
  bool _isLoading = false;
  
  // Is editing mode
  bool get _isEditing => widget.appointmentId != null;
  
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
    
    // If editing an existing appointment, load its data
    if (_isEditing) {
      final appointment = appointmentProvider.getAppointmentById(widget.appointmentId!);
      
      if (appointment != null) {
        // Load customer
        final customer = customerProvider.getCustomerById(appointment.customerId);
        
        // Load services
        final services = appointment.serviceIds.map((id) {
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
        
        setState(() {
          _selectedCustomer = customer;
          _selectedDate = appointment.startTime;
          _selectedTime = TimeOfDay(
            hour: appointment.startTime.hour,
            minute: appointment.startTime.minute,
          );
          _selectedServices = services;
          _selectedEmployee = employee;
          _specialRequestsController.text = appointment.notes;
        });
      }
    }
  }
  
  @override
  void dispose() {
    _specialRequestsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Wrap with Material to provide MaterialLocalizations
    return Material(
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(_isEditing ? 'Edit Appointment' : 'New Appointment'),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildCustomerSelector(),
              const SizedBox(height: 24),
              _buildDateTimePicker(),
              const SizedBox(height: 24),
              _buildServiceSelector(),
              const SizedBox(height: 24),
              _buildEmployeeSelector(),
              const SizedBox(height: 24),
              _buildSpecialRequests(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildCustomerSelector() {
    return Consumer<CustomerProvider>(
      builder: (context, customerProvider, child) {
        if (customerProvider.isLoading) {
          return const LoadingIndicator();
        }
        
        final customers = customerProvider.customers;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'Customer'),
            const SizedBox(height: 8),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => _showCustomerPicker(customers),
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
                      _selectedCustomer?.name ?? 'Select Customer',
                      style: TextStyle(
                        color: _selectedCustomer != null ? AppTheme.black : AppTheme.darkGrey,
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
            const SizedBox(height: 12),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _addNewCustomer,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.lightGrey,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.mintGreen),
                ),
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      CupertinoIcons.person_add,
                      color: AppTheme.mintGreen,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Add New Customer',
                      style: TextStyle(
                        color: AppTheme.mintGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  
  void _showCustomerPicker(List<Customer> customers) {
    // Sort customers alphabetically by name
    final sortedCustomers = List<Customer>.from(customers)
      ..sort((a, b) => a.name.compareTo(b.name));
    
    // Determine the initial index based on the currently selected customer
    int initialIndex = 0;
    if (_selectedCustomer != null) {
      // Find the index of the selected customer in the sorted list
      final selectedIndex = sortedCustomers.indexWhere((c) => c.id == _selectedCustomer!.id);
      if (selectedIndex != -1) {
        initialIndex = selectedIndex;
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
                      _selectedCustomer = sortedCustomers[index];
                    });
                  },
                  children: sortedCustomers.map((customer) {
                    return Center(
                      child: Text(customer.name),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildDateTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Date & Time'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _showDatePicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.lightGrey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('MMM d, yyyy').format(_selectedDate),
                        style: const TextStyle(color: AppTheme.black),
                      ),
                      const Icon(
                        CupertinoIcons.calendar,
                        color: AppTheme.darkGrey,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _showTimePicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.lightGrey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedTime.format(context),
                        style: const TextStyle(color: AppTheme.black),
                      ),
                      const Icon(
                        CupertinoIcons.time,
                        color: AppTheme.darkGrey,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  void _showDatePicker() {
    // Use Material date picker instead of Cupertino
    showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    ).then((pickedDate) {
      if (pickedDate != null) {
        setState(() {
          _selectedDate = pickedDate;
        });
      }
    });
  }
  
  void _showTimePicker() {
    // Use Material time picker instead of Cupertino
    showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    ).then((pickedTime) {
      if (pickedTime != null) {
        setState(() {
          _selectedTime = pickedTime;
        });
      }
    });
  }
  
  Widget _buildServiceSelector() {
    return Consumer<ServiceProvider>(
      builder: (context, serviceProvider, child) {
        if (serviceProvider.isLoading) {
          return const LoadingIndicator();
        }
        
        final services = serviceProvider.services;
        final categories = serviceProvider.getUniqueCategories();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'Services'),
            const SizedBox(height: 8),
            ...categories.map((category) {
              final categoryServices = services.where((s) => s.category == category).toList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 8),
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
                    children: categoryServices.map((service) {
                      final isSelected = _selectedServices.contains(service);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedServices.remove(service);
                            } else {
                              _selectedServices.add(service);
                            }
                          });
                        },
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
                  const SizedBox(height: 16),
                ],
              );
            }).toList(),
            if (_selectedServices.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '\$${_calculateTotal().toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.mintGreen,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
  
  double _calculateTotal() {
    return _selectedServices.fold(0, (sum, service) => sum + service.price);
  }
  
  int _calculateDuration() {
    return _selectedServices.fold(0, (sum, service) => sum + service.durationMinutes);
  }
  
  Widget _buildEmployeeSelector() {
    return Consumer<EmployeeProvider>(
      builder: (context, employeeProvider, child) {
        if (employeeProvider.isLoading) {
          return const LoadingIndicator();
        }
        
        final employees = employeeProvider.employees;
        
        // All employees can perform all services
        List<Employee> availableEmployees = employees;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'Nail Technician'),
            const SizedBox(height: 8),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => _showEmployeePicker(availableEmployees),
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
                      _selectedEmployee?.name ?? 'No preference',
                      style: TextStyle(
                        color: AppTheme.black,
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
          ],
        );
      },
    );
  }
  
  // Navigate to add new customer screen and update selected customer when returning
  Future<void> _addNewCustomer() async {
    // Navigate to the customer form screen
    final newCustomer = await context.push<Customer>('/customers/new');
    
    // If a new customer was created, update the selected customer
    if (newCustomer != null) {
      setState(() {
        _selectedCustomer = newCustomer;
      });
    }
  }

  void _showEmployeePicker(List<Employee> employees) {
    if (employees.isEmpty) return;
    
    // Sort employees alphabetically by name
    final sortedEmployees = List<Employee>.from(employees)
      ..sort((a, b) => a.name.compareTo(b.name));
    
    // Add a "No preference" option at the beginning
    final List<Widget> pickerItems = [
      const Center(child: Text('No preference')),
      ...sortedEmployees.map((employee) => Center(child: Text(employee.name))),
    ];
    
    // Determine the initial index based on the currently selected employee
    int initialIndex = 0; // Default to "No preference"
    if (_selectedEmployee != null) {
      // Find the index of the selected employee in the sorted list
      final selectedIndex = sortedEmployees.indexWhere((e) => e.id == _selectedEmployee!.id);
      if (selectedIndex != -1) {
        initialIndex = selectedIndex + 1; // +1 because "No preference" is at index 0
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
                      // If index is 0, it's "No preference"
                      _selectedEmployee = index == 0 ? null : sortedEmployees[index - 1];
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
  
  Widget _buildSpecialRequests() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Special Requests (Optional)'),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.lightGrey,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _specialRequestsController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Enter any special requests or preferences',
              hintStyle: TextStyle(color: AppTheme.darkGrey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            style: const TextStyle(color: AppTheme.black),
          ),
        ),
      ],
    );
  }
  
  Widget _buildSubmitButton() {
    return Column(
      children: [
        if (_isEditing) ...[
          IosButton(
            text: 'Cancel Appointment',
            onPressed: _showCancelConfirmation,
            isFullWidth: true,
            icon: CupertinoIcons.xmark_circle,
            isDestructive: true,
          ),
          const SizedBox(height: 16),
        ],
        IosButton(
          text: _isEditing ? 'Update Appointment' : 'Create Appointment',
          onPressed: _submitForm,
          isFullWidth: true,
          icon: _isEditing ? CupertinoIcons.pencil : CupertinoIcons.calendar_badge_plus,
        ),
      ],
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
    // Check if we have a valid appointment ID
    if (widget.appointmentId == null) {
      _showErrorDialog('Cannot cancel: No appointment ID found');
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
      
      // Debug output to help diagnose the issue
      print('Deleting appointment with ID: ${widget.appointmentId}');
      
      // Get the appointment to determine its date before deleting
      final appointment = appointmentProvider.getAppointmentById(widget.appointmentId!);
      final appointmentDate = appointment?.startTime;
      
      // Delete the appointment entirely instead of marking it as cancelled
      await appointmentProvider.deleteAppointment(widget.appointmentId!);
      
      // Force a reload of appointments for the date of the deleted appointment
      if (appointmentDate != null) {
        final dateOnly = DateTime(appointmentDate.year, appointmentDate.month, appointmentDate.day);
        await appointmentProvider.loadAppointmentsByDate(dateOnly);
      }
      
      if (mounted) {
        // Navigate back
        context.pop();
        
        // Show a brief success message using CupertinoDialog
        showCupertinoDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            // Auto-dismiss after 2 seconds
            Future.delayed(const Duration(seconds: 2), () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            });
            
            return CupertinoAlertDialog(
              title: const Text('Success'),
              content: const Text('Appointment cancelled successfully'),
            );
          },
        );
      }
    } catch (e) {
      print('Error cancelling appointment: $e');
      _showErrorDialog('Failed to cancel appointment: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _submitForm() {
    // Validate form
    if (_selectedCustomer == null) {
      _showErrorDialog('Please select a customer');
      return;
    }
    
    if (_selectedServices.isEmpty) {
      _showErrorDialog('Please select at least one service');
      return;
    }
    
    // Create appointment
    _createAppointment();
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
  
  Future<void> _createAppointment() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Calculate start and end time
      final startDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );
      
      final durationMinutes = _calculateDuration();
      final endDateTime = startDateTime.add(Duration(minutes: durationMinutes));
      
      // Create appointment
      final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
      final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
      
      // If no employee is selected and there's a special request for a specific technician,
      // we'll leave it as unassigned and the salon can assign it later
      String employeeId = '';
      
      if (_selectedEmployee != null) {
        employeeId = _selectedEmployee!.id;
        
        // Check if time slot is available for the selected employee
        final isAvailable = appointmentProvider.isTimeSlotAvailable(
          employeeId,
          startDateTime,
          endDateTime,
        );
        
        if (!isAvailable) {
          _showErrorDialog('The selected time slot is not available for this technician');
          setState(() {
            _isLoading = false;
          });
          return;
        }
      } else if (_specialRequestsController.text.isNotEmpty) {
        // If there's a special request but no selected employee, try to find an employee
        // who can perform all the selected services
        final selectedServiceIds = _selectedServices.map((s) => s.id).toSet();
        final availableEmployees = employeeProvider.employees.where((employee) {
          return selectedServiceIds.every((serviceId) => employee.serviceIds.contains(serviceId));
        }).toList();
        
        if (availableEmployees.isNotEmpty) {
          // Just use the first available employee as a placeholder
          employeeId = availableEmployees.first.id;
        }
      }
      
      // Create or update appointment
      final appointmentId = _isEditing ? widget.appointmentId! : const Uuid().v4();
      
      final appointment = Appointment(
        id: appointmentId,
        customerId: _selectedCustomer!.id,
        employeeId: employeeId,
        serviceIds: _selectedServices.map((s) => s.id).toList(),
        startTime: startDateTime,
        endTime: endDateTime,
        status: AppointmentStatus.scheduled,
        totalAmount: _calculateTotal(),
        isPaid: false,
        notes: _specialRequestsController.text,
      );
      
      // Save appointment
      if (_isEditing) {
        await appointmentProvider.updateAppointment(appointment);
      } else {
        await appointmentProvider.addAppointment(appointment);
      }
      
      // Navigate back
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      _showErrorDialog('Failed to create appointment: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
