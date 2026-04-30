import 'dart:async';

import 'package:denz_sen/core/theme/app_colors.dart';
import 'package:denz_sen/core/theme/app_spacing.dart';
import 'package:denz_sen/feature/my_message/model/add_member_model.dart';
import 'package:denz_sen/feature/my_message/provider/add_member_provider.dart';
import 'package:denz_sen/feature/cop_portal/provider/create_conversation_provider.dart';
import 'package:denz_sen/feature/my_message/screen/message_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class CreateConversationScreen extends StatefulWidget {
  const CreateConversationScreen({super.key});

  @override
  State<CreateConversationScreen> createState() => _CreateConversationScreenState();
}

class _CreateConversationScreenState extends State<CreateConversationScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _groupNameController = TextEditingController();
  Timer? _debounce;
  final Set<AddMemberModel> _selectedUsers = {};

  @override
  void dispose() {
    _searchController.dispose();
    _groupNameController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _toggleUserSelection(AddMemberModel user) {
    setState(() {
      if (_selectedUsers.contains(user)) {
        _selectedUsers.remove(user);
      } else {
        _selectedUsers.add(user);
      }
    });
  }

  Future<void> _createConversation(BuildContext context) async {
    if (_selectedUsers.isEmpty) return;

    final provider = context.read<CreateConversationProvider>();
    final userIds = _selectedUsers.map((u) => u.id).toList();
    final isGroup = userIds.length > 1;
    final groupName = _groupNameController.text.trim();

    if (isGroup && groupName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a group name')),
      );
      return;
    }

    final success = await provider.createConversation(
      userIds: userIds,
      name: isGroup ? groupName : null,
      isGroup: isGroup,
    );

    if (mounted) {
      if (success && provider.createdConversationId != null) {
        // Pop the create screen and pass true to refresh list
        Navigator.pop(context, true);
        
        // Optionally, immediately navigate to the new chat
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MessageDetailsPage(
              conversationId: provider.createdConversationId,
              conversationTitle: isGroup ? groupName : _selectedUsers.first.fullName,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Failed to create conversation'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AddMemberProvider()..searchUsers()),
        ChangeNotifierProvider(create: (_) => CreateConversationProvider()),
      ],
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text('New Message', style: TextStyle(color: Colors.black)),
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.black),
              actions: [
                Consumer<CreateConversationProvider>(
                  builder: (context, createProvider, _) {
                    return TextButton(
                      onPressed: _selectedUsers.isEmpty || createProvider.isLoading
                          ? null
                          : () => _createConversation(context),
                      child: createProvider.isLoading
                          ? SizedBox(
                              width: 20.sp,
                              height: 20.sp,
                              child: const CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              'Create',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: _selectedUsers.isEmpty ? Colors.grey : AppColors.primaryColor,
                              ),
                            ),
                    );
                  },
                ),
              ],
            ),
            body: Column(
              children: [
                if (_selectedUsers.length > 1)
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: TextField(
                      controller: _groupNameController,
                      decoration: InputDecoration(
                        hintText: 'Group Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      ),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      if (_debounce?.isActive ?? false) _debounce!.cancel();
                      _debounce = Timer(
                        const Duration(milliseconds: 500),
                        () {
                          context.read<AddMemberProvider>().searchUsers(query: value);
                        },
                      );
                    },
                    decoration: InputDecoration(
                      hintText: 'Search users',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                  ),
                ),
                if (_selectedUsers.isNotEmpty)
                  Container(
                    height: 90.h,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      itemCount: _selectedUsers.length,
                      itemBuilder: (context, index) {
                        final user = _selectedUsers.elementAt(index);
                        return Padding(
                          padding: EdgeInsets.only(right: 12.w),
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 26.r,
                                    backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                                    child: user.avatarUrl == null ? Text(user.fullName[0].toUpperCase()) : null,
                                  ),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: GestureDetector(
                                      onTap: () => _toggleUserSelection(user),
                                      child: CircleAvatar(
                                        radius: 10.r,
                                        backgroundColor: Colors.red,
                                        child: Icon(Icons.close, size: 12.sp, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                user.fullName.split(' ').first,
                                style: TextStyle(fontSize: 12.sp),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                Divider(height: 1),
                Expanded(
                  child: Consumer<AddMemberProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (provider.userList.isEmpty) {
                        return const Center(child: Text('No users found'));
                      }

                      return ListView.separated(
                        itemCount: provider.userList.length,
                        separatorBuilder: (context, index) => Divider(height: 1),
                        itemBuilder: (context, index) {
                          final user = provider.userList[index];
                          final isSelected = _selectedUsers.contains(user);

                          return ListTile(
                            onTap: () => _toggleUserSelection(user),
                            leading: CircleAvatar(
                              backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                              child: user.avatarUrl == null ? Text(user.fullName[0].toUpperCase()) : null,
                            ),
                            title: Text(user.fullName),
                            subtitle: Text(user.role ?? 'User'),
                            trailing: isSelected
                                ? Icon(Icons.check_circle, color: AppColors.primaryColor)
                                : Icon(Icons.circle_outlined, color: Colors.grey),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
