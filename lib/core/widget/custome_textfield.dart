import 'package:flutter/material.dart';
import 'package:flutter_app/core/constants/app_colors.dart';

class CustomTextFormField extends StatelessWidget {
  final String? label;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final Color? fillColor;
  final String? errorText;

  const CustomTextFormField({
    super.key,
    this.label,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.controller,
    this.onChanged,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.fillColor,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              label!,
              style: TextStyle(
                color: isDark ? Theme.of(context).colorScheme.onSurface.withOpacity(0.7) : AppColors.textGrey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: fillColor ?? (isDark ? Colors.white.withOpacity(0.05) : AppColors.inputBg),
            borderRadius: BorderRadius.circular(16),
            border: errorText != null 
                ? Border.all(color: AppColors.red, width: 1) 
                : (isDark ? Border.all(color: Colors.white.withOpacity(0.1), width: 1) : null),
          ),
          child: TextFormField(
            controller: controller,
            onChanged: onChanged,
            validator: validator,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 15,
            ),
            cursorColor: AppColors.primaryPurple,
            decoration: InputDecoration(
              prefixIcon: Icon(prefixIcon, color: isDark ? Colors.white.withOpacity(0.5) : AppColors.iconGrey),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              hintText: hintText,
              hintStyle: TextStyle(
                color: isDark ? Colors.white.withOpacity(0.3) : AppColors.iconGrey, 
                fontSize: 14,
              ),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 4),
            child: Text(
              errorText!,
              style: const TextStyle(color: AppColors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
