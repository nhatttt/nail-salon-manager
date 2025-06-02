import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/phone_formatter.dart';
import '../../data/models/customer.dart';
import '../providers/customer_provider.dart';
import '../widgets/common_widgets.dart';
import '../../routes.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    
    // Load data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
    
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _loadData() async {
    final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
    
    if (customerProvider.customers.isEmpty) {
      await customerProvider.loadCustomers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Customers'),
        leading: CupertinoNavigationBarBackButton(
          onPressed: () => context.pop(),
        ),
      ),
      child: SafeArea(
        child: Consumer<CustomerProvider>(
          builder: (context, customerProvider, child) {
            if (customerProvider.isLoading) {
              return const LoadingIndicator();
            }
            
            if (customerProvider.error != null) {
              return ErrorMessage(
                message: customerProvider.error!,
                onRetry: () => _loadData(),
              );
            }
            
            final customers = _searchQuery.isEmpty 
                ? customerProvider.customers 
                : customerProvider.searchCustomers(_searchQuery);
            
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      IosButton(
                        text: 'Add New Customer',
                        onPressed: () => context.push(AppRoutes.newCustomer),
                        icon: CupertinoIcons.person_add,
                        isFullWidth: true,
                      ),
                      const SizedBox(height: 16),
                      CupertinoSearchTextField(
                        controller: _searchController,
                        placeholder: 'Search by name or phone',
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: customers.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: customers.length,
                        itemBuilder: (context, index) {
                          return _buildCustomerCard(context, customers[index]);
                        },
                      ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    if (_searchQuery.isNotEmpty) {
      return const EmptyState(
        message: 'No customers found matching your search',
        icon: CupertinoIcons.search,
      );
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.person_2,
            size: 64,
            color: AppTheme.mintGreen,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Customers Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your first customer to get started',
            style: TextStyle(
              color: AppTheme.darkGrey,
            ),
          ),
          const SizedBox(height: 24),
          IosButton(
            text: 'Add Your First Customer',
            onPressed: () => context.push(AppRoutes.newCustomer),
            icon: CupertinoIcons.person_add,
          ),
        ],
      ),
    );
  }
  
  Widget _buildCustomerCard(BuildContext context, Customer customer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => context.push('/customers/${customer.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: AppTheme.lightMintGreen,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _getInitials(customer.name),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.mintGreen,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      PhoneFormatter.formatPhone(customer.phoneNumber),
                      style: const TextStyle(
                        color: AppTheme.darkGrey,
                        fontSize: 14,
                      ),
                    ),
                    if (customer.email.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        customer.email,
                        style: const TextStyle(
                          color: AppTheme.darkGrey,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(
                  CupertinoIcons.pencil,
                  color: AppTheme.mintGreen,
                ),
                onPressed: () => context.push('/customers/${customer.id}'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _getInitials(String name) {
    final nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}';
    }
    return nameParts[0].length > 1 ? nameParts[0].substring(0, 2) : nameParts[0];
  }
}
