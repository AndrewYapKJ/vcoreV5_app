import 'package:go_router/go_router.dart';
import '../views/splash/splash_view.dart';
import '../views/login/login_view.dart';
import '../views/register/register_view.dart';
import '../views/incentive/incentive_report_view.dart';
import '../views/job/job_list_view.dart';
import '../views/request/request_view.dart';
import '../views/landing/main_shell_scaffold.dart';
import '../views/profile/profile_view.dart';
import '../views/settings/settings_view.dart';
import '../views/bug/bug_report_view.dart';
import '../views/leave/leave_application_view.dart';
import '../views/payment/advance_payment_view.dart';
import '../views/safety/safety_question_view.dart';
import '../views/notification/notification_view.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) {
    if (state.uri.toString() == '/') return '/login';
    return null;
  },
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashView()),
    GoRoute(path: '/login', builder: (context, state) => const LoginView()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterView(),
    ),
    // ShellRoute for main tabs
    ShellRoute(
      builder: (context, state, child) {
        // Pass the current index to the shell scaffold
        final location = state.uri.path;
        int currentIndex = 0;
        if (location.startsWith('/request')) {
          currentIndex = 0;
        } else if (location.startsWith('/jobs')) {
          currentIndex = 1;
        } else if (location.startsWith('/incentive-report')) {
          currentIndex = 2;
        }
        // Add more tabs as needed

        return MainShellScaffold(currentIndex: currentIndex, child: child);
      },
      routes: [
        GoRoute(
          path: '/request',
          builder: (context, state) => const RequestView(),
        ),
        GoRoute(
          path: '/jobs',
          builder: (context, state) => const JobListView(),
        ),
        GoRoute(
          path: '/incentive-report',
          builder: (context, state) => const IncentiveReportView(),
        ),
        // Add more tab routes here
      ],
    ),
    // Other routes (details, etc.) outside the shell
    GoRoute(path: '/profile', builder: (context, state) => const ProfileView()),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsView(),
    ),
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
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationView(),
    ),
  ],
);
