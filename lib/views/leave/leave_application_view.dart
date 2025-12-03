import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LeaveApplicationView extends StatelessWidget {
  const LeaveApplicationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('leave_application'.tr(), style: const TextStyle(fontSize: 24)),
      ),
    );
  }
}
