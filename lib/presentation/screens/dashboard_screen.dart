import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/appointment.dart';
import '../providers/appointment_provider.dart';
import '../providers/service_provider.dart';
import '../providers/employee_provider.dart';
import '../providers/customer_provider.dart';
import '../widgets/common_widgets.dart';
import '../widgets/appointment_card.dart';
import '../screens/appointments_screen.dart';
import '../screens/management_screen.dart';
import '../../routes.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0; // Set initial tab to Dashboard
  final List<Widget> _pages = [];
  final List<String> _titles = ['Dashboard', 'Appointments', 'Management'];
  late CupertinoTabController _tabController;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize tab controller with initial index 0 (Dashboard)
    _tabController = CupertinoTabController(initialIndex: 0);
    
    // Initialize repository with mock data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadData() async {
    final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
    final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
    final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
    final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
    
    await serviceProvider.loadServices();
    await employeeProvider.loadEmployees();
    await customerProvider.loadCustomers();
    await appointmentProvider.loadAppointmentsByDate(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      controller: _tabController,
      tabBar: CupertinoTabBar(
        activeColor: AppTheme.mintGreen,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.calendar),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
            label: 'Management',
          ),
        ],
      ),
      tabBuilder: (BuildContext context, int index) {
        _selectedIndex = index;
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text(_titles[index]),
            // Removed the plus button as we have dedicated add buttons for each screen
          ),
          child: SafeArea(
            child: IndexedStack(
              index: index,
              children: [
                _buildDashboardContent(),
                _buildAppointmentsTab(),
                _buildManagementTab(),
              ],
            ),
          ),
        );
      },
    );
  }
  
  void _onAddPressed(BuildContext context) {
    switch (_selectedIndex) {
      case 1: // Appointments
        context.push(AppRoutes.newAppointment);
        break;
      case 2: // Management
        context.push(AppRoutes.management);
        break;
    }
  }
  
  Widget _buildDashboardContent() {
    return Consumer<AppointmentProvider>(
      builder: (context, appointmentProvider, child) {
        if (appointmentProvider.isLoading) {
          return const LoadingIndicator();
        }
        
        if (appointmentProvider.error != null) {
          return ErrorMessage(
            message: appointmentProvider.error!,
            onRetry: () => _loadData(),
          );
        }
        
        final todayAppointments = appointmentProvider.appointments;
        final scheduledAppointments = appointmentProvider.getAppointmentsByStatus(AppointmentStatus.scheduled);
        final confirmedAppointments = appointmentProvider.getAppointmentsByStatus(AppointmentStatus.confirmed);
        
        final dailyRevenue = appointmentProvider.calculateDailyRevenue(DateTime.now());
        
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildDashboardHeader(dailyRevenue),
            const SizedBox(height: 24),
            _buildAppointmentStatusSummary(
              scheduledCount: scheduledAppointments.length,
              confirmedCount: confirmedAppointments.length,
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Today\'s Appointments'),
            const SizedBox(height: 8),
            if (todayAppointments.isEmpty)
              const EmptyState(
                message: 'No appointments scheduled for today',
                icon: CupertinoIcons.calendar,
              )
            else
              ...todayAppointments.map((appointment) => 
                _buildAppointmentCard(context, appointment)),
            // No Point of Sale button needed as checkout covers this functionality
          ],
        );
      },
    );
  }
  
  Widget _buildDashboardHeader(double dailyRevenue) {
    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE, MMMM d');
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dateFormat.format(now),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.black,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text(
              'Today\'s Revenue:',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.darkGrey,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              currencyFormat.format(dailyRevenue),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.mintGreen,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildAppointmentStatusSummary({
    required int scheduledCount,
    required int confirmedCount,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildStatusCard(
            'Scheduled',
            scheduledCount.toString(),
            Colors.blue,
            CupertinoIcons.calendar,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatusCard(
            'Confirmed',
            confirmedCount.toString(),
            Colors.green,
            CupertinoIcons.check_mark,
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatusCard(String title, String count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildAppointmentCard(BuildContext context, Appointment appointment) {
    return AppointmentCard(
      appointment: appointment,
      navigationPath: '/appointments/${appointment.id}/checkout',
    );
  }
  
  // Placeholder widgets for other tabs
  Widget _buildAppointmentsTab() {
    return const AppointmentsScreen();
  }
  
  Widget _buildManagementTab() {
    return const ManagementScreen();
  }
}
