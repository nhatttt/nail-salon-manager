import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/service.dart';
import '../providers/service_provider.dart';
import '../widgets/common_widgets.dart';
import '../../routes.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
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
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Services'),
        leading: CupertinoNavigationBarBackButton(
          onPressed: () => context.pop(),
        ),
      ),
      child: SafeArea(
        child: Consumer<ServiceProvider>(
          builder: (context, serviceProvider, child) {
            if (serviceProvider.isLoading) {
              return const LoadingIndicator();
            }
            
            if (serviceProvider.error != null) {
              return ErrorMessage(
                message: serviceProvider.error!,
                onRetry: () => _loadData(),
              );
            }
            
            final services = serviceProvider.services;
            final categories = serviceProvider.getUniqueCategories();
            
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: IosButton(
                    text: 'Add New Service',
                    onPressed: () => context.push(AppRoutes.newService),
                    icon: CupertinoIcons.add,
                    isFullWidth: true,
                  ),
                ),
                Expanded(
                  child: services.isEmpty
                    ? const EmptyState(
                        message: 'No services found',
                        icon: CupertinoIcons.list_bullet,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final categoryServices = services.where((s) => s.category == category).toList();
                          
                          return _buildCategorySection(context, category, categoryServices);
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
  
  Widget _buildCategorySection(BuildContext context, String category, List<Service> services) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            category,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.mintGreen,
            ),
          ),
        ),
        ...services.map((service) => _buildServiceCard(context, service)),
        const SizedBox(height: 16),
      ],
    );
  }
  
  Widget _buildServiceCard(BuildContext context, Service service) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => context.push('/services/${service.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (service.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        service.description,
                        style: const TextStyle(
                          color: AppTheme.darkGrey,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      '${service.durationMinutes} min',
                      style: const TextStyle(
                        color: AppTheme.darkGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currencyFormat.format(service.price),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.mintGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minSize: 0,
                    child: const Icon(
                      CupertinoIcons.pencil,
                      color: AppTheme.mintGreen,
                      size: 20,
                    ),
                    onPressed: () => context.push('/services/${service.id}'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
