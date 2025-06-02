import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/service.dart';
import '../providers/service_provider.dart';
import '../widgets/common_widgets.dart';

class ServiceFormScreen extends StatefulWidget {
  final String? serviceId;
  
  const ServiceFormScreen({
    super.key,
    this.serviceId,
  });

  @override
  State<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends State<ServiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Text controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  
  // Selected category
  String _selectedCategory = 'Manicure';
  
  // Available categories
  final List<String> _categories = [
    'Manicure',
    'Pedicure',
    'Enhancements',
    'Add-ons',
    'Packages',
    'Other',
  ];
  
  // Loading state
  bool _isLoading = false;
  
  // Is editing mode
  bool get _isEditing => widget.serviceId != null;
  
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
    
    if (_isEditing) {
      final service = serviceProvider.services.firstWhere(
        (s) => s.id == widget.serviceId,
        orElse: () => Service(
          id: '',
          name: '',
          description: '',
          price: 0,
          durationMinutes: 0,
          category: '',
        ),
      );
      
      if (service.id.isNotEmpty) {
        setState(() {
          _nameController.text = service.name;
          _descriptionController.text = service.description;
          _priceController.text = service.price.toString();
          _durationController.text = service.durationMinutes.toString();
          _selectedCategory = service.category;
        });
      }
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(_isEditing ? 'Edit Service' : 'New Service'),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildBasicInfo(),
                const SizedBox(height: 24),
                _buildPriceAndDuration(),
                const SizedBox(height: 24),
                _buildCategorySelector(),
                const SizedBox(height: 32),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildBasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Basic Information'),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.lightGrey,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'Service Name *',
              hintStyle: TextStyle(color: AppTheme.darkGrey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            style: const TextStyle(color: AppTheme.black),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Service name is required';
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
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.lightGrey,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              hintText: 'Description',
              hintStyle: TextStyle(color: AppTheme.darkGrey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            style: const TextStyle(color: AppTheme.black),
            maxLines: 3,
          ),
        ),
      ],
    );
  }
  
  Widget _buildPriceAndDuration() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Price & Duration'),
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
                      controller: _priceController,
                      decoration: const InputDecoration(
                        hintText: 'Price (\$) *',
                        hintStyle: TextStyle(color: AppTheme.darkGrey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        prefixText: '\$ ',
                      ),
                      style: const TextStyle(color: AppTheme.black),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Price is required';
                        }
                        
                        final price = double.tryParse(value);
                        if (price == null || price < 0) {
                          return 'Enter a valid price';
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.lightGrey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextFormField(
                      controller: _durationController,
                      decoration: const InputDecoration(
                        hintText: 'Duration (min) *',
                        hintStyle: TextStyle(color: AppTheme.darkGrey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        suffixText: 'min',
                      ),
                      style: const TextStyle(color: AppTheme.black),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Duration is required';
                        }
                        
                        final duration = int.tryParse(value);
                        if (duration == null || duration <= 0) {
                          return 'Enter a valid duration';
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
          ],
        ),
      ],
    );
  }
  
  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Category'),
        const SizedBox(height: 8),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _showCategoryPicker,
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
                  _selectedCategory,
                  style: const TextStyle(
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
  }
  
  void _showCategoryPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        // Find the index of the selected category
        int initialIndex = _categories.indexOf(_selectedCategory);
        if (initialIndex == -1) initialIndex = 0;
        
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
                      _selectedCategory = _categories[index];
                    });
                  },
                  children: _categories.map((category) {
                    return Center(
                      child: Text(category),
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
  
  Widget _buildSubmitButton() {
    return IosButton(
      text: _isEditing ? 'Update Service' : 'Add Service',
      onPressed: _submitForm,
      isFullWidth: true,
      icon: _isEditing ? CupertinoIcons.pencil : CupertinoIcons.plus,
    );
  }
  
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _saveService();
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
  
  Future<void> _saveService() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim();
      final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
      final duration = int.tryParse(_durationController.text.trim()) ?? 0;
      
      final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
      
      final service = Service(
        id: _isEditing ? widget.serviceId! : const Uuid().v4(),
        name: name,
        description: description,
        price: price,
        durationMinutes: duration,
        category: _selectedCategory,
      );
      
      if (_isEditing) {
        await serviceProvider.updateService(service);
      } else {
        await serviceProvider.addService(service);
      }
      
      // Navigate back
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      _showErrorDialog('Failed to save service: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
