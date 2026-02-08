import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:denz_sen/core/theme/app_colors.dart';
import 'package:denz_sen/core/theme/app_style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LocationPickerWidget extends StatefulWidget {
  final Function(double lat, double lng, String address) onLocationSelected;

  const LocationPickerWidget({super.key, required this.onLocationSelected});

  @override
  State<LocationPickerWidget> createState() => _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends State<LocationPickerWidget> {
  GoogleMapController? _mapController;
  LatLng _selectedPosition = const LatLng(23.8103, 90.4125); // Dhaka default
  String _selectedAddress = 'Select location on map';
  bool _isLoading = false;
  Set<Marker> _markers = {};

  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  List<Location> _searchResults = [];
  bool _isSearching = false;
  bool _showSearchResults = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _selectedPosition = LatLng(position.latitude, position.longitude);
      });
      _updateMarker(_selectedPosition);
      _getAddressFromLatLng(_selectedPosition);
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_selectedPosition, 15),
      );
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _selectedAddress =
              '${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.country}';
        });
      }
    } catch (e) {
      debugPrint('Error getting address: $e');
      setState(() {
        _selectedAddress =
            'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Search for locations
  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _showSearchResults = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _showSearchResults = true;
    });

    try {
      List<Location> locations = await locationFromAddress(query);
      setState(() {
        _searchResults = locations;
      });
    } catch (e) {
      debugPrint('Error searching location: $e');
      setState(() {
        _searchResults = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No results found for "$query"'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  // Select location from search results
  Future<void> _selectSearchResult(Location location) async {
    final position = LatLng(location.latitude, location.longitude);

    setState(() {
      _selectedPosition = position;
      _showSearchResults = false;
      _searchController.clear();
    });

    _updateMarker(position);
    await _getAddressFromLatLng(position);

    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(position, 15));
  }

  void _updateMarker(LatLng position) {
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('selected_location'),
          position: position,
          draggable: true,
          onDragEnd: (newPosition) {
            setState(() {
              _selectedPosition = newPosition;
            });
            _getAddressFromLatLng(newPosition);
          },
        ),
      };
    });
  }

  void _onMapTapped(LatLng position) {
    setState(() {
      _selectedPosition = position;
    });
    _updateMarker(position);
    _getAddressFromLatLng(position);
  }

  void _confirmLocation() {
    widget.onLocationSelected(
      _selectedPosition.latitude,
      _selectedPosition.longitude,
      _selectedAddress,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Location', style: AppStyle.semiBook20),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _getCurrentLocation,
            tooltip: 'My Location',
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedPosition,
              zoom: 15,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onTap: _onMapTapped,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          // Search bar
          Positioned(
            top: 16.h,
            left: 16.w,
            right: 16.w,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search location...',
                      hintStyle: AppStyle.book14.copyWith(
                        color: AppColors.grey,
                      ),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _showSearchResults = false;
                                  _searchResults = [];
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 14.h,
                      ),
                    ),
                    onChanged: (value) {
                      if (value.length > 2) {
                        _searchLocation(value);
                      } else {
                        setState(() {
                          _showSearchResults = false;
                        });
                      }
                    },
                    onSubmitted: _searchLocation,
                  ),
                ),

                // Search results
                if (_showSearchResults)
                  Container(
                    margin: EdgeInsets.only(top: 8.h),
                    constraints: BoxConstraints(maxHeight: 250.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _isSearching
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : _searchResults.isEmpty
                        ? Padding(
                            padding: EdgeInsets.all(16.w),
                            child: Text(
                              'No results found',
                              style: AppStyle.book14.copyWith(
                                color: AppColors.grey,
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final location = _searchResults[index];
                              return ListTile(
                                leading: Icon(
                                  Icons.location_on,
                                  color: AppColors.primaryColor,
                                ),
                                title: FutureBuilder<List<Placemark>>(
                                  future: placemarkFromCoordinates(
                                    location.latitude,
                                    location.longitude,
                                    // _searchController.dispose();
                                  ),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData &&
                                        snapshot.data!.isNotEmpty) {
                                      final place = snapshot.data!.first;
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            place.name ??
                                                place.street ??
                                                'Unknown',
                                            style: AppStyle.semiBook14,
                                          ),
                                          Text(
                                            '${place.locality}, ${place.administrativeArea}, ${place.country}',
                                            style: AppStyle.book14.copyWith(
                                              color: AppColors.grey,
                                            ),
                                          ),
                                        ],
                                      );
                                    }
                                    return Text(
                                      'Lat: ${location.latitude.toStringAsFixed(4)}, Lng: ${location.longitude.toStringAsFixed(4)}',
                                      style: AppStyle.semiBook14,
                                    );
                                  },
                                ),
                                onTap: () => _selectSearchResult(location),
                              );
                            },
                          ),
                  ),
              ],
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.r),
                  topRight: Radius.circular(20.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: AppColors.primaryColor,
                        size: 24,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selected Location',
                              style: AppStyle.book14.copyWith(
                                color: AppColors.grey,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            _isLoading
                                ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    _selectedAddress,
                                    style: AppStyle.semiBook14,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Lat: ${_selectedPosition.latitude.toStringAsFixed(6)}, Lng: ${_selectedPosition.longitude.toStringAsFixed(6)}',
                    style: AppStyle.book14.copyWith(color: AppColors.grey),
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: _confirmLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        'Confirm Location',
                        style: AppStyle.semiBook16.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Center(
                    child: Text(
                      'Tap on map or drag marker to select location',
                      style: AppStyle.book14.copyWith(color: AppColors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
