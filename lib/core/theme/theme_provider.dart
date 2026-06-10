import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local_storage/local_storage.dart';

const String _themeModeKey = 'theme_mode';
const String _themeColorKey = 'theme_color';

final List<Color> themeSeedColors = [
  Colors.blue,
  Colors.green,
  Colors.red,
  Colors.orange,
  Colors.purple,
  Colors.teal,
];

class ThemeState {
  final ThemeMode mode;
  final Color seedColor;

  const ThemeState({required this.mode, required this.seedColor});

  ThemeState copyWith({ThemeMode? mode, Color? seedColor}) {
    return ThemeState(
      mode: mode ?? this.mode,
      seedColor: seedColor ?? this.seedColor,
    );
  }
}

class ThemeNotifier extends Notifier<ThemeState> {
  @override
  ThemeState build() {
    final modeValue = LocalStorage.getString(_themeModeKey);
    final colorValue = LocalStorage.getString(_themeColorKey);

    var mode = ThemeMode.system;
    if (modeValue == ThemeMode.light.name) {
      mode = ThemeMode.light;
    } else if (modeValue == ThemeMode.dark.name) {
      mode = ThemeMode.dark;
    }

    Color seedColor = Colors.blue;
    if (colorValue != null) {
      final parsedColor = int.tryParse(colorValue);
      if (parsedColor != null) {
        seedColor = Color(parsedColor);
      }
    }

    return ThemeState(mode: mode, seedColor: seedColor);
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(mode: mode);
    LocalStorage.setString(_themeModeKey, mode.name);
  }

  void setSeedColor(Color color) {
    state = state.copyWith(seedColor: color);
    LocalStorage.setString(_themeColorKey, color.toARGB32().toString());
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeState>(
  ThemeNotifier.new,
);
