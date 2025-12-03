import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../views/splash/splash_view.dart';
import '../views/login/login_view.dart';
import '../views/dashboard/dashboard_view.dart';
import '../views/incentive/incentive_report_view.dart';
import '../views/job/job_list_view.dart';
import '../views/dashboard/main_shell_scaffold.dart';
import '../views/profile/profile_view.dart';
import '../views/bug/bug_report_view.dart';
import '../views/leave/leave_application_view.dart';
import '../views/payment/advance_payment_view.dart';
import '../views/safety/safety_question_view.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) {
    if (state.uri.toString() == '/') return '/dashboard';
    return null;
  },
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashView()),
    GoRoute(path: '/login', builder: (context, state) => const LoginView()),
    // ShellRoute for main tabs
    ShellRoute(
      builder: (context, state, child) {
        // Pass the current index to the shell scaffold
        final location = state.uri.path;
        int currentIndex = 0;
        if (location.startsWith('/incentive-report'))
          currentIndex = 1;
        else if (location.startsWith('/jobs'))
          currentIndex = 2;
        // Add more tabs as needed

        return MainShellScaffold(child: child, currentIndex: currentIndex);
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardView(),
        ),
        GoRoute(
          path: '/incentive-report',
          builder: (context, state) => const IncentiveReportView(),
        ),
        GoRoute(
          path: '/jobs',
          builder: (context, state) => const JobListView(),
        ),
        // Add more tab routes here
      ],
    ),
    // Other routes (details, etc.) outside the shell
    GoRoute(path: '/profile', builder: (context, state) => const ProfileView()),
    GoRoute(
      path: '/bug-report',
      builder: (context, state) => const BugReportView(),
    ),
    GoRoute(
      path: '/leave-application',
      builder: (context, state) => const LeaveApplicationView(),
    ),
    GoRoute(
      path: '/advance-payment',
      builder: (context, state) => const AdvancePaymentView(),
    ),
    GoRoute(
      path: '/safety-questions',
      builder: (context, state) => const SafetyQuestionView(),
    ),
  ],
);
