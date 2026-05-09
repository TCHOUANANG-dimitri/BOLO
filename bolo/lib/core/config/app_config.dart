class AppConfig {
  // ─── Campay Mobile Money (Cameroun) ──────────────────────────────────────
  // Sandbox : demo.campay.net  |  Production : campay.net
  static const String campayBaseUrl = 'https://demo.campay.net/api/';
  // static const String campayBaseUrl = 'https://campay.net/api/'; // production
  static const String campayUsername = 'YOUR_CAMPAY_USERNAME';
  static const String campayPassword = 'YOUR_CAMPAY_PASSWORD';

  // ─── App ─────────────────────────────────────────────────────────────────
  static const String appName = 'BOLO';
  static const String currency = 'XAF';
  static const String currencyLabel = 'FCFA';
  static const String countryCode = '237'; // Cameroun

  // Activer le mode démo (paiement simulé si Campay non configuré)
  static bool get isDemoPayment =>
      campayUsername == 'YOUR_CAMPAY_USERNAME' ||
      campayPassword == 'YOUR_CAMPAY_PASSWORD';
}
