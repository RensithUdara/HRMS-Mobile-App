import 'package:flutter/material.dart';

import '../config/app_theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonType type;
  final IconData? icon;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.type = ButtonType.primary,
    this.icon,
    this.width,
    this.height,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final buttonHeight = height ?? 50.0;

    if (isLoading) {
      return Container(
        width: width,
        height: buttonHeight,
        decoration: BoxDecoration(
          color: backgroundColor ?? _getBackgroundColor(context),
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      );
    }

    switch (type) {
      case ButtonType.primary:
        return SizedBox(
          width: width,
          height: buttonHeight,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor ?? AppTheme.primaryColor,
              foregroundColor: textColor ?? Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
              elevation: 2,
            ),
            child: _buildButtonContent(),
          ),
        );

      case ButtonType.secondary:
        return SizedBox(
          width: width,
          height: buttonHeight,
          child: OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: textColor ?? AppTheme.primaryColor,
              side: BorderSide(
                color: backgroundColor ?? AppTheme.primaryColor,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
            ),
            child: _buildButtonContent(),
          ),
        );

      case ButtonType.text:
        return SizedBox(
          width: width,
          height: buttonHeight,
          child: TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              foregroundColor: textColor ?? AppTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
            ),
            child: _buildButtonContent(),
          ),
        );

      case ButtonType.danger:
        return SizedBox(
          width: width,
          height: buttonHeight,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor ?? AppTheme.errorColor,
              foregroundColor: textColor ?? Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
              elevation: 2,
            ),
            child: _buildButtonContent(),
          ),
        );

      case ButtonType.success:
        return SizedBox(
          width: width,
          height: buttonHeight,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor ?? AppTheme.successColor,
              foregroundColor: textColor ?? Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
              elevation: 2,
            ),
            child: _buildButtonContent(),
          ),
        );
    }
  }

  Widget _buildButtonContent() {
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppDimensions.iconSizeS),
          const SizedBox(width: AppDimensions.paddingS),
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize ?? 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize ?? 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Color _getBackgroundColor(BuildContext context) {
    switch (type) {
      case ButtonType.primary:
        return backgroundColor ?? AppTheme.primaryColor;
      case ButtonType.secondary:
        return backgroundColor ?? Colors.transparent;
      case ButtonType.text:
        return backgroundColor ?? Colors.transparent;
      case ButtonType.danger:
        return backgroundColor ?? AppTheme.errorColor;
      case ButtonType.success:
        return backgroundColor ?? AppTheme.successColor;
    }
  }
}

enum ButtonType {
  primary,
  secondary,
  text,
  danger,
  success,
}

class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final String? tooltip;

  const CustomIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 48.0,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(size / 4),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: iconColor ?? AppTheme.primaryColor,
          size: size * 0.5,
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}

class CustomFloatingActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool mini;

  const CustomFloatingActionButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.mini = false,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: backgroundColor ?? AppTheme.secondaryColor,
      foregroundColor: foregroundColor ?? Colors.white,
      mini: mini,
      child: Icon(icon),
    );
  }
}

class CustomButtonGroup extends StatelessWidget {
  final List<CustomButtonGroupItem> items;
  final Axis direction;
  final double spacing;

  const CustomButtonGroup({
    super.key,
    required this.items,
    this.direction = Axis.horizontal,
    this.spacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final buttons = items
        .map((item) => CustomButton(
              text: item.text,
              onPressed: item.onPressed,
              type: item.type,
              icon: item.icon,
            ))
        .toList();

    if (direction == Axis.horizontal) {
      return Row(
        children: _buildWithSpacing(buttons),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _buildWithSpacing(buttons),
      );
    }
  }

  List<Widget> _buildWithSpacing(List<Widget> children) {
    final result = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      if (direction == Axis.horizontal) {
        result.add(Expanded(child: children[i]));
      } else {
        result.add(children[i]);
      }

      if (i < children.length - 1) {
        if (direction == Axis.horizontal) {
          result.add(SizedBox(width: spacing));
        } else {
          result.add(SizedBox(height: spacing));
        }
      }
    }
    return result;
  }
}

class CustomButtonGroupItem {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final IconData? icon;

  const CustomButtonGroupItem({
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.icon,
  });
}
