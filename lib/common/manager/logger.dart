// import 'dart:developer' as developer;

// class Loggers {
//   static void info(Object? msg) {
//     developer.log('$msg', name: 'INFO');
//   }

//   static void success(Object? msg) {
//     developer.log('✅✅✅: $msg', name: 'SUCCESS');
//   }

//   static void warning(Object? msg) {
//     developer.log('⚠️⚠️⚠️: $msg', name: 'WARNING');
//   }

//   static void error(Object? msg) {
//     developer.log('🔴🔴🔴: $msg', name: 'ERROR');
//   }
// }


import 'dart:developer' as developer;

class Loggers {
  static void info(Object? msg) {
    print('INFO: $msg');
    developer.log('$msg', name: 'INFO', level: 0);
  }

  static void success(Object? msg) {
    print('SUCCESS: $msg');
    developer.log('✅ $msg', name: 'SUCCESS', level: 200);
  }

  static void warning(Object? msg) {
    print('WARNING: $msg');
    developer.log('⚠️ $msg', name: 'WARNING', level: 500);
  }

  static void error(Object? msg) {
    print('ERROR: $msg'); // VS CODE always shows this
    developer.log('🔴 $msg', name: 'ERROR', level: 1000);
  }
}
