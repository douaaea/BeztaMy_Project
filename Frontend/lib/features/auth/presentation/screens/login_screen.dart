import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Please enter both email and password');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      final authResponse = await authService.login(email, password);

      // Store token and user info
      await ref.read(authTokenProvider.notifier).setToken(authResponse.token);
      await ref.read(currentUserProvider.notifier).setUser(authResponse);

      if (!mounted) return;

      // Fix for Flutter Web focus issue
      FocusScope.of(context).unfocus();
      await Future.delayed(const Duration(milliseconds: 200));

      if (!mounted) return;

      // Navigate to dashboard
      context.go('/dashboard');
    } on NetworkException catch (_) {
      // On Flutter Web, 401s sometimes show as Unknown/Network error (opaque response)
      if (!mounted) return;
      _showError('Email or password not correct');
    } on ApiException catch (e) {
      if (!mounted) return;
      // Check for 401 Unauthorized or 403 Forbidden which usually mean invalid credentials
      if (e.statusCode == 401 || e.statusCode == 403 || e.message.toLowerCase().contains('bad credentials')) {
        _showError('Email or password not correct');
      } else {
        _showError(e.message);
      }
    } catch (e) {
      if (!mounted) return;
      _showError('An unexpected error occurred. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 920;

    return Scaffold(
      backgroundColor: AppConstants.appBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: isWide ? _buildWideLayout(context) : _buildStackedLayout(context),
          ),
        ),
      ),
    );
  }

  Widget _buildStackedLayout(BuildContext context) {
    return Column(
      children: [
        _buildBrandPanel(isCompact: true),
        const SizedBox(height: 24),
        _buildFormCard(context),
      ],
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 5, child: _buildBrandPanel()),
        const SizedBox(width: 32),
        Expanded(flex: 5, child: _buildFormCard(context)),
      ],
    );
  }

  Widget _buildBrandPanel({bool isCompact = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 24 : 48, vertical: isCompact ? 24 : 72),
      decoration: BoxDecoration(
        color: const Color(0xFF1B4332),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            'assets/images/beztami_logo.png',
            height: isCompact ? 72 : 96,
          ),
          const SizedBox(height: 32),
          const Text(
            'BeztaMy, your calm space for finances.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Track spending, plan budgets, and watch your goals get closer one mindful action at a time.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: const [
                Icon(Icons.lock_clock, color: Colors.white, size: 26),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Secure banking grade encryption keeps your data safe.',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFE6E0D2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome back',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1B4332),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Sign in to view your dashboard and financial insights.',
            style: TextStyle(color: Color(0xFF6F6F6F)),
          ),
          const SizedBox(height: 24),
          _buildLabel('Email Address'),
          const SizedBox(height: 6),
          TextField(
            key: const Key('emailField'),
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            enabled: !_isLoading,
            decoration: _fieldDecoration('you@example.com'),
          ),
          const SizedBox(height: 18),
          _buildLabel('Password'),
          const SizedBox(height: 6),
          TextField(
            key: const Key('passwordField'),
            controller: _passwordController,
            obscureText: _obscurePassword,
            enabled: !_isLoading,
            onSubmitted: (_) => _handleLogin(),
            decoration: _fieldDecoration('Enter your password').copyWith(
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF565D6D)),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Checkbox(
                value: _rememberMe,
                onChanged: _isLoading ? null : (value) => setState(() => _rememberMe = value ?? false),
                activeColor: const Color(0xFF1B4332),
              ),
              const Text(
                'Remember me',
                style: TextStyle(color: Color(0xFF565D6D)),
              ),
              const Spacer(),
              TextButton(
                onPressed: _isLoading ? null : () => context.go('/forgot-password'),
                child: const Text(
                  'Forgot password?',
                  style: TextStyle(color: Color(0xFF1B4332), fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              key: const Key('signInButton'),
              onPressed: _isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 6,
              children: [
                const Text(
                  'New to BeztaMy?',
                  style: TextStyle(color: Color(0xFF565D6D)),
                ),
                GestureDetector(
                  key: const Key('createAccountLink'),
                  onTap: () => context.go('/signup'),
                  child: const Text(
                    'Create an account',
                    style: TextStyle(
                      color: Color(0xFF1B4332),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        color: Color(0xFF7A7A7A),
        fontWeight: FontWeight.w600,
        letterSpacing: 1.1,
      ),
    );
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppConstants.appBackgroundColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFE6E0D2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFE6E0D2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFF1B5E20)),
      ),
    );
  }
}
