import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tatakai_mobile/config/theme.dart';
import 'package:tatakai_mobile/services/supabase_service.dart';
import 'package:tatakai_mobile/providers/auth_provider.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});
  
  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String? _message;
  bool _isSuccess = false;
  
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }
  
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
  
  Future<void> _sendResetEmail() async {
    if (_emailController.text.isEmpty) {
      setState(() {
        _message = 'Please enter your email';
        _isSuccess = false;
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _message = null;
    });
    
    try {
      final supabase = ref.read(supabaseServiceProvider);
      await supabase.client.auth.resetPasswordForEmail(_emailController.text.trim());
      
      setState(() {
        _isLoading = false;
        _isSuccess = true;
        _message = 'Password reset email sent! Check your inbox.';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isSuccess = false;
        _message = 'Error: ${e.toString()}';
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemes.darkBackground,
      appBar: AppBar(
        backgroundColor: AppThemes.darkBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Reset Password',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppThemes.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Forgot your password?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppThemes.spaceSm),
            Text(
              'Enter your email address and we\'ll send you a link to reset your password.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: AppThemes.spaceXl),
            
            // Email field
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                prefixIcon: Icon(Icons.email_outlined, color: Colors.white.withOpacity(0.5)),
                filled: true,
                fillColor: AppThemes.darkSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
                  borderSide: const BorderSide(color: AppThemes.accentPink),
                ),
              ),
            ),
            
            const SizedBox(height: AppThemes.spaceMd),
            
            // Message
            if (_message != null)
              Container(
                padding: const EdgeInsets.all(AppThemes.spaceMd),
                decoration: BoxDecoration(
                  color: _isSuccess 
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isSuccess ? Icons.check_circle : Icons.error,
                      color: _isSuccess ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: AppThemes.spaceMd),
                    Expanded(
                      child: Text(
                        _message!,
                        style: TextStyle(
                          color: _isSuccess ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: AppThemes.spaceLg),
            
            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _sendResetEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppThemes.accentPink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppThemes.spaceMd),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Send Reset Link',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
            
            const SizedBox(height: AppThemes.spaceLg),
            
            // Back to login
            Center(
              child: TextButton(
                onPressed: () => context.go('/auth'),
                child: Text(
                  'Back to Login',
                  style: TextStyle(color: AppThemes.accentPink),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
