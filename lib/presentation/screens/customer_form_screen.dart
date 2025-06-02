import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/phone_formatter.dart';
import '../../data/models/customer.dart';
import '../providers/customer_provider.dart';
import '../widgets/common_widgets.dart';

class CustomerFormScreen extends StatefulWidget {
  final String? customerId;
  
  const CustomerFormScreen({
    super.key,
    this.customerId,
  });

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Text controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  // Loading state
  bool _isLoading = false;
  
  // Is editing mode
  bool get _isEditing => widget.customerId != null;
  
  // Original customer data for editing
  Customer? _originalCustomer;
  
  @override
  void initState() {
    super.initState();
    
    // Load data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }
  
  Future<void> _loadData() async {
    if (_isEditing) {
      final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
      final customer = customerProvider.getCustomerById(widget.customerId!);
      
      if (customer != null) {
        // Format the phone number when loading
        final formattedPhone = PhoneFormatter.formatPhone(customer.phoneNumber);
        
        setState(() {
          _originalCustomer = customer;
          _firstNameController.text = customer.firstName;
          _lastNameController.text = customer.lastName;
          _phoneController.text = formattedPhone;
          _emailController.text = customer.email;
          _notesController.text = customer.notes;
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
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(_isEditing ? 'Edit Customer' : 'New Customer'),
          leading: CupertinoNavigationBarBackButton(
            onPressed: () => context.pop(),
          ),
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
                _buildNotesField(),
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppTheme.lightGrey,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  hintText: '(123) 456-7890 *',
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
                  if (value == null || value.trim().isEmpty) {
                    return 'Phone number is required';
                  }
                  if (!PhoneFormatter.isValidPhone(value)) {
                    return 'Please enter a valid 10-digit phone number';
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
              prefixIcon: Icon(CupertinoIcons.mail, color: AppTheme.darkGrey),
            ),
            style: const TextStyle(color: AppTheme.black),
            keyboardType: TextInputType.emailAddress,
          ),
        ),
      ],
    );
  }
  
  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Additional Information'),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.lightGrey,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              hintText: 'Notes',
              hintStyle: TextStyle(color: AppTheme.darkGrey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            style: const TextStyle(color: AppTheme.black),
            maxLines: 4,
          ),
        ),
      ],
    );
  }
  
  Widget _buildSubmitButton() {
    return IosButton(
      text: _isEditing ? 'Update Customer' : 'Add Customer',
      onPressed: _submitForm,
      isFullWidth: true,
      icon: _isEditing ? CupertinoIcons.person_crop_circle_badge_checkmark : CupertinoIcons.person_add,
    );
  }
  
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _saveCustomer();
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
  
  Future<void> _saveCustomer() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
      
      // Format the phone number before saving
      final formattedPhone = PhoneFormatter.formatPhone(_phoneController.text);
      
      final customer = Customer(
        id: _isEditing ? widget.customerId! : const Uuid().v4(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phoneNumber: formattedPhone,
        email: _emailController.text.trim(),
        appointmentIds: _originalCustomer?.appointmentIds ?? [],
        preferences: _originalCustomer?.preferences ?? {},
        notes: _notesController.text.trim(),
      );
      
      if (_isEditing) {
        await customerProvider.updateCustomer(customer);
      } else {
        await customerProvider.addCustomer(customer);
      }
      
      // Navigate back with the newly created customer
      if (mounted) {
        context.pop(customer);
      }
    } catch (e) {
      _showErrorDialog('Failed to save customer: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
