import 'package:flutter/material.dart';
import 'package:flutter_heart_app_new/providers/user_provider.dart';
import 'package:flutter_heart_app_new/screen/home_screen.dart';
import 'package:flutter_heart_app_new/screen/login_screen.dart';
import 'package:provider/provider.dart';
enum AuthStatus{notLoggedIn, loggedIn}

class Root extends StatefulWidget {
  const Root({super.key});

  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> {
  AuthStatus _authStatus= AuthStatus.notLoggedIn;
  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    UserProvider _user=Provider.of<UserProvider>(
            context,
            listen: false,
          );
    String _returnString =await _user.loadUserAttributes();
    if (_returnString=='success'){
        setState(() {
           _authStatus= AuthStatus.loggedIn;
        });
    }

    
  }
  @override
  Widget build(BuildContext context) {
    Widget retVal;
    switch(_authStatus){
      case AuthStatus.notLoggedIn:
      retVal=LoginScreen();
      break;
      case AuthStatus.loggedIn:
      retVal=HomeScreen();
      break;
    }
    return Scaffold(
    );
  }
}