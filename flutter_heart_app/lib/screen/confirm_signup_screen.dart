import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter_heart_app_new/screen/home_screen.dart';

class ConfirmSignUpScreen extends StatefulWidget {
  final String email;
  final String password;

  const ConfirmSignUpScreen({
    super.key,
    required this.email,
    required this.password,
  });
  @override
  State<ConfirmSignUpScreen> createState() => _ConfirmSignUpScreenState();
}

class _ConfirmSignUpScreenState extends State<ConfirmSignUpScreen> {
  final _codeController = TextEditingController();
  bool _isLoading = false;

  Future<void> _confirmSignUp() async {
    setState(() => _isLoading = true);
    try {
      final res = await Amplify.Auth.confirmSignUp(
        username: widget.email,
        confirmationCode: _codeController.text.trim(),
      );

      if (res.isSignUpComplete) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Account confirmed! Please login.")),
        );
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        // Shouldn’t happen usually
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("⚠️ Confirmation not complete")),
        );
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Error: ${e.message}")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resendCode() async {
    try {
      await Amplify.Auth.resendSignUpCode(username: widget.email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("📨 Confirmation code resent")),
      );
    } on AuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Error: ${e.message}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Confirm Sign Up"),
        backgroundColor: const Color(0xFF5B8FB9),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              "Enter the confirmation code sent to your email:",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: "Confirmation Code",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _confirmSignUp,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Confirm"),
            ),
            TextButton(
              onPressed: _resendCode,
              child: const Text("Resend Code"),
            ),
          ],
        ),
      ),
    );
  }
}
