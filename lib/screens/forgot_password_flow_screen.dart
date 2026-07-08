import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/api_service.dart';
import '../services/auth_service.dart';

class ForgotPasswordEmailScreen extends StatefulWidget {
  const ForgotPasswordEmailScreen({super.key, required this.authService});

  final AuthService authService;

  @override
  State<ForgotPasswordEmailScreen> createState() =>
      _ForgotPasswordEmailScreenState();
}

class _ForgotPasswordEmailScreenState extends State<ForgotPasswordEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  String? _message;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (!_formKey.currentState!.validate() || _isLoading) {
      return;
    }

    final email = _emailController.text.trim();

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      await widget.authService.requestPasswordResetCode(email: email);

      if (!mounted) {
        return;
      }

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ForgotPasswordCodeScreen(
            authService: widget.authService,
            email: email,
          ),
        ),
      );
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
    return _RecoveryScaffold(
      eyebrow: 'Recover access,',
      title: 'Forgot password',
      description:
          'Enter the email address on your account. We will send a 6-digit reset code to that inbox.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter your email';
                }
                if (!value.contains('@')) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            if (_message != null) ...[
              _RecoveryMessageBanner(
                text: _message!,
                isError: true,
              ),
              const SizedBox(height: 14),
            ],
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isLoading ? null : _sendCode,
                child: Text(_isLoading ? 'Sending...' : 'Send reset code'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
              child: const Text('Back to login'),
            ),
          ],
        ),
      ),
    );
  }
}

class ForgotPasswordCodeScreen extends StatefulWidget {
  const ForgotPasswordCodeScreen({
    super.key,
    required this.authService,
    required this.email,
  });

  final AuthService authService;
  final String email;

  @override
  State<ForgotPasswordCodeScreen> createState() =>
      _ForgotPasswordCodeScreenState();
}

class _ForgotPasswordCodeScreenState extends State<ForgotPasswordCodeScreen> {
  final _codeController = TextEditingController();

  bool _isLoading = false;
  String? _message;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
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
      await widget.authService.verifyPasswordResetCode(
        email: widget.email,
        code: code,
      );

      if (!mounted) {
        return;
      }

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ForgotPasswordNewPasswordScreen(
            authService: widget.authService,
            email: widget.email,
            code: code,
          ),
        ),
      );
    } on ApiException catch (error) {
      setState(() {
        _message = error.message;
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
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      await widget.authService.requestPasswordResetCode(email: widget.email);
      if (!mounted) {
        return;
      }

      setState(() {
        _message = 'A new reset code was sent to ${widget.email}.';
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
    return _RecoveryScaffold(
      eyebrow: 'Step 2 of 3,',
      title: 'Enter reset code',
      description:
          'Type the 6-digit code from your email. If you did not get it yet, send a new one from this page.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.email,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F766E),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
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
              labelText: 'Reset code',
              hintText: '123456',
            ),
          ),
          const SizedBox(height: 16),
          if (_message != null) ...[
            _RecoveryMessageBanner(
              text: _message!,
              isError: true,
            ),
            const SizedBox(height: 14),
          ],
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isLoading ? null : _continue,
              child: Text(_isLoading ? 'Checking...' : 'Continue'),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _isLoading ? null : _resendCode,
            child: const Text('Resend code'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            child: const Text('Back to email'),
          ),
        ],
      ),
    );
  }
}

class ForgotPasswordNewPasswordScreen extends StatefulWidget {
  const ForgotPasswordNewPasswordScreen({
    super.key,
    required this.authService,
    required this.email,
    required this.code,
  });

  final AuthService authService;
  final String email;
  final String code;

  @override
  State<ForgotPasswordNewPasswordScreen> createState() =>
      _ForgotPasswordNewPasswordScreenState();
}

class _ForgotPasswordNewPasswordScreenState
    extends State<ForgotPasswordNewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;
  String? _message;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isStrongPassword(String value) {
    return RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$')
        .hasMatch(value);
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';

    if (password.isEmpty) {
      return 'Enter a new password';
    }

    if (!_isStrongPassword(password)) {
      return 'Use at least 8 characters with upper, lower, number, and symbol.';
    }

    return null;
  }

  String? _validateConfirmation(String? value) {
    final confirmation = value ?? '';

    if (confirmation.isEmpty) {
      return 'Retype your new password';
    }

    if (confirmation != _passwordController.text) {
      return 'New password and retype password must match.';
    }

    return null;
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate() || _isLoading) {
      return;
    }

    final password = _passwordController.text;
    final confirmation = _confirmPasswordController.text;

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      await widget.authService.resetPassword(
        email: widget.email,
        code: widget.code,
        newPassword: password,
        passwordConfirmation: confirmation,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).popUntil((route) => route.isFirst);
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
    return _RecoveryScaffold(
      eyebrow: 'Step 3 of 3,',
      title: 'Create a new password',
      description:
          'Set a new password, retype it, and confirm the change to return to the login screen.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _passwordController,
              obscureText: _isPasswordObscured,
              decoration: InputDecoration(
                labelText: 'New password',
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _isPasswordObscured = !_isPasswordObscured;
                    });
                  },
                  icon: Icon(
                    _isPasswordObscured ? Icons.visibility_off : Icons.visibility,
                  ),
                ),
              ),
              validator: _validatePassword,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _isConfirmPasswordObscured,
              decoration: InputDecoration(
                labelText: 'Retype password',
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _isConfirmPasswordObscured = !_isConfirmPasswordObscured;
                    });
                  },
                  icon: Icon(
                    _isConfirmPasswordObscured
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                ),
              ),
              validator: _validateConfirmation,
            ),
            const SizedBox(height: 16),
            if (_message != null) ...[
              _RecoveryMessageBanner(
                text: _message!,
                isError: true,
              ),
              const SizedBox(height: 14),
            ],
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isLoading ? null : _changePassword,
                child: Text(
                  _isLoading ? 'Updating...' : 'Confirm password change',
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
              child: const Text('Back to code'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecoveryScaffold extends StatelessWidget {
  const _RecoveryScaffold({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.child,
  });

  final String eyebrow;
  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
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
                child: _RecoveryCard(
                  eyebrow: eyebrow,
                  title: title,
                  description: description,
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RecoveryCard extends StatelessWidget {
  const _RecoveryCard({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.child,
  });

  final String eyebrow;
  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              height: 1.45,
              color: Color(0xFF475467),
            ),
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}

class _RecoveryMessageBanner extends StatelessWidget {
  const _RecoveryMessageBanner({required this.text, required this.isError});

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