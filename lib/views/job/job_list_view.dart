import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class JobListView extends StatelessWidget {
  const JobListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('job_list'.tr(), style: const TextStyle(fontSize: 24)),
      ),
    );
  }
}
