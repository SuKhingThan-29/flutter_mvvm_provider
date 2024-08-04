import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'login_view.dart';
import 'data_view.dart';

class SplashView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.microtask(() async {
      await Provider.of<AuthViewModel>(context, listen: false).loadUser();
      final user = Provider.of<AuthViewModel>(context, listen: false).user;
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => DataViewScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginView()),
        );
      }
    });

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
