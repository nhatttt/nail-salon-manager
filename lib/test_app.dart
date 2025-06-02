import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/salon_repository.dart';
import 'presentation/providers/service_provider.dart';
import 'presentation/providers/employee_provider.dart';
import 'presentation/providers/customer_provider.dart';
import 'presentation/providers/appointment_provider.dart';
import 'presentation/screens/appointments_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize repository with mock data
  final repository = SalonRepository();
  await repository.initialize();
  
  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ServiceProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
      ],
      child: MaterialApp(
        title: 'Appointments Test',
        theme: ThemeData(
          primaryColor: AppTheme.mintGreen,
          scaffoldBackgroundColor: AppTheme.white,
          colorScheme: ColorScheme.light(
            primary: AppTheme.mintGreen,
            secondary: AppTheme.lightMintGreen,
            onPrimary: AppTheme.black,
          ),
        ),
        home: const AppointmentsScreen(),
      ),
    );
  }
}
