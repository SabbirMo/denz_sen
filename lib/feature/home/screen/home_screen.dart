import 'package:denz_sen/core/theme/app_colors.dart';
import 'package:denz_sen/core/theme/app_spacing.dart';
import 'package:denz_sen/core/theme/app_style.dart';
import 'package:denz_sen/feature/cop_portal/screen/cop_portal_screen.dart';
import 'package:denz_sen/feature/home/provider/dipatches_nearby_provider.dart';
import 'package:denz_sen/feature/home/provider/dispatch_radius_provider.dart';
import 'package:denz_sen/feature/home/provider/google_maps_provider.dart';
import 'package:denz_sen/feature/home/provider/profile_show_provider.dart';
import 'package:denz_sen/feature/home/widget/custom_home_tab_bar.dart';
import 'package:denz_sen/feature/home/widget/custom_slider.dart';
import 'package:denz_sen/feature/home/widget/dispatch_alert_bottom_sheet.dart';
import 'package:denz_sen/feature/leaderboard/screen/leaderboard_screen.dart';
import 'package:denz_sen/feature/my_cases/screen/my_cases_screen.dart';
import 'package:denz_sen/feature/my_message/screen/my_message_screen.dart';
import 'package:denz_sen/feature/setting_page/screen/setting_page.dart';
import 'package:denz_sen/feature/submit_report/screen/submit_report_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double currentValue = 0;

  Set<Marker> markers = {};
  GoogleMapController? mapController;
  Position? currentPosition;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onTapGetMyLocation();
      _loadProfile();
      _loadDispatchesNearby();
    });
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;
    final provider = Provider.of<ProfileShowProvider>(context, listen: false);
    await provider.showProfile();
  }

  Future<void> _loadDispatchesNearby() async {
    if (!mounted) return;
    final provider = Provider.of<DipatchesNearbyProvider>(
      context,
      listen: false,
    );
    await provider.fetchDispatchesNearby();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 60.h,
        automaticallyImplyLeading: false,
        title: Consumer<ProfileShowProvider>(
          builder: (context, ref, _) => CustomHomeAppBar(
            userName: ref.profile?.fullName ?? 'User',
            onLeaderboardTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
              );
            },
            onSettingsTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingPage()),
              );
            },
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          child: Column(
            children: [
              // Fixed Map at top
              Stack(
                children: [
                  SizedBox(
                    width: 340.w,
                    height: 200.h,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: AppColors.black.withValues(alpha: .4),
                          width: 1.w,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(1.w),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.r),
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(23.780682, 90.407428),
                              zoom: 16,
                            ),
                            zoomControlsEnabled: false,
                            zoomGesturesEnabled: false,
                            myLocationButtonEnabled: false,
                            mapToolbarEnabled: false,
                            liteModeEnabled: false,
                            markers: markers,
                            onMapCreated: (GoogleMapController controller) {
                              mapController = controller;
                            },
                            onTap: (LatLng position) {
                              setState(() {
                                markers = {
                                  Marker(
                                    markerId: MarkerId('selected-location'),
                                    position: position,
                                    infoWindow: InfoWindow(
                                      title: position.toString(),
                                    ),
                                  ),
                                };
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 12.h,
                    left: 12.w,
                    child: GestureDetector(
                      onTap: _onTapGetMyLocation,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Icon(
                          Icons.my_location,
                          size: 24.w,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              AppSpacing.h20,
              // Scrollable content below map
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GridView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12.h,
                          crossAxisSpacing: 12.w,
                          childAspectRatio: 2.8,
                        ),
                        children: [
                          CustomGridCard(
                            imagePath: 'assets/svgs/information.svg',
                            title: 'Submit Report',
                            onTap: () {
                              // Get selected marker position if available
                              LatLng? selectedLocation;
                              if (markers.isNotEmpty) {
                                selectedLocation = markers.first.position;
                              }

                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => SubmitReportScreen(
                                    preSelectedLocation: selectedLocation,
                                  ),
                                ),
                              );
                            },
                          ),
                          CustomGridCard(
                            imagePath: 'assets/svgs/folder.svg',
                            title: 'My Cases',
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const MyCasesScreen(),
                              ),
                            ),
                          ),
                          CustomGridCard(
                            imagePath: 'assets/svgs/radio.svg',
                            title: 'COP Portal',
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const CopPortalScreen(),
                              ),
                            ),
                          ),
                          CustomGridCard(
                            imagePath: 'assets/svgs/message.svg',
                            title: 'My Messages',
                            badgeCount: 2,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const MyMessageScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      AppSpacing.h20,
                      Text('New Dispatches', style: AppStyle.semiBook16),
                      AppSpacing.h8,
                      Consumer<DipatchesNearbyProvider>(
                        builder: (context, ref, _) {
                          if (ref.isLoading) {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.h),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (ref.dispatchesNearby.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.h),
                                child: Text(
                                  'No dispatches nearby',
                                  style: AppStyle.medium14,
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: ref.dispatchesNearby.length,
                            itemBuilder: (context, index) {
                              final dispatch = ref.dispatchesNearby[index];
                              final id = dispatch.id ?? 'N/A';
                              return Card(
                                margin: EdgeInsets.only(bottom: 12.h),
                                color: AppColors.offWhite,
                                child: ListTile(
                                  onTap: () {
                                    DispatchAlertBottomSheet.show(
                                      context,
                                      id: id,
                                    );
                                  },
                                  title: Text(
                                    dispatch.caseNumber ?? 'N/A',
                                    style: AppStyle.medium14.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.black,
                                    ),
                                  ),
                                  subtitle: Text(
                                    dispatch.address ?? 'No address',
                                    style: AppStyle.book14,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  trailing: Text(
                                    dispatch.timeAgo ?? '',
                                    style: AppStyle.book14,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              AppSpacing.h12,
              // Fixed slider at bottom
              Consumer<DispatchRadiusProvider>(
                builder: (context, dispatchProvider, _) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 18.h),
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              'Dispatch View Range',
                              style: AppStyle.semiBook14,
                            ),
                            Spacer(),
                            if (dispatchProvider.isLoading)
                              SizedBox(
                                width: 16.w,
                                height: 16.h,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.white,
                                  ),
                                ),
                              )
                            else
                              Text(
                                '${currentValue.toInt()}',
                                style: AppStyle.semiBook14,
                              ),
                          ],
                        ),
                        AppSpacing.h8,
                        SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 6.h,
                            activeTrackColor: AppColors.white.withValues(
                              alpha: 0.2,
                            ),
                            inactiveTrackColor: AppColors.white.withValues(
                              alpha: 0.2,
                            ),
                            thumbColor: AppColors.white,
                            thumbShape: SquareSliderThumbShape(
                              thumbSize: 16,
                              borderRadius: 4,
                              thumbWidth: 24,
                            ),
                            overlayShape: RoundSliderOverlayShape(
                              overlayRadius: 0,
                            ),
                          ),
                          child: Slider(
                            value: currentValue,
                            min: 0,
                            max: 500,
                            onChanged: dispatchProvider.isLoading
                                ? null
                                : (double newValue) {
                                    setState(() {
                                      currentValue = newValue;
                                    });
                                  },
                            onChangeEnd: dispatchProvider.isLoading
                                ? null
                                : (double newValue) async {
                                    final provider =
                                        Provider.of<DispatchRadiusProvider>(
                                          context,
                                          listen: false,
                                        );
                                    bool success = await provider
                                        .updateDispatchRadius(newValue);

                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).clearSnackBars();
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            success
                                                ? 'Dispatch radius updated successfully'
                                                : provider.errorMessage ??
                                                      'Failed to update dispatch radius',
                                          ),
                                          backgroundColor: success
                                              ? Colors.green
                                              : Colors.red,
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  },
                          ),
                        ),
                        AppSpacing.h10,
                        Row(
                          children: [
                            Text(
                              '${currentValue.toInt()} MI',
                              style: AppStyle.semiBook14,
                            ),
                            Spacer(),
                            Text('500 MI', style: AppStyle.semiBook14),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onTapGetMyLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      bool isLocationServiceEnabled =
          await Geolocator.isLocationServiceEnabled();
      if (isLocationServiceEnabled) {
        Position position = await Geolocator.getCurrentPosition();
        print('Current Position: $position');

        // Update location to server
        final provider = Provider.of<GoogleMapsProvider>(
          context,
          listen: false,
        );
        bool success = await provider.updateUserLocation(
          position.latitude,
          position.longitude,
        );

        if (success) {
          setState(() {
            currentPosition = position;
            markers = {
              Marker(
                markerId: MarkerId('my-location'),
                position: LatLng(position.latitude, position.longitude),
                infoWindow: InfoWindow(
                  title: 'My Location',
                  snippet:
                      'Lat: ${position.latitude}, Long: ${position.longitude}',
                ),
              ),
            };
          });

          if (mapController != null) {
            mapController!.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: LatLng(position.latitude, position.longitude),
                  zoom: 16,
                ),
              ),
            );
          }

          if (mounted) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Location updated successfully'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  provider.errorMessage ?? 'Failed to update location',
                ),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      } else {
        Geolocator.openLocationSettings();
      }
    } else {
      LocationPermission requestedPermission =
          await Geolocator.requestPermission();
      if (requestedPermission == LocationPermission.always ||
          requestedPermission == LocationPermission.whileInUse) {
        _onTapGetMyLocation();
        return;
      }
    }
  }
}

class CustomGridCard extends StatelessWidget {
  const CustomGridCard({
    super.key,
    this.imagePath,
    this.title,
    this.showBadge = false,
    this.badgeCount,
    this.onTap,
  });

  final String? imagePath;
  final String? title;
  final bool showBadge;
  final int? badgeCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.offWhite,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            showBadge
                ? Badge(
                    label: Text(
                      '${badgeCount ?? 0}',
                      style: const TextStyle(fontSize: 10),
                    ),
                    child: SvgPicture.asset(
                      imagePath ?? '',
                      width: 22.w,
                      height: 22.h,
                    ),
                  )
                : SvgPicture.asset(imagePath ?? '', width: 22.w, height: 22.h),

            AppSpacing.w6,

            Text(
              title ?? '',
              style: AppStyle.medium14.copyWith(
                color: AppColors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
