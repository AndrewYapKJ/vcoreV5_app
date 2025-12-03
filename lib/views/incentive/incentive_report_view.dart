import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class IncentiveReportView extends StatelessWidget {
  const IncentiveReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('incentive_report'.tr(), style: const TextStyle(fontSize: 24)),
      ),
    );
  }
}
