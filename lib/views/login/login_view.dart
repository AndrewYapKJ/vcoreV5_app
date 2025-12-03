import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('login'.tr(), style: const TextStyle(fontSize: 24)),
      ),
    );
  }
}
