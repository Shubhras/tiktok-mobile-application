
class Loggers {
  static void info(Object? msg) {
    print('INFO: $msg');
  }

  static void success(Object? msg) {
    print('SUCCESS: ✅✅✅: $msg');
  }

  static void warning(Object? msg) {
    print('WARNING: ⚠️⚠️⚠️: $msg');
  }

  static void error(Object? msg) {
    print('ERROR: 🔴🔴🔴: $msg');
  }
}
