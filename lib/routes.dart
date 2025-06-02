import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'presentation/screens/dashboard_screen.dart';
import 'presentation/screens/new_appointment_screen.dart';
import 'presentation/screens/employee_form_screen.dart';
import 'presentation/screens/service_form_screen.dart';
import 'presentation/screens/customer_form_screen.dart';
import 'presentation/screens/checkout_screen.dart';
import 'presentation/screens/tip_screen.dart';
import 'presentation/screens/management_screen.dart';
import 'presentation/screens/employees_screen.dart';
import 'presentation/screens/services_screen.dart';
import 'presentation/screens/customers_screen.dart';
import 'presentation/screens/appointments_screen.dart';

// Define route names as constants for easy reference
class AppRoutes {
  static const String dashboard = '/';
  static const String appointments = '/appointments';
  static const String appointmentDetail = '/appointments/:id';
  static const String newAppointment = '/appointments/new';
  static const String checkout = '/appointments/:id/checkout';
  static const String tip = '/appointments/:id/tip';
  static const String employees = '/employees';
  static const String employeeDetail = '/employees/:id';
  static const String newEmployee = '/employees/new';
  static const String customers = '/customers';
  static const String customerDetail = '/customers/:id';
  static const String newCustomer = '/customers/new';
  static const String services = '/services';
  static const String serviceDetail = '/services/:id';
  static const String newService = '/services/new';
  static const String management = '/management';
}

// Create the router configuration
final GoRouter router = GoRouter(
  initialLocation: AppRoutes.dashboard,
  routes: [
    GoRoute(
      path: AppRoutes.dashboard,
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: AppRoutes.appointments,
      builder: (context, state) => const AppointmentsScreen(),
    ),
    GoRoute(
      path: AppRoutes.management,
      builder: (context, state) => const ManagementScreen(),
    ),
    GoRoute(
      path: AppRoutes.newAppointment,
      builder: (context, state) => const NewAppointmentScreen(),
    ),
    GoRoute(
      path: '/appointments/:id',
      builder: (context, state) => NewAppointmentScreen(
        appointmentId: state.pathParameters['id'],
      ),
    ),
    GoRoute(
      path: '/appointments/:id/checkout',
      builder: (context, state) => CheckoutScreen(
        appointmentId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/appointments/:id/tip',
      builder: (context, state) {
        final Map<String, dynamic> extra = state.extra as Map<String, dynamic>;
        return TipScreen(
          appointmentId: state.pathParameters['id']!,
          technicianServiceMap: extra['technicianServiceMap'] as Map<String, List<String>>,
          primaryTechnicianId: extra['primaryTechnicianId'] as String,
          notes: extra['notes'] as String,
          subtotal: extra['subtotal'] as double,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.newEmployee,
      builder: (context, state) => const EmployeeFormScreen(),
    ),
    GoRoute(
      path: '/employees/:id',
      builder: (context, state) => EmployeeFormScreen(
        employeeId: state.pathParameters['id'],
      ),
    ),
    GoRoute(
      path: AppRoutes.newService,
      builder: (context, state) => const ServiceFormScreen(),
    ),
    GoRoute(
      path: '/services/:id',
      builder: (context, state) => ServiceFormScreen(
        serviceId: state.pathParameters['id'],
      ),
    ),
    GoRoute(
      path: AppRoutes.employees,
      builder: (context, state) => const EmployeesScreen(),
    ),
    GoRoute(
      path: AppRoutes.services,
      builder: (context, state) => const ServicesScreen(),
    ),
    GoRoute(
      path: AppRoutes.newCustomer,
      builder: (context, state) => const CustomerFormScreen(),
    ),
    GoRoute(
      path: '/customers/:id',
      builder: (context, state) => CustomerFormScreen(
        customerId: state.pathParameters['id'],
      ),
    ),
    GoRoute(
      path: AppRoutes.customers,
      builder: (context, state) => const CustomersScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Page Not Found')),
    body: Center(
      child: Text('No route defined for ${state.uri.path}'),
    ),
  ),
);
