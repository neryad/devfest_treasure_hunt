import 'package:flutter/widgets.dart';

import 'app_controller.dart';

/// Root scope exposing the [AppController] through Flutter's built-in
/// InheritedWidget (no third-party state management).
///
/// - `AppScope.of(context)` rebuilds dependents on every notification.
/// - `AppScope.read(context)` reads without subscribing.
class AppScope extends InheritedNotifier<AppController> {
  const AppScope({
    super.key,
    required AppController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in widget tree');
    return scope!.notifier!;
  }

  static AppController read(BuildContext context) {
    final scope = context
        .getElementForInheritedWidgetOfExactType<AppScope>()
        ?.widget as AppScope?;
    assert(scope != null, 'AppScope not found in widget tree');
    return scope!.notifier!;
  }
}