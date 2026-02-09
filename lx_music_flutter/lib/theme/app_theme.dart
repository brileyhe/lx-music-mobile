import 'package:flutter/material.dart';

/// Defines theme modes for the application
enum AppThemeMode {
  light,
  dark,
  highContrast,
  system,
}

/// Provides theme configurations for different modes
class AppTheme {
  /// Creates a light theme
  static ThemeData createLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
    );
  }

  /// Creates a dark theme
  static ThemeData createDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
    );
  }

  /// Creates a high contrast theme suitable for automotive use
  static ThemeData createHighContrastTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark, // High contrast often uses dark backgrounds
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: Color(0xFFFFFFFF), // White
        onPrimary: Color(0xFF000000), // Black
        primaryContainer: Color(0xFF000000), // Black
        onPrimaryContainer: Color(0xFFFFFFFF), // White
        secondary: Color(0xFFFFFFFF), // White
        onSecondary: Color(0xFF000000), // Black
        secondaryContainer: Color(0xFF000000), // Black
        onSecondaryContainer: Color(0xFFFFFFFF), // White
        tertiary: Color(0xFFFFFFFF), // White
        onTertiary: Color(0xFF000000), // Black
        tertiaryContainer: Color(0xFF000000), // Black
        onTertiaryContainer: Color(0xFFFFFFFF), // White
        error: Color(0xFFFFB4AB), // Light red for errors
        onError: Color(0xFF690005), // Dark red text on error
        errorContainer: Color(0xFF93000A), // Red container
        onErrorContainer: Color(0xFFFFDAD6), // Light red text on error container
        surface: Color(0xFF000000), // Black background
        onSurface: Color(0xFFFFFFFF), // White text
        surfaceVariant: Color(0xFF404040), // Dark gray
        onSurfaceVariant: Color(0xFFFFFFFF), // White text on dark gray
        outline: Color(0xFFCCCCCC), // Light gray outline
        outlineVariant: Color(0xFF444444), // Dark gray outline
        shadow: Color(0xFF000000), // Black shadow
        scrim: Color(0xFF000000), // Black scrim
        inverseSurface: Color(0xFFFFFFFF), // White inverted surface
        onInverseSurface: Color(0xFF000000), // Black text on inverted surface
        inversePrimary: Color(0xFF000000), // Black inverse primary
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: Color(0xFFFFFFFF), fontSize: 32, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: Color(0xFFFFFFFF), fontSize: 24, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(color: Color(0xFFFFFFFF), fontSize: 20, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: Color(0xFFFFFFFF), fontSize: 18, fontWeight: FontWeight.w500),
        titleMedium: TextStyle(color: Color(0xFFFFFFFF), fontSize: 16, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(color: Color(0xFFFFFFFF), fontSize: 14, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: Color(0xFFFFFFFF), fontSize: 16),
        bodyMedium: TextStyle(color: Color(0xFFFFFFFF), fontSize: 14),
        bodySmall: TextStyle(color: Color(0xFFFFFFFF), fontSize: 12),
        labelLarge: TextStyle(color: Color(0xFFFFFFFF), fontSize: 14, fontWeight: FontWeight.w500),
        labelMedium: TextStyle(color: Color(0xFFFFFFFF), fontSize: 12, fontWeight: FontWeight.w500),
        labelSmall: TextStyle(color: Color(0xFFFFFFFF), fontSize: 10, fontWeight: FontWeight.w500),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFFFFF), // White background
          foregroundColor: const Color(0xFF000000), // Black text
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFFFFFFF), width: 2),
          foregroundColor: const Color(0xFFFFFFFF),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      iconTheme: const IconThemeData(
        color: Color(0xFFFFFFFF),
        size: 24,
      ),
    );
  }

  /// Gets the theme based on the specified mode
  static ThemeData getTheme(AppThemeMode themeMode) {
    switch (themeMode) {
      case AppThemeMode.light:
        return createLightTheme();
      case AppThemeMode.dark:
        return createDarkTheme();
      case AppThemeMode.highContrast:
        return createHighContrastTheme();
      case AppThemeMode.system:
        // This would normally detect system theme, defaulting to light here
        return createLightTheme();
    }
  }
}

/// Theme provider widget that manages the app theme
class ThemeProvider extends StatefulWidget {
  final Widget child;
  final AppThemeMode initialThemeMode;

  const ThemeProvider({
    super.key,
    required this.child,
    this.initialThemeMode = AppThemeMode.system,
  });

  @override
  State<ThemeProvider> createState() => _ThemeProviderState();
}

class _ThemeProviderState extends State<ThemeProvider> {
  late AppThemeMode _currentThemeMode;

  @override
  void initState() {
    super.initState();
    _currentThemeMode = widget.initialThemeMode;
  }

  /// Changes the current theme mode
  void changeThemeMode(AppThemeMode newThemeMode) {
    setState(() {
      _currentThemeMode = newThemeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.getTheme(_currentThemeMode),
      child: widget.child,
    );
  }

  /// Gets the current theme mode
  AppThemeMode get currentThemeMode => _currentThemeMode;
}

/// Extension to easily access the theme provider
extension ThemeProviderExtension on BuildContext {
  /// Changes the theme mode
  void changeThemeMode(AppThemeMode themeMode) {
    final provider = findAncestorStateOfType<_ThemeProviderState>();
    if (provider != null) {
      provider.changeThemeMode(themeMode);
    }
  }

  /// Gets the current theme mode
  AppThemeMode get currentThemeMode {
    final provider = findAncestorStateOfType<_ThemeProviderState>();
    return provider?.currentThemeMode ?? AppThemeMode.system;
  }
}