import 'dart:async';
import 'package:denz_sen/core/theme/app_spacing.dart';
import 'package:denz_sen/feature/my_message/provider/add_member_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class AddMemberScreen extends StatefulWidget {
  const AddMemberScreen({super.key, required this.caseId});

  final int caseId;

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _addMember(BuildContext providerContext, int userId) async {
    final provider = providerContext.read<AddMemberProvider>();
    final success = await provider.addMember(
      caseId: widget.caseId,
      userId: userId,
    );

    if (mounted) {
      if (success) {
        Navigator.pop(context, true); // Return true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Member added successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Failed to add member'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddMemberProvider()..searchUsers(caseId: widget.caseId),
      child: Builder(
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            backgroundColor: Colors.white,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
                maxWidth: 500.w,
              ),
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Add member to the Case',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    AppSpacing.h16,
                    TextField(
                      controller: _searchController,
                      autofocus: false,
                      onChanged: (value) {
                        if (_debounce?.isActive ?? false) _debounce!.cancel();
                        _debounce = Timer(
                          const Duration(milliseconds: 500),
                          () {
                            context.read<AddMemberProvider>().searchUsers(
                              query: value,
                              caseId: widget.caseId,
                            );
                          },
                        );
                      },
                      decoration: InputDecoration(
                        hintText: 'Search by name',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 14.sp,
                        ),
                        suffixIcon: Icon(Icons.search, color: Colors.grey),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Flexible(
                      child: Consumer<AddMemberProvider>(
                        builder: (context, provider, child) {
                          if (provider.isLoading) {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.all(40.h),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (provider.errorMessage != null) {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.h),
                                child: Text(
                                  provider.errorMessage!,
                                  style: TextStyle(color: Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          }

                          if (provider.userList.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.h),
                                child: Text('No users found'),
                              ),
                            );
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            itemCount: provider.userList.length,
                            separatorBuilder: (context, index) =>
                                SizedBox(height: 16.h),
                            itemBuilder: (context, index) {
                              final user = provider.userList[index];
                              return Row(
                                children: [
                                  Container(
                                    width: 40.w,
                                    height: 40.w,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: user.avatarUrl != null
                                          ? DecorationImage(
                                              image: NetworkImage(
                                                user.avatarUrl!,
                                              ),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                      color: Colors.grey.shade200,
                                    ),
                                    child: user.avatarUrl == null
                                        ? Center(
                                            child: Text(
                                              user.fullName.isNotEmpty
                                                  ? user.fullName[0]
                                                        .toUpperCase()
                                                  : '?',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          )
                                        : null,
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Text(
                                      user.fullName,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      _addMember(context, user.id);
                                    },
                                    borderRadius: BorderRadius.circular(8.r),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 8.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Color(
                                          0xFF54759E,
                                        ), // Muted blue from design
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.add,
                                            color: Colors.white,
                                            size: 18.sp,
                                          ),
                                          SizedBox(width: 4.w),
                                          Text(
                                            'Add',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
