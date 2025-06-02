import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/phone_formatter.dart';
import '../../data/models/employee.dart';
import '../providers/employee_provider.dart';
import '../providers/service_provider.dart';
import '../widgets/common_widgets.dart';
import '../../routes.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
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
    final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
    final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
    
    if (employeeProvider.employees.isEmpty) {
      await employeeProvider.loadEmployees();
    }
    
    if (serviceProvider.services.isEmpty) {
      await serviceProvider.loadServices();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Employees'),
        leading: CupertinoNavigationBarBackButton(
          onPressed: () => context.pop(),
        ),
      ),
      child: SafeArea(
        child: Consumer<EmployeeProvider>(
          builder: (context, employeeProvider, child) {
            if (employeeProvider.isLoading) {
              return const LoadingIndicator();
            }
            
            if (employeeProvider.error != null) {
              return ErrorMessage(
                message: employeeProvider.error!,
                onRetry: () => _loadData(),
              );
            }
            
            final employees = _searchQuery.isEmpty 
                ? employeeProvider.employees 
                : employeeProvider.searchEmployees(_searchQuery);
            
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      IosButton(
                        text: 'Add New Employee',
                        onPressed: () => context.push(AppRoutes.newEmployee),
                        icon: CupertinoIcons.person_badge_plus,
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
                  child: employees.isEmpty
                    ? EmptyState(
                        message: _searchQuery.isNotEmpty
                            ? 'No employees found matching your search'
                            : 'No employees found',
                        icon: CupertinoIcons.person_3,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: employees.length,
                        itemBuilder: (context, index) {
                          return _buildEmployeeCard(context, employees[index]);
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
  
  Widget _buildEmployeeCard(BuildContext context, Employee employee) {
    final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
    
    // Get service names for this employee
    final serviceNames = employee.serviceIds.map((id) {
      try {
        return serviceProvider.services.firstWhere((s) => s.id == id).name;
      } catch (e) {
        return '';
      }
    }).where((name) => name.isNotEmpty).toList();
    
    // Format service names for display
    final specialties = serviceNames.isEmpty 
        ? 'No specialties' 
        : serviceNames.join(', ');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => context.push('/employees/${employee.id}'),
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
                    _getInitials(employee.name),
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
                      employee.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      employee.role,
                      style: const TextStyle(
                        color: AppTheme.darkGrey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (employee.phoneNumber.isNotEmpty)
                      Text(
                        PhoneFormatter.formatPhone(employee.phoneNumber),
                        style: const TextStyle(
                          color: AppTheme.darkGrey,
                          fontSize: 14,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      specialties,
                      style: const TextStyle(
                        color: AppTheme.darkGrey,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(
                  CupertinoIcons.pencil,
                  color: AppTheme.mintGreen,
                ),
                onPressed: () => context.push('/employees/${employee.id}'),
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
