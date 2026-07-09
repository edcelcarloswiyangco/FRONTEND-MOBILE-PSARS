import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'verify_registration_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
    required this.authService,
    required this.onSwitchToLogin,
    required this.onAuthenticated,
  });

  final AuthService authService;
  final VoidCallback onSwitchToLogin;
  final VoidCallback onAuthenticated;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _purokController = TextEditingController();
  final _streetNameController = TextEditingController();
  final _houseNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _localContactNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  static const List<String> _suffixOptions = [
    'Jr.',
    'Sr.',
    'II',
    'III',
    'IV',
    'V',
  ];

  static const List<String> _barangayOptions = [
    'Barangay Agapito del Rosario',
    'Barangay Amsic',
    'Barangay Anunas',
    'Barangay Balibago',
    'Barangay Capaya',
    'Barangay Claro M. Recto',
    'Barangay Cuayan',
    'Barangay Cutcut',
    'Barangay Cutud',
    'Barangay Lourdes North West',
    'Barangay Lourdes Sur (Talimundoc)',
    'Barangay Lourdes Sur East',
    'Barangay Malabañas',
    'Barangay Margot',
    'Barangay Marisol (Ninoy Aquino)',
    'Barangay Mining',
    'Barangay Pampang (Santo Niño)',
    'Barangay Pandan',
    'Barangay Pulung Bulu',
    'Barangay Pulung Cacutud',
    'Barangay Pulung Maragul',
    'Barangay Salapungan',
    'Barangay San José',
    'Barangay San Nicolas',
    'Barangay Santa Teresita',
    'Barangay Santa Trinidad',
    'Barangay Santo Cristo',
    'Barangay Santo Domingo',
    'Barangay Santo Rosario (Población)',
    'Barangay Sapalibutad',
    'Barangay Sapangbato',
    'Barangay Tabun',
    'Barangay Virgen Delos Remedios',
  ];

  String? _selectedSuffix;
  String? _selectedBarangay;
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  bool _isLoading = false;
  String? _errorMessage;
  String? _emailServerError;

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _purokController.dispose();
    _streetNameController.dispose();
    _houseNumberController.dispose();
    _emailController.dispose();
    _localContactNumberController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String _composeFullName() {
    final parts = <String>[
      _firstNameController.text.trim(),
      if (_middleNameController.text.trim().isNotEmpty)
        _middleNameController.text.trim(),
      _lastNameController.text.trim(),
      if (_selectedSuffix != null && _selectedSuffix!.trim().isNotEmpty)
        _selectedSuffix!.trim(),
    ];

    return parts.join(' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String _normalizeContactNumber(String value) {
    final cleaned = value.trim();
    if (cleaned.startsWith('09') && cleaned.length == 11) {
      return '63${cleaned.substring(1)}';
    }

    return cleaned;
  }

  bool _isValidContactNumber(String value) {
    return RegExp(r'^09\d{9}$').hasMatch(value);
  }

  bool _isStrongPassword(String value) {
    return RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$')
        .hasMatch(value);
  }

  String _composeAddress() {
    final parts = <String>[
      if (_houseNumberController.text.trim().isNotEmpty)
        'House No. ${_houseNumberController.text.trim()}',
      'Street ${_streetNameController.text.trim()}',
      if (_purokController.text.trim().isNotEmpty)
        'Purok / Sitio / Subdivision ${_purokController.text.trim()}',
      if (_selectedBarangay != null && _selectedBarangay!.isNotEmpty)
        _selectedBarangay!,
    ];

    return parts.join(', ').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  Future<void> _requestRegistrationCode() async {
    if (!_formKey.currentState!.validate() || _isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _emailServerError = null;
    });

    try {
      await widget.authService.checkRegistrationEmailAvailability(
        email: _emailController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      final verified = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (context) => VerifyRegistrationScreen(
            authService: widget.authService,
            fullName: _composeFullName(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            passwordConfirmation: _confirmPasswordController.text,
            contactNumber: _normalizeContactNumber(_localContactNumberController.text),
            address: _composeAddress(),
            requestCodeOnInit: false,
          ),
        ),
      );

      if (verified == true && mounted) {
        widget.onAuthenticated();
      }
    } on ApiException catch (error) {
      final message = error.message;
      final lowerMessage = message.toLowerCase();
      final emailAlreadyClaimed = lowerMessage.contains('already') &&
          (lowerMessage.contains('email') ||
              lowerMessage.contains('taken') ||
              lowerMessage.contains('used'));

      setState(() {
        if (emailAlreadyClaimed) {
          _emailServerError = message;
        } else {
          _errorMessage = message;
        }
      });

      if (emailAlreadyClaimed) {
        _formKey.currentState?.validate();
      }
    } catch (_) {
      setState(() {
        _errorMessage =
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
                  title: 'Create your account',
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _firstNameController,
                          decoration: const InputDecoration(
                            labelText: 'First Name',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter your first name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _middleNameController,
                          decoration: const InputDecoration(
                            labelText: 'Middle Name (Optional)',
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _lastNameController,
                          decoration: const InputDecoration(
                            labelText: 'Last Name',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter your last name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String?>(
                          initialValue: _selectedSuffix,
                          decoration: const InputDecoration(
                            labelText: 'Suffix (Optional)',
                          ),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('None'),
                            ),
                            ..._suffixOptions.map(
                              (suffix) => DropdownMenuItem<String?>(
                                value: suffix,
                                child: Text(suffix),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedSuffix = value;
                            });
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (_) {
                            if (_emailServerError != null || _errorMessage != null) {
                              setState(() {
                                _emailServerError = null;
                                _errorMessage = null;
                              });
                            }
                          },
                          decoration: const InputDecoration(labelText: 'Email'),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Enter a valid email';
                            }
                            if (_emailServerError != null) {
                              return _emailServerError;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 18,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFD1D5DB)),
                              ),
                              child: const Text(
                                '63+',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _localContactNumberController,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(11),
                                ],
                                decoration: const InputDecoration(
                                  labelText: 'Mobile Number',
                                  hintText: '09171234567',
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Enter your mobile number';
                                  }
                                  if (!_isValidContactNumber(value.trim())) {
                                    return 'Use 09 followed by 9 more digits';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedBarangay,
                          decoration: const InputDecoration(
                            labelText: 'Barangay',
                          ),
                          items: _barangayOptions
                              .map(
                                (barangay) => DropdownMenuItem<String>(
                                  value: barangay,
                                  child: Text(barangay),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedBarangay = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Select your barangay';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _purokController,
                          decoration: const InputDecoration(
                            labelText: 'Purok / Sitio / Subdivision',
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _streetNameController,
                          decoration: const InputDecoration(
                            labelText: 'Street Name',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter your street name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _houseNumberController,
                          decoration: const InputDecoration(
                            labelText: 'House Number (Optional)',
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _isPasswordObscured,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _isPasswordObscured = !_isPasswordObscured;
                                });
                              },
                              icon: Icon(
                                _isPasswordObscured
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter a password';
                            }
                            if (!_isStrongPassword(value)) {
                              return 'Use 8+ chars with upper, lower, number, and special';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _isConfirmPasswordObscured,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _isConfirmPasswordObscured =
                                      !_isConfirmPasswordObscured;
                                });
                              },
                              icon: Icon(
                                _isConfirmPasswordObscured
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 14),
                          _MessageBanner(text: _errorMessage!, isError: true),
                        ],
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _requestRegistrationCode,
                            child: const Text('Next'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: widget.onSwitchToLogin,
                          child: const Text('Already have an account? Login'),
                        ),
                      ],
                    ),
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
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 55),
          padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
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
              Center(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              child,
            ],
          ),
        ),

        // LOGO OUTSIDE THE BOX
        Positioned(
          top: 0,
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 15,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Image.asset(
                'assets/icon/psars2_foreground.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ],
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
