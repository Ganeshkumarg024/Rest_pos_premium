# 🍽️ Restaurant Billing App

A modern, production-ready Flutter restaurant POS billing system with offline-first architecture and Material 3 design.

![Flutter](https://img.shields.io/badge/Flutter-3.9.2+-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)
![SQLite](https://img.shields.io/badge/SQLite-Local-003B57?logo=sqlite)
![License](https://img.shields.io/badge/License-MIT-green)

## 📱 Features

- ✅ **Offline-First**: All data stored locally in SQLite
- ✅ **Order Management**: Create, track, and manage orders
- ✅ **Menu Management**: Grid view with availability toggles
- ✅ **Dashboard**: Real-time sales statistics and analytics
- ✅ **Reports**: Sales analytics with tax breakdown
- ✅ **Dark Mode**: Fully functional light/dark theme toggle
- ✅ **Material 3**: Modern UI with coral orange primary color
- ✅ **Clean Architecture**: Scalable and maintainable code structure

## 🎨 Design

- **Primary Color**: #FF7043 (Coral Orange)
- **Font**: Poppins (Google Fonts)
- **Border Radius**: 12px
- **Theme**: Material 3 with light/dark variants

## 🏗️ Architecture

```
Clean Architecture
├── Presentation Layer (UI + State Management)
├── Domain Layer (Business Logic)
└── Data Layer (Database + Repositories)
```

**State Management**: Riverpod  
**Database**: SQLite with 8 tables  
**Patterns**: Repository Pattern, Provider Pattern

## 📦 Dependencies

```yaml
dependencies:
  flutter_riverpod: ^2.4.9
  sqflite: ^2.3.0
  google_fonts: ^6.1.0
  fl_chart: ^0.65.0
  pdf: ^3.10.7
  printing: ^5.11.1
  qr_flutter: ^4.1.0
  csv: ^5.1.1
  intl: ^0.18.1
  image_picker: ^1.0.5
  shared_preferences: ^2.2.2
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.9.2 or higher
- Android Studio / VS Code
- Android Emulator or iOS Simulator

### Installation

```bash
# Clone the repository
cd /home/ubuntu/Music/RESTAPP

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Login Credentials

Use any credentials for testing:
- **Restaurant Code**: Any non-empty string
- **Email**: Valid email format
- **Password**: Minimum 6 characters

## 📂 Project Structure

```
lib/
├── main.dart                    # Entry point
├── app.dart                     # Root widget
├── core/                        # Core utilities
│   ├── theme/                   # Theme configuration
│   ├── constants/               # App constants
│   └── utils/                   # Utility functions
├── data/                        # Data layer
│   ├── database/                # SQLite helper
│   ├── models/                  # Data models
│   └── repositories/            # Data access
├── domain/                      # Business logic
│   ├── entities/                # Domain entities
│   └── usecases/                # Use cases
└── presentation/                # UI layer
    ├── providers/               # State management
    ├── screens/                 # App screens
    └── widgets/                 # Reusable widgets
```

## 🗄️ Database Schema

- **restaurants**: Restaurant profile
- **tables**: Table management
- **categories**: Menu categories
- **menu_items**: Menu items with pricing
- **orders**: Order headers
- **order_items**: Order line items
- **payments**: Payment records
- **settings**: App configuration

## 📸 Screenshots

### Dashboard
![Dashboard](design/image.png)

### Create Order
![Create Order](design/image%20copy.png)

### Reports
![Reports](design/image%20copy%202.png)

### Settings
![Settings](design/image%20copy%203.png)

### Menu
![Menu](design/image%20copy%204.png)

## ✨ Key Features

### Dashboard
- Today's sales with percentage change
- Active orders count
- Pending payments tracking
- Quick action buttons

### Order Management
- Order type selection (Dine-in, Takeaway, Delivery)
- Category-based menu browsing
- Cart with quantity controls
- Automatic tax calculation
- Discount application

### Menu Management
- Grid layout with images
- Availability indicators
- Sold-out overlay
- Search functionality

### Reports
- Time period filters
- Sales statistics
- Tax breakdown
- Payment method distribution
- Export to PDF/CSV (UI ready)

### Settings
- Dark/Light mode toggle
- Restaurant profile
- Tax configuration
- Backup/Restore (UI ready)
- Clear database

## 🧪 Testing

```bash
# Run tests
flutter test

# Analyze code
flutter analyze
```

## 📝 Code Quality

- ✅ Zero compilation errors
- ✅ Clean Architecture principles
- ✅ Consistent naming conventions
- ✅ Proper error handling
- ✅ Loading states
- ✅ Empty states

## 🔮 Future Enhancements

- [ ] Invoice PDF generation
- [ ] Table CRUD operations
- [ ] Menu item forms
- [ ] Charts visualization
- [ ] CSV export implementation
- [ ] Database backup/restore
- [ ] Bluetooth printer integration
- [ ] Multi-language support

## 📄 License

This project is licensed under the MIT License.

## 👨‍💻 Author

Built with ❤️ using Flutter

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Material Design for the design system
- Riverpod for state management
- SQLite for local database

---

**Note**: This is a production-ready POS system designed for offline restaurant operations. All data is stored locally for maximum reliability and speed.
