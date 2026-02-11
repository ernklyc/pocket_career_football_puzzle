import 'dart:developer' as dev;

/// Basit loglama servisi.
class AppLogger {
  AppLogger._();

  static void info(String message, {String? tag}) {
    dev.log('ℹ️ $message', name: tag ?? 'APP');
  }

  static void warning(String message, {String? tag}) {
    dev.log('⚠️ $message', name: tag ?? 'APP');
  }

  static void error(String message, {Object? error, StackTrace? stackTrace, String? tag}) {
    dev.log(
      '❌ $message',
      name: tag ?? 'APP',
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void debug(String message, {String? tag}) {
    assert(() {
      dev.log('🐛 $message', name: tag ?? 'APP');
      return true;
    }());
  }

  static void sdk(String sdk, String message) {
    dev.log('📦 [$sdk] $message', name: 'SDK');
  }

  static void navigation(String route) {
    dev.log('🧭 → $route', name: 'NAV');
  }

  static void economy(String action, int amount, int newBalance) {
    dev.log('💰 $action: $amount → Balance: $newBalance', name: 'ECON');
  }
}
