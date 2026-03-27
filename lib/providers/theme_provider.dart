import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _key = 'themeMode'; // 0=system, 1=light, 2=dark
  int _themeModeIndex = 0; // default: system

  bool get isDarkMode => _themeModeIndex == 2;

  ThemeMode get themeMode {
    switch (_themeModeIndex) {
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String get themeModeLabel {
    switch (_themeModeIndex) {
      case 1:
        return 'Açık';
      case 2:
        return 'Koyu';
      default:
        return 'Otomatik';
    }
  }

  IconData get themeModeIcon {
    switch (_themeModeIndex) {
      case 1:
        return Icons.light_mode_rounded;
      case 2:
        return Icons.dark_mode_rounded;
      default:
        return Icons.brightness_auto_rounded;
    }
  }

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _themeModeIndex = prefs.getInt(_key) ?? 0;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeModeIndex = (_themeModeIndex + 1) % 3; // cycle: system -> light -> dark
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, _themeModeIndex);
    notifyListeners();
  }
}
