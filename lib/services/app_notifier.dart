import 'package:flutter/foundation.dart';

/// Global data-change notifier.
/// Call [AppNotifier.instance.notify()] after any DB write to trigger
/// all listening screens to reload their data immediately.
class AppNotifier extends ChangeNotifier {
  AppNotifier._();
  static final instance = AppNotifier._();
  void notify() => notifyListeners();
}
