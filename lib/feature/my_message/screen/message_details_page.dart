import 'package:denz_sen/feature/my_message/provider/message_details_provider.dart';
import 'package:denz_sen/feature/my_message/screen/my_message_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class MessageDetailsPage extends StatefulWidget {
  const MessageDetailsPage({super.key, required this.caseId});

  final int caseId;

  @override
  State<MessageDetailsPage> createState() => _MessageDetailsPageState();
}

class _MessageDetailsPageState extends State<MessageDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<MessageDetailsProvider>(
          context,
          listen: false,
        ).fetchMessageDetails(widget.caseId);
      }
    });
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
        title: Text(
          'Case #${widget.caseId.toString().padLeft(5, '0')}',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<MessageDetailsProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 5,
                    itemBuilder: (context, index) => const MessageShimmer(),
                  );
                }

                if (provider.messages.isEmpty) {
                  return const Center(child: Text('No messages found'));
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: provider.messages.length,
                  itemBuilder: (context, index) {
                    final message = provider.messages[index];
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
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.attach_file, color: Colors.grey.shade600),
            onPressed: () {},
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Text(
                'Enter your message',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 15.sp),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFF5B7C99),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(Icons.send, color: Colors.white, size: 20.sp),
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
              // If it's the last image with more images, show scrollable gallery
              // Otherwise show full screen viewer
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
                if (isLast)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.6),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '+$remainingCount',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'View All',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.sp,
                                ),
                              ),
                            ],
                          ),
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
