import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/appointment.dart';
import '../providers/appointment_provider.dart';
import '../providers/service_provider.dart';
import '../providers/employee_provider.dart';
import '../providers/customer_provider.dart';
import '../widgets/common_widgets.dart';
import '../widgets/appointment_card.dart';
import '../../routes.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> with SingleTickerProviderStateMixin {
  // Calendar controller
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  // Appointments for the selected day
  List<Appointment> _selectedDayAppointments = [];
  
  // Map to store appointments by date
  Map<DateTime, List<Appointment>> _appointmentsByDate = {};
  
  // Animation controller for calendar expansion
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  // Calendar expansion state
  bool _isCalendarExpanded = true;
  
  // Year view state
  bool _isYearViewVisible = false;
  
  // Constants for date range
  final DateTime _firstAllowedDay = DateTime(2024, 1, 1);
  final DateTime _lastAllowedDay = DateTime(2026, 12, 31);
  
  @override
  void initState() {
    super.initState();
    
    // Set selected day to today initially and ensure it's within allowed range
    _selectedDay = _ensureDateInRange(DateTime.now());
    _focusedDay = _selectedDay!;
    
    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    // Set initial animation value
    if (_isCalendarExpanded) {
      _animationController.value = 1.0;
    } else {
      _animationController.value = 0.0;
    }
    
    // Load data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }
  
  // Ensure date is within allowed range
  DateTime _ensureDateInRange(DateTime date) {
    if (date.isBefore(_firstAllowedDay)) {
      return _firstAllowedDay;
    } else if (date.isAfter(_lastAllowedDay)) {
      return _lastAllowedDay;
    }
    return date;
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _loadData() async {
    final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
    final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
    final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
    final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
    
    // Load all data
    if (serviceProvider.services.isEmpty) {
      await serviceProvider.loadServices();
    }
    
    if (employeeProvider.employees.isEmpty) {
      await employeeProvider.loadEmployees();
    }
    
    if (customerProvider.customers.isEmpty) {
      await customerProvider.loadCustomers();
    }
    
    // Load all appointments
    await appointmentProvider.loadAllAppointments();
    
    // Group appointments by date
    _groupAppointmentsByDate(appointmentProvider.appointments);
    
    // Load appointments for the selected day
    _loadAppointmentsForSelectedDay();
  }
  
  void _groupAppointmentsByDate(List<Appointment> appointments) {
    _appointmentsByDate = {};
    
    for (final appointment in appointments) {
      final date = DateTime(
        appointment.startTime.year,
        appointment.startTime.month,
        appointment.startTime.day,
      );
      
      if (_appointmentsByDate[date] == null) {
        _appointmentsByDate[date] = [];
      }
      
      _appointmentsByDate[date]!.add(appointment);
    }
    
    setState(() {});
  }
  
  void _loadAppointmentsForSelectedDay() {
    if (_selectedDay == null) return;
    
    final date = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
    );
    
    setState(() {
      _selectedDayAppointments = _appointmentsByDate[date] ?? [];
      
      // Sort appointments by start time
      _selectedDayAppointments.sort((a, b) => a.startTime.compareTo(b.startTime));
    });
  }
  
  // Toggle calendar expansion
  void _toggleCalendarExpansion() {
    setState(() {
      _isCalendarExpanded = !_isCalendarExpanded;
      if (_isCalendarExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }
  
  // Handle drag update for calendar expansion
  void _handleDragUpdate(DragUpdateDetails details) {
    // Negative delta.dy means dragging upward
    if (details.delta.dy < -2 && _isCalendarExpanded) {
      _toggleCalendarExpansion();
    } 
    // Positive delta.dy means dragging downward
    else if (details.delta.dy > 2 && !_isCalendarExpanded) {
      _toggleCalendarExpansion();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Consumer<AppointmentProvider>(
        builder: (context, appointmentProvider, child) {
          if (appointmentProvider.isLoading) {
            return const LoadingIndicator();
          }
          
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: IosButton(
                  text: 'New Appointment',
                  onPressed: () => context.push(AppRoutes.newAppointment),
                  icon: CupertinoIcons.calendar_badge_plus,
                  isFullWidth: true,
                ),
              ),
              _buildCollapsibleCalendar(appointmentProvider.appointments),
              const Divider(height: 1),
              Expanded(
                child: _selectedDayAppointments.isEmpty
                  ? _buildEmptyState()
                  : _buildAppointmentsList(),
              ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildCollapsibleCalendar(List<Appointment> appointments) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            // Calculate the height based on animation value
            // When collapsed, we still show the header (about 50px)
            final double minHeight = 50.0;
            final double maxHeight = 400.0; // Increased height to prevent overflow
            final double currentHeight = minHeight + (maxHeight - minHeight) * _animation.value;
            
            return SizedBox(
              height: currentHeight,
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.topCenter,
                  maxHeight: maxHeight,
                  child: _buildCalendar(appointments),
                ),
              ),
            );
          },
        ),
        GestureDetector(
          onVerticalDragUpdate: _handleDragUpdate,
          onTap: _toggleCalendarExpansion,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isCalendarExpanded ? 'Hide Calendar' : 'Show Calendar',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _isCalendarExpanded 
                        ? CupertinoIcons.chevron_up 
                        : CupertinoIcons.chevron_down,
                      size: 12,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildCalendar(List<Appointment> appointments) {
    if (_isYearViewVisible) {
      return _buildYearView();
    }
    
    // Ensure focused day is within allowed range
    _focusedDay = _ensureDateInRange(_focusedDay);
    
    return TableCalendar(
      firstDay: _firstAllowedDay,
      lastDay: _lastAllowedDay,
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      eventLoader: (day) {
        final date = DateTime(day.year, day.month, day.day);
        return _appointmentsByDate[date] ?? [];
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
        
        // Load appointments for the selected day
        _loadAppointmentsForSelectedDay();
        
        // Get the date in DateTime format for the selected day
        final date = DateTime(
          selectedDay.year,
          selectedDay.month,
          selectedDay.day,
        );
        
        // Get appointments for the selected day
        final appointments = _appointmentsByDate[date] ?? [];
        
        // Only collapse calendar if there are 2 or more appointments
        if (appointments.length >= 2 && _isCalendarExpanded) {
          setState(() {
            _isCalendarExpanded = false;
            _animationController.reverse();
          });
        }
      },
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
        });
      },
      calendarStyle: CalendarStyle(
        markersMaxCount: 3,
        markerDecoration: const BoxDecoration(
          color: AppTheme.mintGreen,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: AppTheme.mintGreen.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        selectedDecoration: const BoxDecoration(
          color: AppTheme.mintGreen,
          shape: BoxShape.circle,
        ),
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      onPageChanged: (focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
      },
      calendarBuilders: CalendarBuilders(
        headerTitleBuilder: (context, day) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _isYearViewVisible = true;
                // Ensure calendar is expanded when year view is shown
                if (!_isCalendarExpanded) {
                  _isCalendarExpanded = true;
                  _animationController.forward();
                }
              });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('MMMM yyyy').format(day),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(CupertinoIcons.chevron_down, size: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildYearView() {
    final currentYear = _focusedDay.year;
    final currentMonth = _focusedDay.month;
    
    return Column(
      children: [
        // Year view header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(CupertinoIcons.chevron_left),
                onPressed: () {
                  setState(() {
                    _focusedDay = DateTime(currentYear - 1, currentMonth);
                  });
                },
              ),
              GestureDetector(
                onTap: () {
                  // Could add year picker here in the future
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    currentYear.toString(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(CupertinoIcons.chevron_right),
                onPressed: () {
                  setState(() {
                    _focusedDay = DateTime(currentYear + 1, currentMonth);
                  });
                },
              ),
            ],
          ),
        ),
        
        // Month grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              final month = index + 1;
              final isCurrentMonth = month == DateTime.now().month && currentYear == DateTime.now().year;
              final isSelectedMonth = month == currentMonth && currentYear == _focusedDay.year;
              
              return GestureDetector(
                onTap: () {
                  final selectedDate = DateTime(currentYear, month, 1);
                  final validDate = _ensureDateInRange(selectedDate);
                  
                  setState(() {
                    _focusedDay = validDate;
                    _selectedDay = validDate;
                    _isYearViewVisible = false;
                  });
                  
                  // Update appointments for the selected day
                  _loadAppointmentsForSelectedDay();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelectedMonth 
                      ? AppTheme.mintGreen 
                      : isCurrentMonth 
                        ? AppTheme.mintGreen.withOpacity(0.3)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    DateFormat('MMM').format(DateTime(currentYear, month)),
                    style: TextStyle(
                      fontWeight: isCurrentMonth || isSelectedMonth ? FontWeight.bold : FontWeight.normal,
                      color: isSelectedMonth ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        
        // Back button
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: TextButton(
            onPressed: () {
              // Ensure focused day is valid before going back
              final validDate = _ensureDateInRange(_focusedDay);
              
              setState(() {
                _focusedDay = validDate;
                _selectedDay = validDate;
                _isYearViewVisible = false;
              });
            },
            child: const Text('Back to Calendar'),
          ),
        ),
      ],
    );
  }
  
  Widget _buildEmptyState() {
    final dateFormat = DateFormat('EEEE, MMMM d');
    final selectedDate = _selectedDay ?? DateTime.now();
    
    return EmptyState(
      message: 'No appointments for ${dateFormat.format(selectedDate)}',
      icon: CupertinoIcons.calendar,
    );
  }
  
  Widget _buildAppointmentsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _selectedDayAppointments.length,
      itemBuilder: (context, index) {
        return _buildAppointmentCard(context, _selectedDayAppointments[index]);
      },
    );
  }
  
  Widget _buildAppointmentCard(BuildContext context, Appointment appointment) {
    return AppointmentCard(
      appointment: appointment,
      navigationPath: '/appointments/${appointment.id}',
    );
  }
}
