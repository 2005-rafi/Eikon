import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class AppProviderScope extends StatelessWidget {
  final Widget child;
  final List<Object> overrides;

  const AppProviderScope({
    super.key,
    required this.child,
    this.overrides = const <Object>[],
  });

  @override
  Widget build(BuildContext context) {
    return ProviderScope(overrides: overrides.cast(), child: child);
  }
}
