import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/auth_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
    required this.authService,
    required this.onSwitchToLogin,
  });

  final AuthService authService;
  final VoidCallback onSwitchToLogin;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static final RegExp _passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&#^()_+\-\[\]{};:,.<>]).{12,}$',
  );

  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _houseNumberController = TextEditingController();
  final _buildingNameController = TextEditingController();
  final _streetNameController = TextEditingController();
  final _barangayController = TextEditingController();
  final _cityController = TextEditingController();
  final _provinceController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _submitted = false;
  bool _termsAccepted = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedSuffix = '';
  String _selectedCountryCode = '+63';
  String? _errorMessage;

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _houseNumberController.dispose();
    _buildingNameController.dispose();
    _streetNameController.dispose();
    _barangayController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _zipCodeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _required(String? value, String message) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final error = _required(value, 'Please enter your email address.');
    if (error != null) {
      return error;
    }

    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value!.trim())) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final error = _required(value, 'Please enter your phone number.');
    if (error != null) {
      return error;
    }

    final digits = value!.trim();
    if (!RegExp(r'^\d+$').hasMatch(digits)) {
      return 'Numbers only are allowed.';
    }

    final country = _phoneCountries.firstWhere((item) => item.code == _selectedCountryCode);
    if (digits.length < country.minLength || digits.length > country.maxLength) {
      return country.phoneError;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final error = _required(value, 'Please enter a password.');
    if (error != null) {
      return error;
    }

    if (!_passwordRegex.hasMatch(value!)) {
      if (value.length < 12) {
        return 'Password must be at least 12 characters long.';
      }
      if (!RegExp(r'[A-Z]').hasMatch(value)) {
        return 'Password must contain at least one uppercase letter.';
      }
      if (!RegExp(r'[a-z]').hasMatch(value)) {
        return 'Password must contain at least one lowercase letter.';
      }
      if (!RegExp(r'\d').hasMatch(value)) {
        return 'Password must contain at least one number.';
      }
      return 'Password must contain at least one special character.';
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    final error = _required(value, 'Please confirm your password.');
    if (error != null) {
      return error;
    }

    if (value != _passwordController.text) {
      return 'Passwords do not match.';
    }
    return null;
  }

  double get _strengthProgress {
    final checks = [
      _passwordController.text.length >= 12,
      RegExp(r'[A-Z]').hasMatch(_passwordController.text),
      RegExp(r'[a-z]').hasMatch(_passwordController.text),
      RegExp(r'\d').hasMatch(_passwordController.text),
      RegExp(r'[@$!%*?&#^()_+\-\[\]{};:,.<>]').hasMatch(_passwordController.text),
    ];
    return checks.where((check) => check).length / 5.0;
  }

  String get _strengthLabel {
    if (_passwordRegex.hasMatch(_passwordController.text)) {
      return 'Very Strong';
    }
    final score = (_strengthProgress * 5).round();
    if (score >= 4) return 'Strong';
    if (score >= 2) return 'Medium';
    return 'Weak';
  }

  Color get _strengthColor {
    switch (_strengthLabel) {
      case 'Very Strong':
        return Colors.green;
      case 'Strong':
        return const Color(0xFF059669);
      case 'Medium':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFFDC2626);
    }
  }

  Future<void> _submit() async {
    setState(() => _submitted = true);

    if (!_termsAccepted) {
      setState(() {
        _errorMessage = 'You must agree to the Terms and Conditions first.';
      });
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false) || _isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await widget.authService.register(
        firstName: _firstNameController.text.trim(),
        middleName: _middleNameController.text.trim().isEmpty
            ? null
            : _middleNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        suffix: _selectedSuffix.isEmpty ? null : _selectedSuffix,
        email: _emailController.text.trim(),
        password: _passwordController.text,
        countryCode: _selectedCountryCode,
        phoneNumber: _phoneController.text.trim(),
        houseNumber: _houseNumberController.text.trim().isEmpty
            ? null
            : _houseNumberController.text.trim(),
        buildingName: _buildingNameController.text.trim().isEmpty
            ? null
            : _buildingNameController.text.trim(),
        streetName: _streetNameController.text.trim(),
        barangay: _barangayController.text.trim(),
        cityMunicipality: _cityController.text.trim(),
        province: _provinceController.text.trim(),
        zipCode: _zipCodeController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully!')),
      );
      widget.onSwitchToLogin();
    } on ApiException catch (error) {
      setState(() {
        _errorMessage = error.message;
      });
    } catch (_) {
      setState(() {
        _errorMessage = 'Unable to connect to the server. Check the backend URL and try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _field({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hintText,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    Iterable<String>? autofillHints,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
    void Function(String)? onFieldSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      inputFormatters: inputFormatters,
      obscureText: obscureText,
      maxLines: maxLines,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      decoration: buildAuthInputDecoration(
        context,
        labelText: label,
        icon: icon,
        hintText: hintText,
        suffixIcon: suffixIcon,
      ),
    );
  }

  Widget _section(String title, String subtitle, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthSectionHeader(title: title, subtitle: subtitle),
        const SizedBox(height: 14),
        child,
      ],
    );
  }

  Widget _phoneSection(BuildContext context) {
    final country = _phoneCountries.firstWhere((item) => item.code == _selectedCountryCode);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 520) {
          return Column(
            children: [
              DropdownButtonFormField<String>(
                initialValue: _selectedCountryCode,
                decoration: buildAuthInputDecoration(context, labelText: 'Code', icon: Icons.public),
                items: _phoneCountries
                    .map((countryCode) => DropdownMenuItem(
                          value: countryCode.code,
                          child: Text(countryCode.displayLabel),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedCountryCode = value ?? '+63'),
              ),
              const SizedBox(height: 12),
              _field(
                context: context,
                controller: _phoneController,
                label: 'Phone Number',
                hintText: country.placeholder,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.telephoneNumber],
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(15),
                ],
                validator: _validatePhone,
                onChanged: (_) => setState(() {}),
                onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
              ),
            ],
          );
        }

        return Row(
          children: [
            SizedBox(
              width: 164,
              child: DropdownButtonFormField<String>(
                initialValue: _selectedCountryCode,
                decoration: buildAuthInputDecoration(context, labelText: 'Code', icon: Icons.public),
                items: _phoneCountries
                    .map((countryCode) => DropdownMenuItem(
                          value: countryCode.code,
                          child: Text(countryCode.displayLabel),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedCountryCode = value ?? '+63'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _field(
                context: context,
                controller: _phoneController,
                label: 'Phone Number',
                hintText: country.placeholder,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.telephoneNumber],
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(15),
                ],
                validator: _validatePhone,
                onChanged: (_) => setState(() {}),
                onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _passwordSection(BuildContext context) {
    final rules = [
      ('At least 12 characters', _passwordController.text.length >= 12),
      ('One uppercase letter', RegExp(r'[A-Z]').hasMatch(_passwordController.text)),
      ('One lowercase letter', RegExp(r'[a-z]').hasMatch(_passwordController.text)),
      ('One number', RegExp(r'\d').hasMatch(_passwordController.text)),
      ('One special character', RegExp(r'[@$!%*?&#^()_+\-\[\]{};:,.<>]').hasMatch(_passwordController.text)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _field(
          context: context,
          controller: _passwordController,
          label: 'Password',
          hintText: 'Create a strong password',
          icon: Icons.lock_outline,
          keyboardType: TextInputType.visiblePassword,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.newPassword],
          obscureText: _obscurePassword,
          validator: _validatePassword,
          suffixIcon: IconButton(
            tooltip: _obscurePassword ? 'Show password' : 'Hide password',
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
          ),
          onChanged: (_) => setState(() {}),
          onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
        ),
        const SizedBox(height: 14),
        PasswordStrengthIndicator(
          label: _strengthLabel,
          progress: _strengthProgress,
          color: _strengthColor,
        ),
        const SizedBox(height: 14),
        for (var i = 0; i < rules.length; i++) ...[
          PasswordRequirementTile(label: rules[i].$1, isSatisfied: rules[i].$2),
          if (i != rules.length - 1) const SizedBox(height: 8),
        ],
        const SizedBox(height: 14),
        _field(
          context: context,
          controller: _confirmPasswordController,
          label: 'Confirm Password',
          hintText: 'Retype your password',
          icon: Icons.lock_reset_outlined,
          keyboardType: TextInputType.visiblePassword,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.newPassword],
          obscureText: _obscureConfirmPassword,
          validator: _validateConfirmPassword,
          suffixIcon: IconButton(
            tooltip: _obscureConfirmPassword ? 'Show confirm password' : 'Hide confirm password',
            onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
            icon: Icon(_obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
          ),
          onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
        ),
      ],
    );
  }

  Widget _twoUp(Widget left, Widget right) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 560) {
          return Column(children: [left, const SizedBox(height: 12), right]);
        }
        return Row(children: [Expanded(child: left), const SizedBox(width: 12), Expanded(child: right)]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      child: AuthCard(
        eyebrow: 'New Client',
        title: 'Create your account',
        child: Form(
          key: _formKey,
          autovalidateMode: _submitted ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _section(
                'Personal Information',
                'Split name fields help keep your profile accurate and searchable.',
                Column(
                  children: [
                    _twoUp(
                      _field(
                        context: context,
                        controller: _firstNameController,
                        label: 'First Name',
                        hintText: 'Given name',
                        icon: Icons.person_outline,
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.givenName],
                        validator: (value) => _required(value, 'Please enter your first name.'),
                        onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                      ),
                      _field(
                        context: context,
                        controller: _middleNameController,
                        label: 'Middle Name',
                        hintText: 'Optional',
                        icon: Icons.person_outline,
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.middleName],
                        validator: (_) => null,
                        onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _twoUp(
                      _field(
                        context: context,
                        controller: _lastNameController,
                        label: 'Last Name',
                        hintText: 'Family name',
                        icon: Icons.person_outline,
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.familyName],
                        validator: (value) => _required(value, 'Please enter your last name.'),
                        onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                      ),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedSuffix,
                        decoration: buildAuthInputDecoration(context, labelText: 'Suffix', icon: Icons.badge_outlined),
                        items: [
                          DropdownMenuItem(value: '', child: Text('None')),
                          DropdownMenuItem(value: 'Jr.', child: Text('Jr.')),
                          DropdownMenuItem(value: 'Sr.', child: Text('Sr.')),
                          DropdownMenuItem(value: 'II', child: Text('II')),
                          DropdownMenuItem(value: 'III', child: Text('III')),
                          DropdownMenuItem(value: 'IV', child: Text('IV')),
                        ],
                        onChanged: (value) => setState(() => _selectedSuffix = value ?? ''),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _section(
                'Email Address',
                'This is required and must be a valid email format.',
                _field(
                  context: context,
                  controller: _emailController,
                  label: 'Email Address',
                  hintText: 'name@example.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  validator: _validateEmail,
                  onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                ),
              ),
              const SizedBox(height: 20),
              _section('Contact Number', 'Choose a country code and enter digits only.', _phoneSection(context)),
              const SizedBox(height: 20),
              _section(
                'Address Information',
                'Break the address into searchable parts for better profile management.',
                Column(
                  children: [
                    _twoUp(
                      _field(
                        context: context,
                        controller: _houseNumberController,
                        label: 'House Number',
                        hintText: 'Optional',
                        icon: Icons.home_outlined,
                        keyboardType: TextInputType.streetAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.streetAddressLine1],
                        validator: (_) => null,
                        onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                      ),
                      _field(
                        context: context,
                        controller: _buildingNameController,
                        label: 'Building Name',
                        hintText: 'Optional',
                        icon: Icons.apartment_outlined,
                        keyboardType: TextInputType.streetAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.streetAddressLine2],
                        validator: (_) => null,
                        onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _field(
                      context: context,
                      controller: _streetNameController,
                      label: 'Street Name',
                      hintText: 'Required',
                      icon: Icons.signpost_outlined,
                      keyboardType: TextInputType.streetAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.streetAddressLine1],
                      maxLines: 2,
                      validator: (value) => _required(value, 'Please enter your street name.'),
                      onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    ),
                    const SizedBox(height: 12),
                    _twoUp(
                      _field(
                        context: context,
                        controller: _barangayController,
                        label: 'Barangay',
                        hintText: 'Required',
                        icon: Icons.location_on_outlined,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        validator: (value) => _required(value, 'Please enter your barangay.'),
                        onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                      ),
                      _field(
                        context: context,
                        controller: _cityController,
                        label: 'City / Municipality',
                        hintText: 'Required',
                        icon: Icons.location_city_outlined,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        validator: (value) => _required(value, 'Please enter your city or municipality.'),
                        onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _twoUp(
                      _field(
                        context: context,
                        controller: _provinceController,
                        label: 'Province',
                        hintText: 'Required',
                        icon: Icons.map_outlined,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        validator: (value) => _required(value, 'Please enter your province.'),
                        onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                      ),
                      _field(
                        context: context,
                        controller: _zipCodeController,
                        label: 'ZIP Code',
                        hintText: 'Numbers only',
                        icon: Icons.local_post_office_outlined,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.postalCode],
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                        validator: (value) {
                          final error = _required(value, 'Please enter your ZIP code.');
                          if (error != null) return error;
                          if (!RegExp(r'^\d+$').hasMatch(value!.trim())) {
                            return 'ZIP Code accepts numbers only.';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _section('Password Security', 'Use a strong password and confirm it exactly as entered.', _passwordSection(context)),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _termsAccepted,
                    onChanged: _isLoading ? null : (value) => setState(() => _termsAccepted = value ?? false),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        'I agree to the Terms and Conditions and Privacy Policy.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ],
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                AuthMessageBanner(text: _errorMessage!, isError: true),
              ],
              const SizedBox(height: 18),
              AuthPrimaryButton(
                label: 'Create Account',
                isBusy: _isLoading,
                onPressed: _isLoading || !_termsAccepted ? null : _submit,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _isLoading ? null : widget.onSwitchToLogin,
                child: const Text('Already have an account? Login'),
              ),
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () => showApiBaseUrlDialog(context, widget.authService.apiService),
                child: const Text('Set API URL'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhoneCountry {
  const _PhoneCountry({
    required this.code,
    required this.label,
    required this.placeholder,
    required this.minLength,
    required this.maxLength,
  });

  final String code;
  final String label;
  final String placeholder;
  final int minLength;
  final int maxLength;

  String get displayLabel => '$label ($code)';

  String get phoneError => minLength == maxLength
      ? 'Phone number must be exactly $minLength digits for $label.'
      : 'Phone number must be between $minLength and $maxLength digits for $label.';
}

const List<_PhoneCountry> _phoneCountries = [
  _PhoneCountry(code: '+63', label: 'Philippines', placeholder: '9XXXXXXXXX', minLength: 10, maxLength: 10),
  _PhoneCountry(code: '+1', label: 'United States', placeholder: '10 digits', minLength: 10, maxLength: 10),
  _PhoneCountry(code: '+44', label: 'United Kingdom', placeholder: '10 to 11 digits', minLength: 10, maxLength: 11),
  _PhoneCountry(code: '+61', label: 'Australia', placeholder: '9 digits', minLength: 9, maxLength: 9),
  _PhoneCountry(code: '+65', label: 'Singapore', placeholder: '8 digits', minLength: 8, maxLength: 8),
  _PhoneCountry(code: '+91', label: 'India', placeholder: '10 digits', minLength: 10, maxLength: 10),
  _PhoneCountry(code: '+81', label: 'Japan', placeholder: '10 digits', minLength: 10, maxLength: 10),
];
