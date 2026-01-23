import 'package:denz_sen/core/theme/app_colors.dart';
import 'package:denz_sen/core/theme/app_style.dart';
import 'package:denz_sen/feature/cop_portal/screen/cop_partal_comms_screen.dart';
import 'package:denz_sen/feature/cop_portal/screen/cop_portal_education.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CopPortalScreen extends StatelessWidget {
  const CopPortalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('COP Portal', style: AppStyle.semiBook20),
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
              Tab(text: 'Comms'),
              Tab(text: 'Education'),
            ],
          ),
        ),
        body: TabBarView(
          children: [CopPartalCommsScreen(), CopPortalEducation()],
        ),
      ),
    );
  }
}
