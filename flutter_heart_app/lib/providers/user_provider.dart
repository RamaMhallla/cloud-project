// 📄 lib/providers/user_provider.dart

import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

class UserProvider extends ChangeNotifier {
  String _userName = '';
  String _userEmail = '';

  String get userName => _userName;
  String get userEmail => _userEmail;

  Future<String> loadUserAttributes() async {
    try {
      final attributes = await Amplify.Auth.fetchUserAttributes();
      _userEmail =
          attributes
              .firstWhere(
                (attr) => attr.userAttributeKey == AuthUserAttributeKey.email,
                orElse: () => const AuthUserAttribute(
                  userAttributeKey: AuthUserAttributeKey.email,
                  value: '',
                ),
              )
              .value ??
          '';

      _userName =
          attributes
              .firstWhere(
                (attr) => attr.userAttributeKey == AuthUserAttributeKey.name,
                orElse: () => const AuthUserAttribute(
                  userAttributeKey: AuthUserAttributeKey.name,
                  value: '',
                ),
              )
              .value ??
          '';

      notifyListeners();
      if (_userName!='' && _userEmail!=''){
          return "success";
      }
    } catch (e) {
      safePrint('❌ Failed to load user attributes: $e');
    }
    return "failure";

  }

Future<void> signOut() async {
    try {
      await Amplify.Auth.signOut();
      _userName = ''; // Clear user data
      _userEmail = ''; // Clear user data
      safePrint('User signed out successfully.');
    } on AuthException catch (e) {
      safePrint('❌ Sign out failed: $e');
    } finally {
      notifyListeners(); // Notify listeners after sign out
    }
  }
}
