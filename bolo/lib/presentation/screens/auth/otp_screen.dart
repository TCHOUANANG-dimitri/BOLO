import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../widgets/bolo_button.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  final String destination; // '/home' or '/provider-setup'

  const OtpScreen({super.key, required this.phone, required this.destination});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isVerifying = false;
  bool _isResending = false;
  int _resendCountdown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    // Auto-focus first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  void _startCountdown() {
    _resendCountdown = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendCountdown == 0) {
        t.cancel();
      } else {
        setState(() => _resendCountdown--);
      }
    });
  }

  String get _otp =>
      _controllers.map((c) => c.text).join();

  Future<void> _verify() async {
    if (_otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entrez le code à 6 chiffres')),
      );
      return;
    }

    setState(() => _isVerifying = true);
    await Future.delayed(const Duration(seconds: 1, milliseconds: 500));

    if (!mounted) return;
    // Accept any 6-digit code for demo
    setState(() => _isVerifying = false);
    _showSuccessAndNavigate();
  }

  void _showSuccessAndNavigate() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: AppColors.success, size: 40),
              ),
              const SizedBox(height: 16),
              Text('Numéro vérifié !', style: AppTextStyles.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Votre compte a été créé avec succès.',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.go(widget.destination);
                  },
                  child: const Text('Accéder à l\'application'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _resend() async {
    setState(() => _isResending = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isResending = false);
    _startCountdown();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Code renvoyé au ${widget.phone}'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _onDigitEntered(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
    if (_otp.length == 6) _verify();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.sms_rounded,
                  color: AppColors.primary, size: 32),
            ),
            const SizedBox(height: 24),

            Text('Vérification SMS', style: AppTextStyles.headlineLarge),
            const SizedBox(height: 10),
            Text.rich(
              TextSpan(
                text: 'Un code à 6 chiffres a été envoyé au ',
                style: AppTextStyles.bodyMedium,
                children: [
                  TextSpan(
                    text: widget.phone,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // OTP fields
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (i) => _OtpField(
                controller: _controllers[i],
                focusNode: _focusNodes[i],
                onChanged: (v) => _onDigitEntered(i, v),
              )),
            ),
            const SizedBox(height: 36),

            // Verify button
            BoloButton(
              onPressed: _verify,
              label: 'Vérifier',
              isLoading: _isVerifying,
            ),
            const SizedBox(height: 24),

            // Resend
            Center(
              child: _resendCountdown > 0
                  ? Text.rich(
                      TextSpan(
                        text: 'Renvoyer le code dans ',
                        style: AppTextStyles.bodyMedium,
                        children: [
                          TextSpan(
                            text: '${_resendCountdown}s',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _isResending
                      ? const CircularProgressIndicator(
                          color: AppColors.primary, strokeWidth: 2)
                      : GestureDetector(
                          onTap: _resend,
                          child: Text(
                            'Renvoyer le code',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
            ),

            const Spacer(),

            // Hint for demo
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Mode démo : entrez n\'importe quel code à 6 chiffres',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _OtpField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _OtpField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 56,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: AppTextStyles.headlineSmall.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: controller.text.isNotEmpty
              ? AppColors.primaryLight
              : AppColors.cardBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: controller.text.isNotEmpty
                  ? AppColors.primary
                  : Colors.transparent,
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: controller.text.isNotEmpty
                  ? AppColors.primary
                  : Colors.transparent,
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
    );
  }
}
