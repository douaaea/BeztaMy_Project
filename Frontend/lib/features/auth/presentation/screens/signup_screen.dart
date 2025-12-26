import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants.dart';
import '../../../../core/network/api_exception.dart';
import '../../data/models/register_request.dart';
import '../../domain/providers/auth_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _acceptedTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  Uint8List? _profileImageBytes;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _statusController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final telephone = _telephoneController.text.trim();
    final status = _statusController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Validation
    if (firstName.isEmpty || lastName.isEmpty || telephone.isEmpty) {
      _showError('Please fill in all required fields');
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      _showError('Please enter a valid email address (e.g., name@example.com)');
      return;
    }

    if (password.length < 8) {
      _showError('Password must be at least 8 characters long');
      return;
    }

    if (password != confirmPassword) {
      _showError('The password and confirm password do not match');
      return;
    }

    if (!_acceptedTerms) {
      _showError('Please accept the Terms of Service and Privacy Policy');
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? profilePictureBase64;
      if (_profileImageBytes != null) {
        profilePictureBase64 = base64Encode(_profileImageBytes!);
      }

      final authService = ref.read(authServiceProvider);
      final request = RegisterRequest(
        email: email,
        firstName: firstName,
        lastName: lastName,
        telephone: telephone,
        password: password,
        profilePicture: profilePictureBase64,
        status: status.isNotEmpty ? status : 'ACTIVE', // Default to ACTIVE if empty 
      );

      final authResponse = await authService.register(request);

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
    } on ApiException catch (e) {
      if (!mounted) return;
      // Handle "Email already exists" from backend which is usually 400
      if (e.message.contains('Email already exists')) {
        _showError('This email is already registered. Please sign in instead.');
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
    final isWide = MediaQuery.of(context).size.width >= 920;

    return Scaffold(
      backgroundColor: AppConstants.appBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: isWide ? _buildWide(context) : _buildStacked(context),
          ),
        ),
      ),
    );
  }

  Widget _buildStacked(BuildContext context) {
    return Column(
      children: [
        _buildStoryPanel(isCompact: true),
        const SizedBox(height: 24),
        _buildFormCard(context),
      ],
    );
  }

  Widget _buildWide(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 5, child: _buildStoryPanel()),
        const SizedBox(width: 32),
        Expanded(flex: 5, child: _buildFormCard(context)),
      ],
    );
  }

  Widget _buildStoryPanel({bool isCompact = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 24 : 48, vertical: isCompact ? 28 : 80),
      decoration: BoxDecoration(
        color: const Color(0xFF143D2A),
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
            'Create balance in your money habits.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Automated insights, goal driven coaching, and mindful nudges help you stay intentional with every transaction.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _StoryPoint(text: 'Plan savings with guided targets.'),
              SizedBox(height: 10),
              _StoryPoint(text: 'Know exactly where your money flows.'),
              SizedBox(height: 10),
              _StoryPoint(text: 'Manage your Expenses mindfully.'),
            ],
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
            'Join BeztaMy',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1B4332),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Set up your account and personalize your money journey.',
            style: TextStyle(color: Color(0xFF6F6F6F)),
          ),
          const SizedBox(height: 24),
          _buildProfileImageSection(),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildField('First Name', _firstNameController, hint: 'Enter your first name', keyName: 'firstNameField')),
              const SizedBox(width: 16),
              Expanded(child: _buildField('Last Name', _lastNameController, hint: 'Enter your last name', keyName: 'lastNameField')),
            ],
          ),
          const SizedBox(height: 18),
          _buildField('Email Address', _emailController, hint: 'you@example.com', keyboardType: TextInputType.emailAddress, keyName: 'signupEmailField'),
          const SizedBox(height: 18),
          _buildField('Phone Number', _telephoneController, hint: '+1234567890', keyboardType: TextInputType.phone, keyName: 'phoneField'),
          const SizedBox(height: 18),
          _buildField('Status', _statusController, hint: 'e.g. Employee, Freelancer', keyboardType: TextInputType.text, keyName: 'statusField'),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _buildPasswordField(
                  keyName: 'signupPasswordField',
                  label: 'Password',
                  controller: _passwordController,
                  obscure: _obscurePassword,
                  onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPasswordField(
                  keyName: 'confirmPasswordField',
                  label: 'Confirm Password',
                  controller: _confirmPasswordController,
                  obscure: _obscureConfirmPassword,
                  onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Checkbox(
                key: const Key('termsCheckbox'),
                value: _acceptedTerms,
                onChanged: (value) => setState(() => _acceptedTerms = value ?? false),
                activeColor: const Color(0xFF1B4332),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(color: Color(0xFF565D6D), fontSize: 14),
                    children: [
                      TextSpan(text: 'I agree to the '),
                      TextSpan(
                        text: 'Terms of Service',
                        style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1B4332)),
                      ),
                      TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1B4332)),
                      ),
                      TextSpan(text: '.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              key: const Key('createAccountButton'),
              onPressed: (_acceptedTerms && !_isLoading) ? _handleSignup : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                disabledBackgroundColor: const Color(0xFF9EB6A3),
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
                  : const Text('Create Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 6,
              children: [
                const Text(
                  'Already on BeztaMy?',
                  style: TextStyle(color: Color(0xFF565D6D)),
                ),
                GestureDetector(
                  key: const Key('goToLoginLink'),
                  onTap: () => context.go('/login'),
                  child: const Text(
                    'Sign in',
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

  Widget _buildField(
    String label,
    TextEditingController controller, {
    String? hint,
    TextInputType? keyboardType,
    String? keyName,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF7A7A7A),
            fontWeight: FontWeight.w600,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          key: keyName != null ? Key(keyName) : null,
          controller: controller,
          keyboardType: keyboardType,
          enabled: !_isLoading,
          decoration: _fieldDecoration(hint ?? ''),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
    String? keyName,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF7A7A7A),
            fontWeight: FontWeight.w600,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          key: keyName != null ? Key(keyName) : null,
          controller: controller,
          obscureText: obscure,
          decoration: _fieldDecoration('At least 8 characters').copyWith(
            suffixIcon: IconButton(
              icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF565D6D)),
              onPressed: onToggle,
            ),
          ),
        ),
      ],
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

  Widget _buildProfileImageSection() {
    final imageProvider = _profileImageBytes == null ? null : MemoryImage(_profileImageBytes!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PROFILE PICTURE',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF7A7A7A),
            fontWeight: FontWeight.w600,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: AppConstants.appBackgroundColor,
              backgroundImage: imageProvider,
              child: imageProvider == null
                  ? const Icon(Icons.person, size: 32, color: Color(0xFF1B4332))
                  : null,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OutlinedButton.icon(
                  onPressed: _pickProfileImage,
                  icon: const Icon(Icons.upload, size: 18),
                  label: const Text('Upload Image'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                if (_profileImageBytes != null)
                  TextButton(
                    onPressed: () => setState(() => _profileImageBytes = null),
                    child: const Text(
                      'Remove',
                      style: TextStyle(color: Color(0xFFB71C1C), fontWeight: FontWeight.w600),
                    ),
                  ),
                if (_profileImageBytes == null)
                  const Text(
                    'Recommended size: 400x400 px.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF7A7A7A)),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickProfileImage() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        if (!mounted) return;
        setState(() => _profileImageBytes = bytes);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to pick image: $e')),
      );
    }
  }
}

class _StoryPoint extends StatelessWidget {
  final String text;
  const _StoryPoint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
