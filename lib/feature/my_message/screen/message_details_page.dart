import 'dart:io';

import 'package:denz_sen/feature/my_message/provider/close_cases_provider.dart';
import 'package:denz_sen/feature/my_message/provider/message_details_provider.dart';
import 'package:denz_sen/feature/my_message/provider/message_send_provider.dart';
import 'package:denz_sen/feature/my_message/provider/message_socket_provider.dart';
import 'package:denz_sen/feature/my_message/screen/my_message_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class MessageDetailsPage extends StatefulWidget {
  const MessageDetailsPage({super.key, required this.caseId});

  final int caseId;

  @override
  State<MessageDetailsPage> createState() => _MessageDetailsPageState();
}

class _MessageDetailsPageState extends State<MessageDetailsPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<File> _selectedFiles = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final socketProvider = Provider.of<MessageSocketProvider>(
          context,
          listen: false,
        );

        // Set callback to refresh when new message arrives via WebSocket
        socketProvider.onNewMessage = () {
          if (mounted) {
            Provider.of<MessageDetailsProvider>(
              context,
              listen: false,
            ).fetchMessageDetails(widget.caseId);
          }
        };

        // Connect to WebSocket for real-time messaging
        socketProvider.connect(widget.caseId);

        // Fallback: Load message history via REST API
        Provider.of<MessageDetailsProvider>(
          context,
          listen: false,
        ).fetchMessageDetails(widget.caseId);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _addMember() {
    // TODO: Implement add member functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add Member feature coming soon')),
    );
  }

  void _closeCase() {
    // Show confirmation dialog before closing case
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Close Case'),
          content: Text(
            'Are you sure you want to close this case?',
            style: TextStyle(fontSize: 15.sp),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            Consumer<CloseCasesProvider>(
              builder: (context, ref, _) => TextButton(
                onPressed: () async {
                  // Save references before any async operations
                  final navigator = Navigator.of(context);
                  final scaffoldMessenger = ScaffoldMessenger.of(context);

                  // Close the dialog first
                  navigator.pop();

                  // Close the case
                  await ref.caseClose(widget.caseId);

                  // Show success message using saved reference
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text('Case closed successfully')),
                  );

                  // Navigate back to message list screen
                  navigator.pop(true);
                },
                child: const Text(
                  'Close Case',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Case #${widget.caseId.toString().padLeft(5, '0')}',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            Consumer<MessageSocketProvider>(
              builder: (context, socketProvider, child) {
                return Row(
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.h,
                      decoration: BoxDecoration(
                        color: socketProvider.isConnected
                            ? Colors.green
                            : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      socketProvider.isConnected ? 'Real-time' : 'Offline',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: socketProvider.isConnected
                            ? Colors.green
                            : Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            offset: Offset(0, 50.h),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'add_member',
                child: Row(
                  children: [
                    Icon(Icons.person_add, color: Colors.blue, size: 20.sp),
                    SizedBox(width: 12.w),
                    Text(
                      'Add Member',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'close_case',
                child: Row(
                  children: [
                    Icon(Icons.close, color: Colors.red, size: 20.sp),
                    SizedBox(width: 12.w),
                    Text(
                      'Close Case',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            onSelected: (String value) {
              if (value == 'add_member') {
                _addMember();
              } else if (value == 'close_case') {
                _closeCase();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<MessageDetailsProvider>(
              builder: (context, restProvider, child) {
                // Always show REST API messages for consistency
                if (restProvider.isLoading) {
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 5,
                    itemBuilder: (context, index) => const MessageShimmer(),
                  );
                }

                final messages = restProvider.messages;

                if (messages.isEmpty) {
                  return const Center(child: Text('No messages found'));
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return MessageWidget(message: message);
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
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

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty && _selectedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a message or attach files')),
      );
      return;
    }

    // final socketProvider = Provider.of<MessageSocketProvider>(
    //   context,
    //   listen: false,
    // );
    final sendProvider = Provider.of<MessageSendProvider>(
      context,
      listen: false,
    );
    final detailsProvider = Provider.of<MessageDetailsProvider>(
      context,
      listen: false,
    );

    final messageText = _messageController.text.trim();
    final hasFiles = _selectedFiles.isNotEmpty;

    // Always send via REST API POST request
    final success = await sendProvider.sendMessage(
      caseId: widget.caseId,
      content: messageText,
      attachments: hasFiles ? _selectedFiles : null,
    );

    if (success) {
      _messageController.clear();
      setState(() {
        _selectedFiles.clear();
      });

      // Wait a bit for backend to process images, then refresh
      await Future.delayed(const Duration(milliseconds: 500));
      await detailsProvider.fetchMessageDetails(widget.caseId);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              sendProvider.errorMessage ?? 'Failed to send message',
            ),
          ),
        );
      }
    }
  }

  Widget _buildMessageInput() {
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
              Consumer2<MessageSendProvider, MessageSocketProvider>(
                builder: (context, sendProvider, socketProvider, child) {
                  final isLoading = sendProvider.isLoading;
                  final isConnected = socketProvider.isConnected;

                  return GestureDetector(
                    onTap: isLoading ? null : _sendMessage,
                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: isLoading
                            ? Colors.grey.shade400
                            : (isConnected
                                  ? const Color(
                                      0xFF2ECC71,
                                    ) // Green when connected
                                  : const Color(
                                      0xFF5B7C99,
                                    )), // Blue when offline
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: isLoading
                          ? SizedBox(
                              width: 20.sp,
                              height: 20.sp,
                              child: CircularProgressIndicator(
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
  const MessageWidget({super.key, required this.message});

  final dynamic message;

  String _formatTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } catch (e) {
      // If parsing fails, return the original string or a default
      return dateTimeString;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get attachment URLs directly from the model
    List<String> imageUrls = message.attachmentUrls ?? [];

    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 18.r,
            backgroundImage: message.senderAvatar.isNotEmpty
                ? NetworkImage(message.senderAvatar)
                : null,
            backgroundColor: Colors.grey.shade300,
            child: message.senderAvatar.isEmpty
                ? Icon(Icons.person, size: 18.sp, color: Colors.white)
                : null,
          ),
          SizedBox(width: 12.w),
          // Message content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sender name and timestamp
                Row(
                  children: [
                    Text(
                      message.senderName.isNotEmpty
                          ? message.senderName
                          : 'Unknown',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
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
                      _formatTime(message.createdAt),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                // Message text
                Text(
                  message.content,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
                // Image attachments
                if (imageUrls.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  SizedBox(
                    height: 100.h,
                    child: _buildImageGrid(imageUrls, context),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid(List<String> imageUrls, BuildContext context) {
    if (imageUrls.isEmpty) return const SizedBox.shrink();

    // Show max 3 images in grid
    int displayCount = imageUrls.length > 3 ? 3 : imageUrls.length;
    int remainingCount = imageUrls.length - 3;

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: displayCount,
      itemBuilder: (context, index) {
        bool isLast = index == 2 && remainingCount > 0;
        return Padding(
          padding: EdgeInsets.only(right: 8.w),
          child: GestureDetector(
            onTap: () {
              if (isLast) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ScrollableImageGallery(images: imageUrls),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImageGalleryViewer(
                      images: imageUrls,
                      initialIndex: index,
                    ),
                  ),
                );
              }
            },
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Image.network(
                    imageUrls[index],
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
                // Image count indicator - only on last image
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
                        imageUrls.length > 3
                            ? '+${imageUrls.length}'
                            : '${imageUrls.length}',
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

// Scrollable image gallery with all images
class ScrollableImageGallery extends StatelessWidget {
  final List<String> images;

  const ScrollableImageGallery({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'All Images (${images.length})',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(16.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8.w,
          mainAxisSpacing: 8.h,
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // Open full screen viewer for selected image
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ImageGalleryViewer(images: images, initialIndex: index),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.network(
                images[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade300,
                    child: Icon(
                      Icons.image,
                      color: Colors.grey.shade500,
                      size: 30.sp,
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
