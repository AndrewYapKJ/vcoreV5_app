import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class JobDetailView extends StatelessWidget {
  final String jobId;
  const JobDetailView({super.key, required this.jobId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('job_details'.tr() + ' #$jobId', style: const TextStyle(fontSize: 24)),
      ),
    );
  }
}
