import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainShellScaffold extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const MainShellScaffold({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedIconTheme: IconThemeData(size: 30),
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/dashboard');
              break;
            case 1:
              context.go('/incentive-report');
              break;
            case 2:
              context.go('/jobs');
              break;
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Dashboard'),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: 'Incentive',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Jobs'),
        ],
      ),
    );
  }
}
