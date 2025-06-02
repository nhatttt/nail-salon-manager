import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:signature/signature.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/appointment.dart';
import '../providers/appointment_provider.dart';
import '../widgets/common_widgets.dart';

class TipScreen extends StatefulWidget {
  final String appointmentId;
  final Map<String, List<String>> technicianServiceMap;
  final String primaryTechnicianId;
  final String notes;
  final double subtotal;
  
  const TipScreen({
    super.key,
    required this.appointmentId,
    required this.technicianServiceMap,
    required this.primaryTechnicianId,
    required this.notes,
    required this.subtotal,
  });

  @override
  State<TipScreen> createState() => _TipScreenState();
}

class _TipScreenState extends State<TipScreen> {
  // Tip options
  final List<String> _tipOptions = ['No tip', '18%', '20%', '25%', 'Custom tip'];
  String _selectedTipOption = 'No tip';
  double _tipAmount = 0.0;
  
  // Custom tip state
  bool _isCustomTipActive = false;
  final TextEditingController _customTipController = TextEditingController(text: '\$0.00');
  final FocusNode _customTipFocusNode = FocusNode();
  
  // Receipt options
  final List<String> _receiptOptions = ['Yes', 'No Receipt'];
  String _selectedReceiptOption = 'Yes';
  
  // Signature state
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: AppTheme.mintGreen,
    exportBackgroundColor: Colors.white,
  );
  bool _hasSignature = false;
  
  // Loading state
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    
    // Listen for signature changes
    _signatureController.onDrawStart = () {
      if (!_hasSignature) {
        setState(() {
          _hasSignature = true;
        });
      }
    };
  }
  
  @override
  void dispose() {
    _customTipController.dispose();
    _customTipFocusNode.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              middle: const Text('Add Tip'),
            ),
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildTipSection(),
                  const SizedBox(height: 24),
                  _buildReceiptSection(),
                  const SizedBox(height: 24),
                  _buildTotalSection(),
                  const SizedBox(height: 24),
                  _buildSignatureSection(),
                  const SizedBox(height: 32),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CupertinoActivityIndicator(
                  radius: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildSignatureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Signature'),
        const SizedBox(height: 16),
        const Text(
          'Please sign to confirm your payment:',
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.darkGrey,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.mediumGrey),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Signature(
              controller: _signatureController,
              backgroundColor: Colors.white,
              height: 200,
              width: double.infinity,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              onPressed: () {
                setState(() {
                  _signatureController.clear();
                  _hasSignature = false;
                });
              },
              child: const Text(
                'Clear Signature',
                style: TextStyle(
                  color: AppTheme.mintGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildTipSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Tip Amount'),
        const SizedBox(height: 16),
        const Text(
          'Would you like to add a tip?',
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.darkGrey,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 12,
          children: _tipOptions.map((option) {
            final isSelected = _selectedTipOption == option;
            
            // Calculate tip amount for percentage options
            String displayText = option;
            if (option != 'No tip' && option != 'Custom tip') {
              final percentage = double.parse(option.replaceAll('%', '')) / 100;
              final tipAmount = widget.subtotal * percentage;
              displayText = '$option (\$${tipAmount.toStringAsFixed(2)})';
            }
            
            // For custom tip option
            if (option == 'Custom tip' && _isCustomTipActive) {
              return Container(
                width: 150,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.mintGreen,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.mintGreen),
                ),
                child: TextField(
                  controller: _customTipController,
                  focusNode: _customTipFocusNode,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: _formatCustomTip,
                  autofocus: true,
                ),
              );
            }
            
            return GestureDetector(
              onTap: () => _selectTipOption(option),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.mintGreen : AppTheme.lightGrey,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppTheme.mintGreen : AppTheme.mediumGrey,
                  ),
                ),
                child: Text(
                  displayText,
                  style: TextStyle(
                    color: isSelected ? AppTheme.black : AppTheme.darkGrey,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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
      
      // Handle custom tip option
      if (option == 'Custom tip') {
        _isCustomTipActive = true;
        _customTipController.text = '\$0.00';
        _tipAmount = 0.0;
        
        // Focus the text field after the UI updates
        Future.delayed(const Duration(milliseconds: 100), () {
          _customTipFocusNode.requestFocus();
        });
      } else {
        _isCustomTipActive = false;
        
        // Calculate tip amount based on selection
        if (option == 'No tip') {
          _tipAmount = 0.0;
        } else {
          // Parse percentage and calculate tip
          final percentage = double.parse(option.replaceAll('%', '')) / 100;
          _tipAmount = widget.subtotal * percentage;
        }
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
  
  
  Widget _buildTotalSection() {
    final total = widget.subtotal + _tipAmount;
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.mintGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.mintGreen.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Subtotal:',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '\$${widget.subtotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tip:',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '\$${_tipAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Amount:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: AppTheme.mintGreen,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildReceiptSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Receipt'),
        const SizedBox(height: 16),
        const Text(
          'Would you like a receipt?',
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.darkGrey,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 12,
          children: _receiptOptions.map((option) {
            final isSelected = _selectedReceiptOption == option;
            
            return GestureDetector(
              onTap: () => _selectReceiptOption(option),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.mintGreen : AppTheme.lightGrey,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppTheme.mintGreen : AppTheme.mediumGrey,
                  ),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    color: isSelected ? AppTheme.black : AppTheme.darkGrey,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
  
  void _selectReceiptOption(String option) {
    setState(() {
      _selectedReceiptOption = option;
    });
  }
  
  Widget _buildSubmitButton() {
    return IosButton(
      text: 'Complete Checkout',
      onPressed: _submitForm,
      isFullWidth: true,
      icon: CupertinoIcons.check_mark_circled,
    );
  }
  
  void _submitForm() async {
    // Check if signature is provided
    if (_signatureController.isEmpty) {
      _showErrorDialog('Please provide your signature to complete the checkout.');
      return;
    }
    
    // Update signature state
    setState(() {
      _hasSignature = true;
      _isLoading = true;
    });
    
    try {
      // Export signature as image
      final signatureImage = await _signatureController.toPngBytes();
      
      if (signatureImage == null) {
        throw Exception('Failed to export signature');
      }
      
      // In a real app, you would save this image to storage
      // For example:
      // final signatureFile = await _saveSignatureToStorage(signatureImage);
      
      await _completeCheckout();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Failed to process signature: ${e.toString()}');
    }
  }
  
  Future<void> _completeCheckout() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Update appointment status to completed
      final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
      
      // Update the appointment
      final appointment = appointmentProvider.getAppointmentById(widget.appointmentId);
      if (appointment == null) {
        throw Exception('Appointment data is missing');
      }
      
      // Prepare receipt information
      String receiptInfo = 'Receipt preference: $_selectedReceiptOption';
      
      // Prepare signature information
      String signatureInfo = 'Customer signature provided: Yes';
      
      final updatedAppointment = appointment.copyWith(
        status: AppointmentStatus.completed,
        isPaid: true,
        // Store the technician assignments, tip, receipt preference, and signature info in the notes field
        // In a real app, you'd want to store this in proper fields and store the signature image
        notes: '${widget.notes}\n\nTechnician Assignments: ${widget.technicianServiceMap}\n\nTip: \$${_tipAmount.toStringAsFixed(2)}\n\n$receiptInfo\n\n$signatureInfo',
        employeeId: widget.primaryTechnicianId,
        totalAmount: widget.subtotal + _tipAmount, // Update total amount to include tip
      );
      
      await appointmentProvider.updateAppointment(updatedAppointment);
      
      // Show success dialog
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: const Text('Success'),
              content: const Text('Checkout completed successfully!'),
              actions: [
                CupertinoDialogAction(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Go back to the dashboard with the navigation bar
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
}
