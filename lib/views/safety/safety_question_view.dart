import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class SafetyQuestionView extends StatelessWidget {
  const SafetyQuestionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('safety_questions'.tr(), style: const TextStyle(fontSize: 24)),
      ),
    );
  }
}
