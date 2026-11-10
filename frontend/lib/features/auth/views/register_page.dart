import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_color.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const new({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _username = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _hide = true;

  @override
  void dispose() {
    for (final c in [_email, _username, _phone, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final ok = await context.read<AuthProvider>().register(
      email: _email.text,
      username: _username.text,
      phone: _phone.text,
      password: _password.text,
      confirm: _confirm.text,
    );
    if (ok && mounted) Navigator.of(context).popUntil((r) => r.isFirst);
  }

  InputDecoration _dec(String label, {IconData? icon}) {
    return InputDecoration(
      hintText: label,
      hintStyle: GoogleFonts.dmSans(
        fontSize: 13,
        color: const Color(0xFF94A3B8),
      ),
      prefixIcon: icon != null
          ? Icon(icon, color: const Color(0xFF64748B), size: 21)
          : null,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDC2626)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const FaIcon(
            FontAwesomeIcons.angleLeft,
            color: Color(0xFF0F172A),
            size: 20,
          ),
        ),
        title: Text(
          'Create account',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header icon
                    Center(
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F0FF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: FaIcon(
                            FontAwesomeIcons.solidUser,
                            color: Color(0xFF2563EB),
                            size: 30,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Heading
                    Text(
                      'Get started',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.7,
                        color: const Color(0xFF0F172A),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      'Create an account and turn your images into digital text.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        height: 1.5,
                        color: const Color(0xFF64748B),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Email
                    _buildLabel('Email'),
                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      decoration: _dec(
                        'Enter your email',
                        icon: Icons.email_outlined,
                      ),
                      validator: (v) {
                        final t = v?.trim() ?? '';

                        if (t.isEmpty) return 'Please enter your email';

                        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                            .hasMatch(t)) {
                          return 'Please enter a valid email';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // Username
                    _buildLabel('Username'),
                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _username,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.newUsername],
                      decoration: _dec(
                        'Choose a username (optional)',
                        icon: Icons.person_outline_rounded,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Phone
                    _buildLabel('Phone number'),
                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.telephoneNumber],
                      decoration: _dec(
                        'Enter your phone number (optional)',
                        icon: Icons.phone_outlined,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Password
                    _buildLabel('Password'),
                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _password,
                      obscureText: _hide,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.newPassword],
                      decoration:
                          _dec(
                            '6–12 characters',
                            icon: Icons.lock_outline_rounded,
                          ).copyWith(
                            suffixIcon: IconButton(
                              tooltip: _hide
                                  ? 'Show password'
                                  : 'Hide password',
                              icon: Icon(
                                _hide
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: const Color(0xFF64748B),
                                size: 21,
                              ),
                              onPressed: () {
                                setState(() => _hide = !_hide);
                              },
                            ),
                          ),
                      validator: (v) {
                        final t = v ?? '';

                        if (t.isEmpty) return 'Please enter a password';

                        if (t.length < 6 || t.length > 12) {
                          return 'Password must be 6–12 characters';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // Confirm password
                    _buildLabel('Confirm password'),
                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _confirm,
                      obscureText: _hide,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.newPassword],
                      onFieldSubmitted: (_) {
                        if (!auth.loading) _submit();
                      },
                      decoration: _dec(
                        'Re-enter your password',
                        icon: Icons.verified_user_outlined,
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Please confirm your password';
                        }

                        if (v != _password.text) {
                          return 'Passwords do not match';
                        }

                        return null;
                      },
                    ),

                    // Authentication error
                    if (auth.error != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFECACA)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: Color(0xFFDC2626),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                auth.error!,
                                style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  height: 1.4,
                                  color: const Color(0xFFB91C1C),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 28),

                    // Sign up button
                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: auth.loading ? null : _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFF93B4F8),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: auth.loading
                            ? const SizedBox(
                                height: 21,
                                width: 21,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Create account',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.document_scanner_outlined,
                          size: 16,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Your images, converted to text.',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account?",
                          style: TextStyle(fontSize: 12),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            "Login",
                            style: GoogleFonts.dmSans(
                              color: AppColor.link,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildLabel(String text) {
  return Text(
    text,
    style: GoogleFonts.dmSans(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF334155),
    ),
  );
}
