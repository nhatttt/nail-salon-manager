import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/salon_repository.dart';
import 'presentation/providers/service_provider.dart';
import 'presentation/providers/employee_provider.dart';
import 'presentation/providers/customer_provider.dart';
import 'presentation/providers/appointment_provider.dart';
import 'routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize repository with mock data
  final repository = SalonRepository();
  await repository.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ServiceProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
      ],
      child: MaterialApp.router(
        title: 'Nail Salon Manager',
        theme: ThemeData(
          primaryColor: AppTheme.mintGreen,
          scaffoldBackgroundColor: AppTheme.white,
          colorScheme: ColorScheme.light(
            primary: AppTheme.mintGreen,
            secondary: AppTheme.lightMintGreen,
            onPrimary: AppTheme.black,
          ),
        ),
        // Add Cupertino theme data
        builder: (context, child) {
          return CupertinoTheme(
            data: const CupertinoThemeData(
              primaryColor: AppTheme.mintGreen,
              brightness: Brightness.light,
              scaffoldBackgroundColor: AppTheme.white,
              barBackgroundColor: AppTheme.white,
              textTheme: CupertinoTextThemeData(
                primaryColor: AppTheme.mintGreen,
              ),
            ),
            child: child!,
          );
        },
        routerConfig: router,
        // Ensure we have both Material and Cupertino localizations
        localizationsDelegates: const [
          DefaultMaterialLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
      ),
    );
  }
}
