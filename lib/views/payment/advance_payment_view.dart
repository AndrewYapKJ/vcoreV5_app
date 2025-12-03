import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class AdvancePaymentView extends StatelessWidget {
  const AdvancePaymentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('advance_payment_request'.tr(), style: const TextStyle(fontSize: 24)),
      ),
    );
  }
}
