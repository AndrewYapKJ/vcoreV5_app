import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../views/splash/splash_view.dart';
import '../views/login/login_view.dart';
import '../views/dashboard/dashboard_view.dart';
import '../views/landing/landing_view.dart';
import '../views/job/job_list_view.dart';
import '../views/job/job_detail_view.dart';
import '../views/profile/profile_view.dart';
import '../views/bug/bug_report_view.dart';
import '../views/incentive/incentive_report_view.dart';
import '../views/leave/leave_application_view.dart';
import '../views/payment/advance_payment_view.dart';
import '../views/safety/safety_question_view.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashView(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginView(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const LandingView(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardView(),
    ),
    GoRoute(
      path: '/jobs',
      builder: (context, state) => const JobListView(),
    ),
    GoRoute(
      path: '/job/:id',
      builder: (context, state) => JobDetailView(jobId: state.pathParameters['id'] ?? ''),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileView(),
    ),
    GoRoute(
      path: '/bug-report',
      builder: (context, state) => const BugReportView(),
    ),
    GoRoute(
      path: '/incentive-report',
      builder: (context, state) => const IncentiveReportView(),
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
