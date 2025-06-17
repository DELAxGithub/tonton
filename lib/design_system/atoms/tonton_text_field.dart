import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../theme/tokens.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

/// Apple HIG-compliant text field styles
enum TontonTextFieldStyle {
  /// Default bordered style
  bordered,

  /// Plain style without borders (for inline editing)
  plain,

  /// Rounded style with pill-shaped border
  rounded,
}

/// Apple HIG-compliant text field component
///
/// A text input field that follows Apple's design guidelines with proper
/// styling, interaction feedback, and accessibility.
class TontonTextField extends StatefulWidget {
  /// Text field controller
  final TextEditingController? controller;

  /// Focus node
  final FocusNode? focusNode;

  /// Placeholder text
  final String? placeholder;

  /// Helper text shown below the field
  final String? helperText;

  /// Error text (replaces helper text when set)
  final String? errorText;

  /// Leading widget (icon or text)
  final Widget? leading;

  /// Trailing widget (icon or button)
  final Widget? trailing;

  /// Text field style
  final TontonTextFieldStyle style;

  /// Whether the field is enabled
  final bool enabled;

  /// Whether to obscure text (for passwords)
  final bool obscureText;

  /// Whether to enable autocorrect
  final bool autocorrect;

  /// Keyboard type
  final TextInputType? keyboardType;

  /// Text input action
  final TextInputAction? textInputAction;

  /// Input formatters
  final List<TextInputFormatter>? inputFormatters;

  /// Maximum lines
  final int? maxLines;

  /// Minimum lines
  final int? minLines;

  /// Maximum length
  final int? maxLength;

  /// Whether to show character counter
  final bool showCounter;

  /// Callback when text changes
  final ValueChanged<String>? onChanged;

  /// Callback when editing is complete
  final VoidCallback? onEditingComplete;

  /// Callback when field is submitted
  final ValueChanged<String>? onSubmitted;

  /// Callback when field is tapped
  final VoidCallback? onTap;

  /// Text alignment
  final TextAlign textAlign;

  /// Text capitalization
  final TextCapitalization textCapitalization;

  /// Whether the field should autofocus
  final bool autofocus;

  const TontonTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.placeholder,
    this.helperText,
    this.errorText,
    this.leading,
    this.trailing,
    this.style = TontonTextFieldStyle.bordered,
    this.enabled = true,
    this.obscureText = false,
    this.autocorrect = true,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.showCounter = false,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.onTap,
    this.textAlign = TextAlign.start,
    this.textCapitalization = TextCapitalization.none,
    this.autofocus = false,
  });

  @override
  State<TontonTextField> createState() => _TontonTextFieldState();
}

class _TontonTextFieldState extends State<TontonTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasError = widget.errorText != null;

    // Determine colors
    Color borderColor;
    Color backgroundColor;
    Color textColor;
    Color placeholderColor;

    if (!widget.enabled) {
      borderColor = TontonColors.separatorColor(context);
      backgroundColor = TontonColors.fillColor(context);
      textColor = TontonColors.tertiaryLabelColor(context);
      placeholderColor = TontonColors.quaternaryLabelColor(context);
    } else if (hasError) {
      borderColor = TontonColors.systemRed;
      backgroundColor =
          isDark
              ? TontonColors.tertiarySystemBackgroundDark
              : TontonColors.tertiarySystemBackground;
      textColor = TontonColors.labelColor(context);
      placeholderColor = TontonColors.tertiaryLabelColor(context);
    } else if (_isFocused) {
      borderColor = theme.colorScheme.primary;
      backgroundColor =
          isDark
              ? TontonColors.tertiarySystemBackgroundDark
              : TontonColors.tertiarySystemBackground;
      textColor = TontonColors.labelColor(context);
      placeholderColor = TontonColors.tertiaryLabelColor(context);
    } else {
      borderColor = TontonColors.separatorColor(context);
      backgroundColor =
          isDark
              ? TontonColors.tertiarySystemBackgroundDark
              : TontonColors.tertiarySystemBackground;
      textColor = TontonColors.labelColor(context);
      placeholderColor = TontonColors.tertiaryLabelColor(context);
    }

    // Build input decoration based on style
    InputDecoration? decoration;
    BorderRadius? borderRadius;

    switch (widget.style) {
      case TontonTextFieldStyle.bordered:
        borderRadius = Radii.mediumBorderRadius;
        decoration = InputDecoration(
          hintText: widget.placeholder,
          hintStyle: TontonTypography.body.copyWith(color: placeholderColor),
          contentPadding: EdgeInsets.symmetric(
            horizontal: widget.leading != null ? 0 : Spacing.md,
            vertical: Spacing.sm,
          ),
          filled: true,
          fillColor: backgroundColor,
          border: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide(color: borderColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide(color: borderColor),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide(color: borderColor, width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide(color: borderColor),
          ),
          prefixIcon: widget.leading,
          suffixIcon: widget.trailing,
          counterText: widget.showCounter ? null : '',
        );
        break;

      case TontonTextFieldStyle.plain:
        decoration = InputDecoration(
          hintText: widget.placeholder,
          hintStyle: TontonTypography.body.copyWith(color: placeholderColor),
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          prefixIcon: widget.leading,
          suffixIcon: widget.trailing,
          counterText: widget.showCounter ? null : '',
        );
        break;

      case TontonTextFieldStyle.rounded:
        borderRadius = Radii.fullBorderRadius;
        decoration = InputDecoration(
          hintText: widget.placeholder,
          hintStyle: TontonTypography.body.copyWith(color: placeholderColor),
          contentPadding: EdgeInsets.symmetric(
            horizontal: widget.leading != null ? 0 : Spacing.lg,
            vertical: Spacing.sm,
          ),
          filled: true,
          fillColor: backgroundColor,
          border: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide(color: borderColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide(color: borderColor),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide(color: borderColor, width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide(color: borderColor),
          ),
          prefixIcon: widget.leading,
          suffixIcon: widget.trailing,
          counterText: widget.showCounter ? null : '',
        );
        break;
    }

    // Build text field
    Widget textField = TextField(
      controller: _controller,
      focusNode: _focusNode,
      decoration: decoration,
      style: TontonTypography.body.copyWith(color: textColor),
      enabled: widget.enabled,
      obscureText: widget.obscureText,
      autocorrect: widget.autocorrect,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      inputFormatters: widget.inputFormatters,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      onChanged: widget.onChanged,
      onEditingComplete: widget.onEditingComplete,
      onSubmitted: widget.onSubmitted,
      onTap: widget.onTap,
      textAlign: widget.textAlign,
      textCapitalization: widget.textCapitalization,
      autofocus: widget.autofocus,
    );

    // Add helper/error text if needed
    if (widget.helperText != null || widget.errorText != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          textField,
          const SizedBox(height: Spacing.xs),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
            child: Text(
              widget.errorText ?? widget.helperText!,
              style: TontonTypography.caption1.copyWith(
                color:
                    hasError
                        ? TontonColors.systemRed
                        : TontonColors.secondaryLabelColor(context),
              ),
            ),
          ),
        ],
      );
    }

    return textField;
  }
}

/// A convenient search field with Apple-style design
class TontonSearchField extends StatelessWidget {
  /// Search controller
  final TextEditingController? controller;

  /// Placeholder text
  final String placeholder;

  /// Callback when search text changes
  final ValueChanged<String>? onChanged;

  /// Callback when search is submitted
  final ValueChanged<String>? onSubmitted;

  /// Callback when clear button is pressed
  final VoidCallback? onClear;

  /// Whether to show clear button
  final bool showClearButton;

  /// Whether the field is enabled
  final bool enabled;

  const TontonSearchField({
    super.key,
    this.controller,
    this.placeholder = 'Search',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.showClearButton = true,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TontonTextField(
      controller: controller,
      placeholder: placeholder,
      style: TontonTextFieldStyle.rounded,
      enabled: enabled,
      leading: Icon(
        CupertinoIcons.search,
        size: IconSize.medium,
        color: TontonColors.tertiaryLabelColor(context),
      ),
      trailing:
          showClearButton && controller?.text.isNotEmpty == true
              ? IconButton(
                icon: Icon(
                  CupertinoIcons.clear_circled_solid,
                  size: IconSize.medium,
                  color: TontonColors.tertiaryLabelColor(context),
                ),
                onPressed: () {
                  controller?.clear();
                  onClear?.call();
                  onChanged?.call('');
                },
              )
              : null,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: TextInputAction.search,
    );
  }
}
