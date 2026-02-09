import 'dart:async';
import 'dart:io';

import 'package:denz_sen/core/theme/app_colors.dart';
import 'package:denz_sen/feature/cop_portal/provider/cop_portal_comms_provider.dart';
import 'package:denz_sen/feature/cop_portal/provider/cop_portal_message_send.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class CopPartalCommsScreen extends StatefulWidget {
  const CopPartalCommsScreen({super.key});

  @override
  State<CopPartalCommsScreen> createState() => _CopPartalCommsScreenState();
}

class _CopPartalCommsScreenState extends State<CopPartalCommsScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<File> _selectedFiles = [];
  final ImagePicker _picker = ImagePicker();
  Timer? _refreshTimer;
  int _previousMessageCount = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<CopPortalCommsProvider>().init();
    });

    // Periodic refresh every 5 seconds for real-time updates
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        context.read<CopPortalCommsProvider>().fetchMessages();
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  String formatTime(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Consumer<CopPortalCommsProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading && provider.messages.isEmpty) {
                    return ListView.builder(
                      padding: EdgeInsets.all(16.w),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 5,
                      itemBuilder: (context, index) => const MessageShimmer(),
                    );
                  }

                  if (provider.messages.isEmpty) {
                    return const Center(child: Text("No messages yet"));
                  }

                  // Auto-scroll when new messages arrive
                  if (provider.messages.length != _previousMessageCount) {
                    _previousMessageCount = provider.messages.length;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_scrollController.hasClients) {
                        _scrollController.animateTo(
                          0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      }
                    });
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: EdgeInsets.all(16.w),
                    itemCount: provider.messages.length,
                    itemBuilder: (context, index) {
                      final message = provider.messages[index];
                      return MessageWidget(
                        name: message.senderName,
                        message: message.content,
                        time: formatTime(message.createdAt),
                        avatar: message.senderAvatar.isNotEmpty
                            ? message.senderAvatar
                            : 'https://ui-avatars.com/api/?name=${message.senderName}',
                        color: message.isMe
                            ? AppColors.primaryColor
                            : AppColors.black,
                        rank: 'assets/icons/rank1.png',
                        attachmentUrls: message.attachmentUrls,
                      );
                    },
                  );
                },
              ),
            ),
            _buildInputArea(context),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFiles() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedFiles.addAll(images.map((xfile) => File(xfile.path)));
        });
      }
    } catch (e) {
      debugPrint('Error picking files: $e');
    }
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Show selected files
          if (_selectedFiles.isNotEmpty) ...[
            Container(
              height: 80.h,
              margin: EdgeInsets.only(bottom: 8.h),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedFiles.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Container(
                        width: 80.w,
                        height: 80.h,
                        margin: EdgeInsets.only(right: 8.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: Image.file(
                            _selectedFiles[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4.h,
                        right: 12.w,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedFiles.removeAt(index);
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              size: 12.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.attach_file, color: Colors.grey.shade600),
                onPressed: _pickFiles,
              ),
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Enter your message',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 15.sp,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24.r),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.newline,
                ),
              ),
              SizedBox(width: 8.w),
              Consumer<CopPortalMessageSendProvider>(
                builder: (context, sendProvider, child) {
                  final isLoading = sendProvider.isLoading;

                  return GestureDetector(
                    onTap: isLoading
                        ? null
                        : () async {
                            final text = _messageController.text.trim();
                            if (text.isEmpty && _selectedFiles.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please enter a message or attach files',
                                  ),
                                ),
                              );
                              return;
                            }

                            final success = await sendProvider.sendMessage(
                              content: text,
                              attachments: _selectedFiles.isNotEmpty
                                  ? _selectedFiles
                                  : null,
                            );

                            if (success) {
                              _messageController.clear();
                              setState(() {
                                _selectedFiles.clear();
                              });

                              // Refresh messages after sending
                              if (mounted) {
                                await Future.delayed(
                                  const Duration(milliseconds: 500),
                                );
                                if (mounted) {
                                  context.read<CopPortalCommsProvider>().init();
                                }
                              }
                            } else {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      sendProvider.errorMessage ??
                                          'Failed to send message',
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: isLoading
                            ? Colors.grey.shade400
                            : const Color(0xFF5B7C99),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: isLoading
                          ? SizedBox(
                              width: 20.sp,
                              height: 20.sp,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(Icons.send, color: Colors.white, size: 20.sp),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MessageWidget extends StatelessWidget {
  final String name, message, time, avatar;
  final Color color;
  final String rank;
  final List<String> attachmentUrls;

  const MessageWidget({
    super.key,
    required this.name,
    required this.message,
    required this.time,
    required this.avatar,
    required this.color,
    required this.rank,
    this.attachmentUrls = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18.r,
            backgroundImage: NetworkImage(avatar),
            backgroundColor: Colors.grey.shade300,
            onBackgroundImageError: (_, __) {},
            child: avatar.isEmpty
                ? Icon(Icons.person, size: 18.sp, color: Colors.white)
                : null,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name.isNotEmpty ? name : 'Unknown',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4A574),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Icon(Icons.star, size: 12.sp, color: Colors.white),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                if (message.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ],
                if (attachmentUrls.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  _buildAttachments(context),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachments(BuildContext context) {
    if (attachmentUrls.isEmpty) return const SizedBox.shrink();

    int displayCount = attachmentUrls.length > 3 ? 3 : attachmentUrls.length;

    return SizedBox(
      height: 100.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: displayCount,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImageGalleryViewer(
                      images: attachmentUrls,
                      initialIndex: index,
                    ),
                  ),
                );
              },
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.network(
                      attachmentUrls[index],
                      width: 100.w,
                      height: 100.h,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 100.w,
                          height: 100.h,
                          color: Colors.grey.shade300,
                          child: Icon(Icons.image, color: Colors.grey.shade500),
                        );
                      },
                    ),
                  ),
                  if (index == displayCount - 1)
                    Positioned(
                      top: 6.h,
                      right: 6.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          attachmentUrls.length > 3
                              ? '+${attachmentUrls.length}'
                              : '${attachmentUrls.length}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Shimmer loading widget
class MessageShimmer extends StatelessWidget {
  const MessageShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36.w,
            height: 36.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 150.w,
                  height: 15.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  width: double.infinity,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Full screen image gallery viewer
class ImageGalleryViewer extends StatelessWidget {
  final List<String> images;
  final int initialIndex;

  const ImageGalleryViewer({
    super.key,
    required this.images,
    this.initialIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${initialIndex + 1} / ${images.length}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: PageView.builder(
        controller: PageController(initialPage: initialIndex),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Center(
            child: InteractiveViewer(
              child: Image.network(
                images[index],
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.white,
                      size: 100,
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
