import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/phone_formatter.dart';
import '../../data/models/employee.dart';
import '../../data/models/service.dart';
import '../providers/employee_provider.dart';
import '../providers/service_provider.dart';
import '../widgets/common_widgets.dart';

class EmployeeFormScreen extends StatefulWidget {
  final String? employeeId;
  
  const EmployeeFormScreen({
    super.key,
    this.employeeId,
  });

  @override
  State<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends State<EmployeeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Text controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _minimumPayController = TextEditingController();
  final TextEditingController _employeeRatioController = TextEditingController();
  final TextEditingController _cashRatioController = TextEditingController();
  
  // Selected services
  final List<Service> _selectedServices = [];
  
  // Loading state
  bool _isLoading = false;
  
  // Is editing mode
  bool get _isEditing => widget.employeeId != null;
  
  @override
  void initState() {
    super.initState();
    
    // Load data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }
  
  Future<void> _loadData() async {
    final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
    
    if (serviceProvider.services.isEmpty) {
      await serviceProvider.loadServices();
    }
    
    if (_isEditing) {
      final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
      final employee = employeeProvider.getEmployeeById(widget.employeeId!);
      
      if (employee != null) {
        // Split the name into first and last name
        final nameParts = employee.name.split(' ');
        final firstName = nameParts.first;
        final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
        
        // Format the phone number when loading
        final formattedPhone = PhoneFormatter.formatPhone(employee.phoneNumber);
        
        setState(() {
          _firstNameController.text = firstName;
          _lastNameController.text = lastName;
          _phoneController.text = formattedPhone;
          _emailController.text = employee.email;
          
          // Load payment information
          _minimumPayController.text = employee.paymentInfo['minimumPay']?.toString() ?? '';
          _employeeRatioController.text = employee.paymentInfo['employeeRatio']?.toString() ?? '';
          _cashRatioController.text = employee.paymentInfo['cashRatio']?.toString() ?? '';
          
          // Clear any existing selected services
          _selectedServices.clear();
          
          // Load selected services
          for (final serviceId in employee.serviceIds) {
            try {
              final service = serviceProvider.services.firstWhere(
                (s) => s.id == serviceId,
              );
              _selectedServices.add(service);
            } catch (e) {
              // Service not found, skip it
            }
          }
        });
      }
    }
  }
  
  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _minimumPayController.dispose();
    _employeeRatioController.dispose();
    _cashRatioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(_isEditing ? 'Edit Employee' : 'New Employee'),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildNameFields(),
                const SizedBox(height: 24),
                _buildContactFields(),
                const SizedBox(height: 24),
              _buildPaymentFields(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildNameFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Name'),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.lightGrey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        hintText: 'First Name *',
                        hintStyle: TextStyle(color: AppTheme.darkGrey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      style: const TextStyle(color: AppTheme.black),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'First name is required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Text(
                      'Required',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.darkGrey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.lightGrey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    hintText: 'Last Name',
                    hintStyle: TextStyle(color: AppTheme.darkGrey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  style: const TextStyle(color: AppTheme.black),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildContactFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Contact Information'),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.lightGrey,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              hintText: '(123) 456-7890',
              hintStyle: TextStyle(color: AppTheme.darkGrey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              prefixIcon: Icon(CupertinoIcons.phone, color: AppTheme.darkGrey),
            ),
            style: const TextStyle(color: AppTheme.black),
            keyboardType: TextInputType.phone,
            onChanged: (value) {
              // Format the phone number as the user types
              final formattedValue = PhoneFormatter.formatPhoneWhileTyping(value);
              if (formattedValue != value) {
                _phoneController.value = TextEditingValue(
                  text: formattedValue,
                  selection: TextSelection.collapsed(offset: formattedValue.length),
                );
              }
            },
            validator: (value) {
              if (value != null && value.trim().isNotEmpty && !PhoneFormatter.isValidPhone(value)) {
                return 'Please enter a valid 10-digit phone number';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.lightGrey,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              hintText: 'Email Address',
              hintStyle: TextStyle(color: AppTheme.darkGrey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            style: const TextStyle(color: AppTheme.black),
            keyboardType: TextInputType.emailAddress,
          ),
        ),
      ],
    );
  }
  
  Widget _buildPaymentFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Payment Information'),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.lightGrey,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextFormField(
            controller: _minimumPayController,
            decoration: const InputDecoration(
              hintText: 'Minimum Pay (per day)',
              hintStyle: TextStyle(color: AppTheme.darkGrey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              prefixIcon: Icon(CupertinoIcons.money_dollar, color: AppTheme.darkGrey),
            ),
            style: const TextStyle(color: AppTheme.black),
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.lightGrey,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextFormField(
            controller: _employeeRatioController,
            decoration: const InputDecoration(
              hintText: 'Employee/Owner Ratio (%)',
              hintStyle: TextStyle(color: AppTheme.darkGrey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              prefixIcon: Icon(CupertinoIcons.percent, color: AppTheme.darkGrey),
            ),
            style: const TextStyle(color: AppTheme.black),
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.lightGrey,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextFormField(
            controller: _cashRatioController,
            decoration: const InputDecoration(
              hintText: 'Cash/Check Ratio (%)',
              hintStyle: TextStyle(color: AppTheme.darkGrey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              prefixIcon: Icon(CupertinoIcons.percent, color: AppTheme.darkGrey),
            ),
            style: const TextStyle(color: AppTheme.black),
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.only(left: 8),
        ),
      ],
    );
  }
  
  Widget _buildSubmitButton() {
    return IosButton(
      text: _isEditing ? 'Update Employee' : 'Add Employee',
      onPressed: _submitForm,
      isFullWidth: true,
      icon: _isEditing ? CupertinoIcons.person_crop_circle_badge_checkmark : CupertinoIcons.person_badge_plus,
    );
  }
  
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _saveEmployee();
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
  
  Future<void> _saveEmployee() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();
      final fullName = lastName.isEmpty ? firstName : '$firstName $lastName';
      
      final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
      
      // Parse payment information
      double? minimumPay;
      double? employeeRatio;
      double? cashRatio;
      
      if (_minimumPayController.text.isNotEmpty) {
        minimumPay = double.tryParse(_minimumPayController.text);
      }
      
      if (_employeeRatioController.text.isNotEmpty) {
        employeeRatio = double.tryParse(_employeeRatioController.text);
      }
      
      if (_cashRatioController.text.isNotEmpty) {
        cashRatio = double.tryParse(_cashRatioController.text);
      }
      
      // Format the phone number before saving
      final formattedPhone = PhoneFormatter.formatPhone(_phoneController.text);
      
      final employee = Employee(
        id: _isEditing ? widget.employeeId! : const Uuid().v4(),
        name: fullName,
        phoneNumber: formattedPhone,
        email: _emailController.text.trim(),
        role: 'Nail Technician', // Default role
        serviceIds: [], // All employees can perform all services
        paymentInfo: {
          'method': 'Direct Deposit',
          'commissionRate': 0.5,
          'minimumPay': minimumPay,
          'employeeRatio': employeeRatio,
          'cashRatio': cashRatio,
        },
      );
      
      if (_isEditing) {
        await employeeProvider.updateEmployee(employee);
      } else {
        await employeeProvider.addEmployee(employee);
      }
      
      // Navigate back
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      _showErrorDialog('Failed to save employee: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
