import 'package:denz_sen/core/theme/app_colors.dart';
import 'package:denz_sen/core/theme/app_style.dart';
import 'package:denz_sen/feature/my_cases/screen/active_case_screen.dart';
import 'package:denz_sen/feature/my_cases/screen/close_case_screen.dart';
import 'package:denz_sen/feature/my_cases/screen/pending_case_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyCasesScreen extends StatefulWidget {
  const MyCasesScreen({super.key});

  @override
  State<MyCasesScreen> createState() => _MyCasesScreenState();
}

class _MyCasesScreenState extends State<MyCasesScreen> {
  String userRole = '';

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('role') ?? 'user';
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isAnalyst = userRole.toLowerCase() == 'analyst';
    final int tabLength = isAnalyst ? 3 : 2;

    return DefaultTabController(
      length: tabLength,
      child: Scaffold(
        appBar: AppBar(
          title: Text('My Cases', style: AppStyle.semiBook20),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_outlined),
            onPressed: () => Navigator.of(context).pop(),
          ),
          bottom: TabBar(
            dividerHeight: 0,
            indicatorColor: AppColors.primaryColor,
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: AppColors.primaryColor,
            unselectedLabelColor: AppColors.lightGrey,
            labelStyle: AppStyle.medium14,
            splashFactory: NoSplash.splashFactory,
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            indicatorPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 6.h,
            ),
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Closed'),
              if (isAnalyst) Tab(text: 'Pending'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ActiveCaseScreen(),
            CloseCaseScreen(),
            if (isAnalyst) PendingCaseScreen(),
          ],
        ),
      ),
    );
  }
}
