// 📄 lib/providers/user_provider.dart

import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

class UserProvider extends ChangeNotifier {
  String _userName = '';
  String _userEmail = '';
  bool _rememberMe = false;

  String get userName => _userName;
  String get userEmail => _userEmail;
  bool get rememberMe=>_rememberMe;

  Future<String> login(bool rememberMeP) async {
      Future<String> ret=loadUserAttributes();
      if (ret=="success"){
        _rememberMe=rememberMeP;
      }
      return ret;
  }

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
      _rememberMe=false;
      safePrint('User signed out successfully.');
    } on AuthException catch (e) {
      safePrint('❌ Sign out failed: $e');
    } finally {
      notifyListeners(); // Notify listeners after sign out
    }
  }
}
