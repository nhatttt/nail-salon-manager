import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/theme/app_theme.dart';

// iOS-style app bar
class IosAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;

  const IosAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoNavigationBar(
      middle: Text(title),
      trailing: actions != null && actions!.isNotEmpty
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: actions!,
            )
          : null,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: AppTheme.white,
      border: const Border(
        bottom: BorderSide(
          color: AppTheme.mediumGrey,
          width: 0.5,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(44.0);
}

// iOS-style button
class IosButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isDestructive;
  final bool isFullWidth;
  final IconData? icon;

  const IosButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isPrimary = true,
    this.isDestructive = false,
    this.isFullWidth = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Color textColor;
    Color backgroundColor;

    if (isDestructive) {
      textColor = Colors.white;
      backgroundColor = Colors.red;
    } else if (isPrimary) {
      textColor = AppTheme.black;
      backgroundColor = AppTheme.mintGreen;
    } else {
      textColor = AppTheme.mintGreen;
      backgroundColor = Colors.transparent;
    }

    Widget buttonContent = Text(
      text,
      style: TextStyle(
        color: textColor,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );

    if (icon != null) {
      buttonContent = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 18),
          const SizedBox(width: 8),
          buttonContent,
        ],
      );
    }

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: CupertinoButton(
          padding: const EdgeInsets.symmetric(vertical: 16),
          color: isPrimary || isDestructive ? backgroundColor : null,
          onPressed: onPressed,
          child: buttonContent,
        ),
      );
    }

    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isPrimary || isDestructive ? backgroundColor : null,
      onPressed: onPressed,
      child: buttonContent,
    );
  }
}

// iOS-style text field
class IosTextField extends StatelessWidget {
  final String placeholder;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int? maxLines;
  final int? minLines;
  final bool autofocus;
  final FocusNode? focusNode;
  final Widget? prefix;
  final Widget? suffix;

  const IosTextField({
    super.key,
    required this.placeholder,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.minLines,
    this.autofocus = false,
    this.focusNode,
    this.prefix,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      controller: controller,
      placeholder: placeholder,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onChanged: onChanged,
      maxLines: maxLines,
      minLines: minLines,
      autofocus: autofocus,
      focusNode: focusNode,
      prefix: prefix != null
          ? Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: prefix,
            )
          : null,
      suffix: suffix != null
          ? Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: suffix,
            )
          : null,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.lightGrey,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

// iOS-style segmented control
class IosSegmentedControl<T extends Object> extends StatelessWidget {
  final Map<T, Widget> children;
  final T groupValue;
  final void Function(T) onValueChanged;

  const IosSegmentedControl({
    super.key,
    required this.children,
    required this.groupValue,
    required this.onValueChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoSegmentedControl<T>(
      children: children,
      groupValue: groupValue,
      onValueChanged: onValueChanged,
      selectedColor: AppTheme.mintGreen,
      unselectedColor: AppTheme.white,
      borderColor: AppTheme.mintGreen,
    );
  }
}

// iOS-style list tile
class IosListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;

  const IosListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.black,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.darkGrey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 16),
                  trailing!,
                ],
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            thickness: 0.5,
            indent: 16,
            endIndent: 0,
            color: AppTheme.mediumGrey,
          ),
      ],
    );
  }
}

// Loading indicator
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CupertinoActivityIndicator(),
    );
  }
}

// Error message
class ErrorMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorMessage({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.exclamationmark_circle,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.darkGrey,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              IosButton(
                text: 'Retry',
                onPressed: onRetry!,
                isPrimary: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Empty state
class EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionText;

  const EmptyState({
    super.key,
    required this.message,
    this.icon = CupertinoIcons.doc,
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppTheme.darkGrey,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.darkGrey,
              ),
            ),
            if (onAction != null && actionText != null) ...[
              const SizedBox(height: 16),
              IosButton(
                text: actionText!,
                onPressed: onAction!,
                isPrimary: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Status badge
class StatusBadge extends StatelessWidget {
  final String text;
  final Color color;

  const StatusBadge({
    super.key,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

// Section header
class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.darkGrey,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// Bottom action bar
class BottomActionBar extends StatelessWidget {
  final List<Widget> children;

  const BottomActionBar({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppTheme.white,
        border: Border(
          top: BorderSide(
            color: AppTheme.mediumGrey,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: children,
        ),
      ),
    );
  }
}
