class ApiConfig {
  ApiConfig._();

  // ---------------------------------------------------------
  // BASE URL CONFIGURATION
  // ---------------------------------------------------------

  // 🚀 PRODUCTION
  // static const String baseUrl = 'https://ftprotech.in/';
  // static const String dbName = 'ftprotech';

  // 🧪 TESTING / STAGING
  static const String baseUrl = 'https://test.ftprotech.in/';
  static const String dbName = 'pmt_test';

  // 🛠️ ALTERNATE TESTING (Odoo 18)
  // static const String baseUrl = 'https://test-h-r-m-s-18.odoo.com';
  // static const String dbName = 'test-h-r-m-s-18';
}
