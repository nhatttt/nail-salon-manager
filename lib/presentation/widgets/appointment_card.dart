import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/appointment.dart';
import '../providers/customer_provider.dart';
import '../providers/service_provider.dart';
import 'common_widgets.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback? onTap;
  final String? navigationPath;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onTap,
    this.navigationPath,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('h:mm a');
    final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
    final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
    
    final customer = customerProvider.getCustomerById(appointment.customerId);
    
    final services = appointment.serviceIds
        .map((id) {
          try {
            return serviceProvider.services.firstWhere((s) => s.id == id);
          } catch (e) {
            return null;
          }
        })
        .where((service) => service != null)
        .toList();
    
    final totalServices = services.length;
    final serviceNames = totalServices > 0 
        ? '${services[0]?.name ?? "Unknown"}${totalServices > 1 ? ' +${totalServices - 1} more' : ''}' 
        : 'No services';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: appointment.statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap ?? (navigationPath != null 
          ? () => context.push(navigationPath!) 
          : () => context.push('/appointments/${appointment.id}')),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${timeFormat.format(appointment.startTime)} - ${timeFormat.format(appointment.endTime)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  StatusBadge(
                    text: appointment.status.name.toUpperCase(),
                    color: appointment.statusColor,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                serviceNames,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.black,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'For: ${customer?.name ?? 'Unknown Customer'}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.darkGrey,
                    ),
                  ),
                  Text(
                    '\$${appointment.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.mintGreen,
                    ),
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
