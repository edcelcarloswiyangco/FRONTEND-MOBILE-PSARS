import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/api_service.dart';
import '../services/auth_service.dart';

class VerifyRegistrationScreen extends StatefulWidget {
  const VerifyRegistrationScreen({
    super.key,
    required this.authService,
    required this.fullName,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    required this.contactNumber,
    required this.address,
    this.requestCodeOnInit = true,
  });

  final AuthService authService;
  final String fullName;
  final String email;
  final String password;
  final String passwordConfirmation;
  final String contactNumber;
  final String address;
  final bool requestCodeOnInit;

  @override
  State<VerifyRegistrationScreen> createState() =>
      _VerifyRegistrationScreenState();
}

class _VerifyRegistrationScreenState extends State<VerifyRegistrationScreen> {
  final _codeController = TextEditingController();

  bool _isLoading = false;
  String? _message;
  bool _codeRequested = false;

  @override
  void initState() {
    super.initState();
    if (widget.requestCodeOnInit) {
      _requestCode();
    } else {
      _codeRequested = true;
      _message = 'A verification code was sent to ${widget.email}.';
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();

    if (code.length != 6) {
      setState(() {
        _message = 'Enter the 6-digit code sent to your email.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      await widget.authService.verifyRegistrationCode(
        email: widget.email,
        code: code,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      setState(() {
        _message = error.message;
      });
    } catch (_) {
      setState(() {
        _message =
            'Unable to connect to the server. Check the backend URL and try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _requestCode() async {
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      await widget.authService.requestRegistrationCode(
        fullName: widget.fullName,
        email: widget.email,
        password: widget.password,
        passwordConfirmation: widget.passwordConfirmation,
        contactNumber: widget.contactNumber,
        address: widget.address,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _codeRequested = true;
        _message = 'A verification code was sent to ${widget.email}.';
      });
    } on ApiException catch (error) {
      setState(() {
        _message = error.message;
      });
    } catch (_) {
      setState(() {
        _message =
            'Unable to connect to the server. Check the backend URL and try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendCode() async {
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      await widget.authService.requestRegistrationCode(
        fullName: widget.fullName,
        email: widget.email,
        password: widget.password,
        passwordConfirmation: widget.passwordConfirmation,
        contactNumber: widget.contactNumber,
        address: widget.address,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _codeRequested = true;
        _message = 'A new verification code was sent to ${widget.email}.';
      });
    } on ApiException catch (error) {
      setState(() {
        _message = error.message;
      });
    } catch (_) {
      setState(() {
        _message =
            'Unable to connect to the server. Check the backend URL and try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sendButtonLabel = _codeRequested ? 'Resend Code' : 'Send Code';

    final isErrorMessage = _message != null &&
        (_message!.startsWith('Unable') ||
            _message!.startsWith('Enter') ||
            _message!.contains('Invalid') ||
            _message!.contains('expired'));

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF102A43), Color(0xFF1F8A70), Color(0xFFF4F7F7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: _AuthCard(
                  eyebrow: 'Almost there,',
                  title: 'Verify your email',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Email Verification',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _codeRequested
                            ? 'Enter the 6-digit verification code sent to your email address to complete your registration.'
                            : 'Send a code to your email first, then enter the 6-digit verification code here.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(height: 1.4),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.email,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F766E),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _codeController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          letterSpacing: 8,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Verification Code',
                          hintText: '_ _ _ _ _ _',
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_message != null) ...[
                        _MessageBanner(
                          text: _message!,
                          isError: isErrorMessage,
                        ),
                        const SizedBox(height: 14),
                      ],
                      const SizedBox(height: 6),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _isLoading || !_codeRequested ? null : _verifyCode,
                          child: Text(
                            _isLoading
                                ? 'Verifying...'
                                : 'Verify & Create Account',
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isLoading
                                  ? null
                                  : (_codeRequested ? _resendCode : _requestCode),
                              child: Text(sendButtonLabel),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Code expires in 5 minutes.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF475467),
                        ),
                      ),
                      TextButton(
                        onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                        child: const Text('Back to registration'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthCard extends StatelessWidget {
  const _AuthCard({
    required this.eyebrow,
    required this.title,
    required this.child,
  });

  final String eyebrow;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow,
            style: const TextStyle(
              color: Color(0xFF0F766E),
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}

class _MessageBanner extends StatelessWidget {
  const _MessageBanner({required this.text, required this.isError});

  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError ? const Color(0xFFFFF1F0) : const Color(0xFFECFDF3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isError ? const Color(0xFFB42318) : const Color(0xFF027A48),
        ),
      ),
    );
  }
}