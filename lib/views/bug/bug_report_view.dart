import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class BugReportView extends StatelessWidget {
  const BugReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('bug_report'.tr(), style: const TextStyle(fontSize: 24)),
      ),
    );
  }
}
