import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CloseCaseDialog {
  static Future<void> show(BuildContext context, {VoidCallback? onConfirm}) {
    return showDialog(
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
            TextButton(
              onPressed: () {
                Navigator.pop(context);

                // যদি বাইরে থেকে custom action পাঠাও
                if (onConfirm != null) {
                  onConfirm();
                } else {
                  // default behavior
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Case closed successfully')),
                  );
                }
              },
              child: const Text(
                'Close Case',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
