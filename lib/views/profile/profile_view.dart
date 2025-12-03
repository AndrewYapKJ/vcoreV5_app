import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('user_profile'.tr(), style: const TextStyle(fontSize: 24)),
      ),
    );
  }
}
