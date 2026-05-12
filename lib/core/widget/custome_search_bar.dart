import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color backgroundColor;
  final IconData prefixIcon;
  final Color iconColor;
  final bool autofocus;

  const CustomSearchBar({
    super.key,
    this.hintText = 'Search...',
    this.controller,
    this.onChanged,
    this.padding = const EdgeInsets.symmetric(vertical: 7),
    this.borderRadius = 20,
    this.backgroundColor = Colors.transparent,
    this.prefixIcon = Icons.search,
    this.iconColor = Colors.transparent,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor == Colors.transparent ? (Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface) : backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          autofocus: autofocus,
          onChanged: onChanged,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              fontSize: 15,
            ),
            prefixIcon: Icon(prefixIcon, color: iconColor == Colors.transparent ? Theme.of(context).colorScheme.onSurface.withOpacity(0.6) : iconColor),
            filled: true,
            fillColor: Colors.transparent, // Handled by container
            contentPadding: const EdgeInsets.symmetric(
              vertical: 0,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }
}
