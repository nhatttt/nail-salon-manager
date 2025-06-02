import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../routes.dart';
import '../widgets/common_widgets.dart';

class ManagementScreen extends StatelessWidget {
  const ManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SectionHeader(title: 'Salon Management'),
            const SizedBox(height: 16),
            _buildManagementCard(
              context,
              title: 'Services',
              description: 'Manage salon services and pricing',
              icon: CupertinoIcons.list_bullet,
              color: Colors.blue,
              onTap: () => context.push(AppRoutes.services),
            ),
            const SizedBox(height: 16),
            _buildManagementCard(
              context,
              title: 'Employees',
              description: 'Manage nail technicians and staff',
              icon: CupertinoIcons.person_3,
              color: Colors.purple,
              onTap: () => context.push(AppRoutes.employees),
            ),
            const SizedBox(height: 16),
            _buildManagementCard(
              context,
              title: 'Customers',
              description: 'View and manage customer information',
              icon: CupertinoIcons.person_2,
              color: Colors.green,
              onTap: () => context.push(AppRoutes.customers),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.darkGrey,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                CupertinoIcons.chevron_right,
                color: AppTheme.darkGrey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
