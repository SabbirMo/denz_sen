import 'package:denz_sen/core/theme/app_colors.dart';
import 'package:denz_sen/core/theme/app_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomField extends StatelessWidget {
  const CustomField({
    super.key,
    this.hintText,
    this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.obsecureText = false,
    this.type,
    this.maxLines = 1,
    this.title,
    this.readOnly = false,
    this.onTap,
  });
  final String? hintText;
  final TextEditingController? controller;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obsecureText;
  final TextInputType? type;
  final int maxLines;
  final String? title;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Text(title!, style: AppStyle.book16.copyWith(color: AppColors.grey)),
        4.h.verticalSpace,
        Container(
          margin: EdgeInsets.only(bottom: 14.h),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: TextFormField(
            readOnly: readOnly,
            onTap: onTap,
            controller: controller,
            cursorColor: AppColors.primaryColor,
            keyboardType: type,
            autofocus: false,
            textInputAction: TextInputAction.next,
            maxLines: maxLines,
            decoration: InputDecoration(
              alignLabelWithHint: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: prefixIcon != null ? 1 : 10,
                vertical: 12,
              ),
              hintText: hintText,
              hintStyle: TextStyle(
                color: AppColors.grey.withValues(alpha: 0.4),
                fontSize: 16.sp,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(
                  color: AppColors.black.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
              ),

              prefixIcon: prefixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: prefixIcon,
                    )
                  : null,
              prefixIconConstraints: const BoxConstraints(
                minWidth: 48,
                minHeight: 48,
              ),
              suffixIcon: suffixIcon,
              suffixIconConstraints: const BoxConstraints(
                minWidth: 48,
                minHeight: 48,
              ),
            ),
            obscureText: obsecureText,
          ),
        ),
      ],
    );
  }
}
