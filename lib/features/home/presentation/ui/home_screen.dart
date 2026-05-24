import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learn_craft/core/theme/app_colors.dart';
import 'package:learn_craft/features/course/data/datasources/course_seed_service.dart';
import 'package:learn_craft/features/course/presentation/cubit/course_cubit.dart';
import 'package:learn_craft/features/course/presentation/ui/explore_screen.dart';
import 'package:learn_craft/features/home/presentation/ui/dashboard_screen.dart';
import 'package:learn_craft/features/home/presentation/ui/duo_bottom_nav.dart';
import 'package:learn_craft/features/profile/presentation/cubit/user_cubit.dart';
import 'package:learn_craft/features/upload/presentation/ui/upload_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<UserCubit>().loadUser();
    context.read<CourseCubit>().loadCourses();
  }

  Future<void> _seedCourseData() async {
    final messenger = ScaffoldMessenger.of(context);
    final cubit = context.read<CourseCubit>();
    try {
      await CourseSeedService().seedSampleCourse();
      cubit.loadCourses();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Sample course + 5 lessons seeded!'),
          backgroundColor: AppColors.green,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Seed failed: $e'),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  // Tab 0: Home  1: Explore  (Add taps push UploadScreen)
  static const _screens = [
    DashboardScreen(),
    ExploreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      // SEED DATA FAB — only on Home tab
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: _seedCourseData,
              backgroundColor: AppColors.green,
              elevation: 0,
              extendedPadding:
                  const EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(
                    color: AppColors.greenShadow, width: 2),
              ),
              icon: const Icon(Icons.cloud_upload_rounded,
                  color: Colors.white, size: 20),
              label: const Text(
                'SEED DATA',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  fontSize: 13,
                ),
              ),
            )
          : null,
      bottomNavigationBar: DuoBottomNav(
        // Map screen index back to nav index (0→0, 1→2, skip Add=1)
        currentIndex: _selectedIndex == 0 ? 0 : 2,
        onTap: (i) {
          if (i == 1) {
            // Add tab → push UploadScreen as modal, don't change tab index
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const UploadScreen()),
            );
          } else {
            // Map nav index to screen index (skip the Add slot)
            setState(() => _selectedIndex = i == 0 ? 0 : 1);
          }
        },
      ),
    );
  }
}
