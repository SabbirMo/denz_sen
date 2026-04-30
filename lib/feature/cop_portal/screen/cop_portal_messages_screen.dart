import 'package:denz_sen/core/theme/app_colors.dart';
import 'package:denz_sen/core/theme/app_spacing.dart';
import 'package:denz_sen/core/theme/app_style.dart';
import 'package:denz_sen/feature/my_message/provider/my_message_provider.dart';
import 'package:denz_sen/feature/my_message/screen/message_details_page.dart';
import 'package:denz_sen/feature/my_message/screen/my_message_screen.dart'; // for MyMessageCaseWidget
import 'package:denz_sen/feature/cop_portal/screen/create_conversation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class CopPortalMessagesScreen extends StatefulWidget {
  const CopPortalMessagesScreen({super.key});

  @override
  State<CopPortalMessagesScreen> createState() => _CopPortalMessagesScreenState();
}

class _CopPortalMessagesScreenState extends State<CopPortalMessagesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
    Future.microtask(() {
      if (mounted) {
        Provider.of<MyMessageProvider>(context, listen: false).fatchMessage();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<dynamic> _filterMessages(List<dynamic> messages) {
    if (_searchQuery.isEmpty) return messages;

    final cleanQuery = _searchQuery.replaceAll(RegExp(r'[-\s]'), '');

    return messages.where((message) {
      final caseNumber = (message.caseNumber ?? '').toLowerCase().replaceAll(
        RegExp(r'[-\s]'),
        '',
      );
      final lastMessage = (message.lastMessage ?? '').toLowerCase();
      final lastSender = (message.lastSender ?? '').toLowerCase();

      return caseNumber.contains(cleanQuery) ||
          lastMessage.contains(_searchQuery) ||
          lastSender.contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async {
          await Provider.of<MyMessageProvider>(
            context,
            listen: false,
          ).fatchMessage();
        },
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xfff9f9f7),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TextField(
                      controller: _searchController,
                      autofocus: false,
                      decoration: InputDecoration(
                        hintText: 'Search messages',
                        border: InputBorder.none,
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                },
                              )
                            : null,
                        contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                    ),
                  ),
                  AppSpacing.h18,
                  Consumer<MyMessageProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading && provider.messages.isEmpty) {
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 5,
                          itemBuilder: (context, index) => const MessageShimmer(),
                        );
                      }

                      final filteredMessages = _filterMessages(provider.messages);

                      if (filteredMessages.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 50.h),
                            child: Text(
                              _searchQuery.isEmpty
                                  ? 'No messages found'
                                  : 'No messages match your search',
                              style: AppStyle.medium14.copyWith(
                                color: AppColors.lightGrey,
                              ),
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredMessages.length,
                        itemBuilder: (context, index) {
                          final message = filteredMessages[index];
                          return MyMessageCaseWidget(
                            message: message,
                            onTap: () async {
                              if (message.id != null) {
                                // It's a Case message
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MessageDetailsPage(
                                      caseId: message.id,
                                      caseStatus: message.caseStatus,
                                    ),
                                  ),
                                );
                              } else if (message.conversationId != null) {
                                // It's a Direct/Group conversation
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MessageDetailsPage(
                                      conversationId: message.conversationId,
                                      conversationTitle: message.caseNumber ?? 'Chat',
                                    ),
                                  ),
                                );
                              }
                              
                              if (mounted) {
                                Provider.of<MyMessageProvider>(context, listen: false).fatchMessage();
                              }
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateConversationScreen()),
          );
          if (result == true && mounted) {
            Provider.of<MyMessageProvider>(context, listen: false).fatchMessage();
          }
        },
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
