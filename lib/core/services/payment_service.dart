import 'package:dio/dio.dart';
import '../config/app_config.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._();
  factory PaymentService() => _instance;
  PaymentService._();

  late final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConfig.campayBaseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {'Content-Type': 'application/json'},
  ));

  String? _token;
  DateTime? _tokenExpiry;

  // ─── Auth token ───────────────────────────────────────────────────────────

  Future<String> _getToken() async {
    if (_token != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(_tokenExpiry!)) {
      return _token!;
    }
    final resp = await _dio.post('/token/', data: {
      'username': AppConfig.campayUsername,
      'password': AppConfig.campayPassword,
    });
    _token = resp.data['token'] as String;
    _tokenExpiry = DateTime.now().add(const Duration(minutes: 55));
    return _token!;
  }

  // ─── Initier un paiement Mobile Money ────────────────────────────────────

  Future<PaymentInitResult> initiatePayment({
    required int amount,
    required String phone,
    required String description,
    required String externalReference,
  }) async {
    if (AppConfig.isDemoPayment) {
      // Mode démo : simule une référence de paiement
      await Future.delayed(const Duration(seconds: 1));
      return PaymentInitResult(
        reference: 'DEMO_${DateTime.now().millisecondsSinceEpoch}',
        ussdCode: '#150*50#',
        isDemo: true,
      );
    }

    final token = await _getToken();
    final formatted = _formatPhone(phone);

    final resp = await _dio.post(
      '/collect/',
      data: {
        'amount': amount.toString(),
        'currency': AppConfig.currency,
        'from': formatted,
        'description': description,
        'external_reference': externalReference,
      },
      options: Options(headers: {'Authorization': 'Token $token'}),
    );

    return PaymentInitResult(
      reference: resp.data['reference'] as String,
      ussdCode: resp.data['ussd_code'] as String?,
    );
  }

  // ─── Vérifier le statut ───────────────────────────────────────────────────

  Future<PaymentStatus> checkStatus(String reference) async {
    if (reference.startsWith('DEMO_')) {
      await Future.delayed(const Duration(seconds: 2));
      return PaymentStatus(
        reference: reference,
        status: 'SUCCESSFUL',
        amount: null,
        operator: 'demo',
      );
    }

    final token = await _getToken();
    final resp = await _dio.get(
      '/transaction/$reference/',
      options: Options(headers: {'Authorization': 'Token $token'}),
    );
    return PaymentStatus(
      reference: reference,
      status: resp.data['status'] as String,
      amount: resp.data['amount'],
      operator: resp.data['operator'] as String?,
    );
  }

  // ─── Polling jusqu'à confirmation ────────────────────────────────────────

  Future<PaymentStatus> pollUntilDone(
    String reference, {
    Duration interval = const Duration(seconds: 5),
    Duration timeout = const Duration(minutes: 3),
    void Function(String status)? onUpdate,
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      await Future.delayed(interval);
      final s = await checkStatus(reference);
      onUpdate?.call(s.status);
      if (s.isSuccessful || s.isFailed) return s;
    }
    throw PaymentTimeoutException();
  }

  // ─── Formatage numéro Cameroun ────────────────────────────────────────────

  String _formatPhone(String phone) {
    final clean = phone.replaceAll(RegExp(r'[\s\-\(\)+]'), '');
    if (clean.startsWith('237')) return clean;
    if (clean.startsWith('6') || clean.startsWith('2')) return '237$clean';
    return '237$clean';
  }
}

// ─── Data classes ─────────────────────────────────────────────────────────────

class PaymentInitResult {
  final String reference;
  final String? ussdCode;
  final bool isDemo;
  const PaymentInitResult({
    required this.reference,
    this.ussdCode,
    this.isDemo = false,
  });
}

class PaymentStatus {
  final String reference;
  final String status; // SUCCESSFUL | FAILED | PENDING
  final dynamic amount;
  final String? operator;

  const PaymentStatus({
    required this.reference,
    required this.status,
    this.amount,
    this.operator,
  });

  bool get isSuccessful => status == 'SUCCESSFUL';
  bool get isFailed => status == 'FAILED';
  bool get isPending => status == 'PENDING';
}

class PaymentTimeoutException implements Exception {
  @override
  String toString() => 'Le paiement a expiré. Veuillez réessayer.';
}
