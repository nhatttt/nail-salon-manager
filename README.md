# Nail Salon Manager

A comprehensive Flutter application designed for nail salon owners and managers to streamline daily operations, enhance customer experience, and optimize business performance with an elegant iOS-like UI design.

![Nail Salon Manager](https://placeholder-for-app-screenshot.png)

## Overview

Nail Salon Manager provides an all-in-one solution for nail salon businesses to manage appointments, customers, services, employees, and point-of-sale operations. The application is built with a focus on usability, efficiency, and scalability to meet the needs of small to medium-sized nail salons.

## Features

### Dashboard
- Real-time daily revenue tracking and visualization
- Appointment overview with status indicators
- Quick access to today's appointments and walk-ins
- Performance metrics and business insights

### Appointment Management
- Intuitive scheduling interface with drag-and-drop functionality
- View appointments by day, week, or month with customizable calendar
- Filter appointments by status (scheduled, confirmed, in-progress, completed, canceled)
- Automatic reminders and notifications
- Conflict detection to prevent double-booking

### Customer Management
- Comprehensive customer profiles with contact information
- Service history and preferences tracking
- Notes and special requirements storage
- Loyalty program integration
- Birthday reminders and special occasion tracking

### Service Catalog Management
- Hierarchical service organization by categories:
  - Manicure (Basic, Gel, Dip Powder)
  - Pedicure (Basic, Spa, Luxury)
  - Enhancements (Acrylic, Gel, Extensions)
  - Add-ons (Designs, Gems, French Tips)
- Customizable pricing tiers and duration settings
- Detailed service descriptions and images
- Special packages and promotions management

### Employee Management
- Employee profiles with contact information and emergency contacts
- Skill matrix and service capabilities tracking
- Commission structure and payment information
- Performance tracking and metrics
- Schedule management and availability

### Point of Sale (POS) System
- Streamlined checkout process with service selection
- Multiple payment methods (Cash, Credit/Debit Card, Mobile Payment)
- Technician assignment for multi-service appointments
- Dynamic tip calculation with percentage presets
- Digital signature capture for receipts
- Email/SMS receipt options
- Discount and promotion application

### Reporting and Analytics (Planned)
- Daily, weekly, monthly, and annual sales reports
- Employee performance metrics
- Service popularity analysis
- Customer retention statistics
- Revenue forecasting

## Technical Details

### Architecture
- Clean architecture with clear separation of concerns:
  - Presentation layer (UI components)
  - Domain layer (business logic)
  - Data layer (repositories and data sources)
- Provider pattern for efficient state management
- Repository pattern for centralized data access
- SOLID principles implementation for maintainable code

### UI Design
- iOS-like UI with Cupertino widgets for a polished look and feel
- Consistent color palette with white, black, and mint green
- Responsive design that adapts to various screen sizes (phones, tablets)
- Accessibility features for improved usability
- Smooth animations and transitions

### Data Management
- Local storage with SQLite for offline functionality
- Future cloud synchronization capabilities
- Secure data handling for customer information
- Regular automated backups

### Dependencies
- `provider`: State management
- `go_router`: Navigation and routing
- `intl`: Internationalization and formatting
- `flutter_slidable`: Interactive list items with swipe actions
- `table_calendar`: Flexible calendar widget
- `uuid`: Unique identifier generation
- `signature`: Digital signature capture
- `sqflite`: Local database management
- `path_provider`: File system access
- `flutter_secure_storage`: Secure data storage

## Installation Requirements

- Flutter SDK 3.10.0 or higher
- Dart 3.0.0 or higher
- iOS 13+ (for iOS deployment)
- Android 6.0+ (API level 23+) for Android deployment
- macOS 10.15+ (for development)

## Getting Started

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/nail_salon_manager.git
   ```

2. Navigate to the project directory:
   ```
   cd nail_salon_manager
   ```

3. Install dependencies:
   ```
   flutter pub get
   ```

4. Run the application:
   ```
   flutter run
   ```

## Project Structure

```
lib/
  ├── core/                  # Core functionality and utilities
  │   ├── constants/         # Application constants
  │   ├── theme/             # Theme configuration
  │   └── utils/             # Utility functions
  ├── data/                  # Data layer
  │   ├── models/            # Data models
  │   └── repositories/      # Data repositories
  ├── presentation/          # Presentation layer
  │   ├── providers/         # State management
  │   ├── screens/           # Application screens
  │   └── widgets/           # Reusable UI components
  ├── routes.dart            # Application routing
  └── main.dart              # Application entry point
```

## Future Enhancements

- Customer-facing mobile application
- Online booking system with real-time availability
- Integrated payment processing
- Inventory management system
- Advanced employee scheduling with time tracking
- Comprehensive analytics and business intelligence
- Push notifications for appointments and promotions
- Cloud synchronization across multiple devices
- Multi-language support
- Dark mode theme option
- Integration with social media platforms
- Customer feedback and review system

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support, email support@nailsalonmanager.com or open an issue in the repository.
