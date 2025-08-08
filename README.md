# Neodocs Flutter Assignment - By Prajjwal 
A Flutter application that displays a dynamic range bar with multiple sections

## Project Overview

This project implements a range bar visualization that can handle varying metadata (ranges, labels, colors) from an API, with robust error handling and a clean architecture.

## Key Features & Implementation

### 1. Flexible Metadata Handling

The project handles varying metadata formats through a robust data model:

```dart
// models/range_section.dart
class RangeSection {
  factory RangeSection.fromJson(Map<String, dynamic> json) {
    // Handles multiple range formats:
    // - String format: "0-28" or " 0 - 28 "
    // - Single number: "28" or 28
    // - Object format: {"min": 0, "max": 28}
    // - Flexible color formats: "#aabbcc", "aabbcc", "#ffaabbcc"
  }
}
```

### 2. State Management

Implements a clean state management solution without setState():

```dart
// controllers/range_controller.dart
class RangeController extends ChangeNotifier {
  // State variables
  List<RangeSection> sections = [];
  bool loading = false;
  String? error;
  double currentValue = 0.0;

  // Notifies listeners only when state changes
  Future<void> fetchRanges() async {
    loading = true;
    notifyListeners();
    // ... async work ...
    loading = false;
    notifyListeners();
  }
}

// Provided via InheritedWidget for efficient updates
class RangeProvider extends InheritedNotifier<RangeController>
```

### 3. Modular Code Organization

Clear separation of concerns with a well-organized folder structure:

```
lib/
├── controllers/    # Business logic and state management
├── models/         # Data models and type definitions
├── services/       # API and external service interactions
├── views/          # Screen and page components
└── widgets/        # Reusable UI components
```

### 4. Reliable API Integration

Robust API integration with comprehensive error handling:

```dart
// services/api_service.dart
class ApiService {
  Future<List<RangeSection>> fetchRanges() async {
    // Features:
    // - Network connectivity check
    // - Retry mechanism with exponential backoff
    // - Timeout handling
    // - Specific error messages for different HTTP status codes
    // - JSON parsing error handling
  }
}
```

### 5. Error Handling & Fallback UI

Comprehensive error handling with user-friendly fallback states:

```dart
// widgets/fallback_states.dart
class LoadingState extends StatelessWidget { ... }
class ErrorState extends StatelessWidget { ... }
class EmptyState extends StatelessWidget { ... }

// Features:
// - Loading indicators with messages
// - Error states with retry options
// - Empty states with helpful messages
// - Network error handling
// - Input validation with user feedback
```

### 6. Code Readability & Maintainability

Strong focus on clean code practices:

- **Descriptive Naming**: Clear and meaningful names for classes, methods, and variables
- **Documentation**: Comprehensive comments explaining complex logic
- **Single Responsibility**: Each class and method has a clear, single purpose
- **Error Prevention**: Strong input validation and error checking
- **Responsive Design**: Adapts to different screen sizes using LayoutBuilder
- **Code Organization**: Related functionality grouped together

## Technical Highlights

1. **Custom Range Bar Widget**: 
   - Handles dynamic sections with varying widths
   - Automatic contrast calculation for text
   - Smooth animations and transitions
   - Responsive to different screen sizes

2. **Input Validation**:
   - Validates numeric input
   - Range checking against available sections
   - Clear error messages for users

3. **API Integration**:
   - Bearer token authentication
   - Automatic retries for failed requests
   - Network status checking
   - Comprehensive error handling

4. **State Management**:
   - Uses ChangeNotifier for efficient updates
   - InheritedWidget for dependency injection
   - Clean separation of UI and business logic

## Getting Started

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run the app using `flutter run`

## Dependencies

- Flutter SDK
- Dart SDK
- No external state management libraries needed (uses built-in solutions)



- By Prajjwal Tripathi
 (mail: prajjwal026@gmail.com)