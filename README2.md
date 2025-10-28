# Flutter App - Modular Architecture

This Flutter application uses a **feature-based modular architecture** for better organization, maintainability, and scalability.

## 📁 Folder Structure

```
lib/
├── core/                      # Core app functionality
│   ├── app/                   # App entry point and configuration
│   │   └── main.dart          # Main application entry point
│   ├── constants/             # App-wide constants
│   └── firebase/              # Firebase configuration
│       └── firebase_options.dart
│
├── features/                  # Feature-based modules
│   ├── auth/                  # Authentication feature
│   │   └── screens/           # Auth screens (login, signup, splash)
│   ├── devices/               # Smart device control feature
│   │   ├── screens/           # Device control screens
│   │   └── widgets/           # Device-related widgets
│   ├── home/                  # Home dashboard feature
│   │   └── screens/
│   ├── maps/                  # Maps and location feature
│   │   └── screens/
│   ├── profile/               # User profile feature
│   │   └── screens/
│   ├── video/                 # Video player feature (complete module)
│   │   ├── config/            # Video-specific configuration
│   │   ├── controllers/       # Video player logic
│   │   ├── models/            # Video data models
│   │   ├── screens/           # Video player screens
│   │   ├── services/          # YouTube/Cloudinary API services
│   │   ├── utils/             # Video-specific utilities
│   │   └── widgets/           # Video player widgets
│   └── weather/               # Weather functionality
│       └── services/          # Weather API service
│
├── shared/                    # Shared/reusable components
│   ├── navigation/            # Navigation components
│   ├── theme/                 # Theme configuration
│   └── widgets/               # Common reusable widgets
│
├── models/                    # Global data models
├── services/                  # Global services
├── utils/                     # Global utilities
└── config/                    # Global configuration
```

## 🎯 Architecture Benefits

### 1. **Feature-Based Organization**
- Each feature is self-contained with its own screens, widgets, models, and services
- Easy to find and modify feature-specific code
- Clear boundaries between different app features

### 2. **Scalability**
- Easy to add new features without affecting existing ones
- Simple to remove features if needed
- Team members can work on different features independently

### 3. **Maintainability**
- Single responsibility for each file and folder
- Clear import paths and dependencies
- Consistent folder structure across features

### 4. **Reusability**
- Shared components in `shared/` folder
- Feature-specific components can be easily reused within their domain
- Global utilities available across the entire app

## 📋 Feature Breakdown

### **Authentication (`features/auth/`)**
- Splash screen, login, and signup functionality
- Handles user authentication flow

### **Devices (`features/devices/`)**
- Smart home device controls (lights, TV, AC, etc.)
- Device cards and room management
- Thermostat configuration

### **Video (`features/video/`)**
- Complete video player implementation
- YouTube and Cloudinary video support
- Player controls, autoplay, and quality selection
- **Most comprehensive feature module**

### **Weather (`features/weather/`)**
- Weather API integration
- Weather-related functionality

### **Maps (`features/maps/`)**
- Location services and map integration
- Location picking and history

### **Profile (`features/profile/`)**
- User profile management
- Profile creation and editing

## 📦 Import Strategy

### **Barrel Exports**
Each feature has `index.dart` files for easier imports:

```dart
// Instead of multiple imports
import 'features/auth/screens/login_page.dart';
import 'features/auth/screens/signup_page.dart';

// Use barrel export
import 'features/auth/screens/index.dart';
```

### **Relative Imports**
Within a feature, use relative imports:
```dart
// Within video feature
import '../config/video_config.dart';
import '../models/video_model.dart';
```

### **Absolute Imports**
For cross-feature dependencies, use absolute paths:
```dart
// From any feature to core or shared
import 'core/firebase/firebase_options.dart';
import 'shared/widgets/loading_indicator.dart';
```

## 🔧 How to Add a New Feature

1. Create feature folder: `lib/features/your_feature/`
2. Add subfolders as needed: `screens/`, `widgets/`, `models/`, `services/`
3. Implement your feature components
4. Create `index.dart` for barrel exports
5. Update imports in existing files if needed

## 📱 Running the App

The main entry point is now located at:
```
lib/core/app/main.dart
```

Make sure your IDE or `flutter run` command points to this file.

## 🧪 Testing Strategy

With this modular architecture:
- Test individual features independently
- Mock services at the feature level
- Unit test models and utilities separately
- Widget test screens in isolation

## 🔄 Migration Notes

This structure was refactored from a single large file approach to improve:
- Code organization and readability
- Team collaboration capabilities  
- Feature development speed
- Long-term maintainability

The video player feature serves as a complete example of the modular approach, with all components properly separated and organized.