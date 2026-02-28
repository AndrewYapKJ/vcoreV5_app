import 'package:flutter/material.dart';
import 'package:flutter_scale_kit/flutter_scale_kit.dart';
import 'package:vcore_v5_app/core/font_styling.dart';

typedef SuggestionsCallback<T> = Future<List<T>> Function(String pattern);
typedef ItemBuilder<T> = Widget Function(BuildContext context, T suggestion);
typedef OnSuggestionSelected<T> = void Function(T suggestion);
typedef SuggestionDisplay<T> = String Function(T suggestion);
typedef OnQRScanned = Future<String?> Function();

class CustomTypeAheadField<T> extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final OnQRScanned? onQRScan;
  final SuggestionsCallback<T> suggestionsCallback;
  final ItemBuilder<T> itemBuilder;
  final OnSuggestionSelected<T> onSuggestionSelected;
  final SuggestionDisplay<T> suggestionDisplay;
  final ColorScheme colorScheme;
  final BuildContext context;
  final int maxSuggestions;
  final Duration debounceDuration;
  final bool hideOnEmpty;

  const CustomTypeAheadField({
    super.key,
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.onQRScan,
    required this.suggestionsCallback,
    required this.itemBuilder,
    required this.onSuggestionSelected,
    required this.suggestionDisplay,
    required this.colorScheme,
    required this.context,
    this.maxSuggestions = 5,
    this.debounceDuration = const Duration(milliseconds: 300),
    this.hideOnEmpty = true,
  });

  @override
  State<CustomTypeAheadField<T>> createState() =>
      _CustomTypeAheadFieldState<T>();
}

class _CustomTypeAheadFieldState<T> extends State<CustomTypeAheadField<T>> {
  late FocusNode _focusNode;
  List<T> _suggestions = [];
  bool _isLoading = false;
  int _selectedIndex = -1;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
    widget.controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    widget.controller.removeListener(_onSearchChanged);
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      // Clear everything when losing focus
      setState(() {
        _showSuggestions = false;
        _suggestions = [];
        _selectedIndex = -1;
      });
    } else {
      // Show suggestions when focused, even if empty
      setState(() => _showSuggestions = true);
      _searchSuggestions();
    }
  }

  void _onSearchChanged() {
    setState(() {
      _selectedIndex = -1;
    });

    _searchSuggestions();
  }

  Future<void> _searchSuggestions() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final suggestions = await widget.suggestionsCallback(
        widget.controller.text,
      );

      if (!mounted) return;

      setState(() {
        _suggestions = suggestions.take(widget.maxSuggestions).toList();
        _isLoading = false;
        _showSuggestions = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Widget _buildSuggestionsList() {
    if (_isLoading) {
      return Padding(
        padding: EdgeInsets.all(16.h),
        child: Center(
          child: SizedBox(
            height: 24.h,
            width: 24.h,
            child: CircularProgressIndicator(
              color: widget.colorScheme.primary,
              strokeWidth: 2,
            ),
          ),
        ),
      );
    }

    if (_suggestions.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(16.h),
        child: Text(
          'No suggestions found',
          style: widget.context.font
              .regular(widget.context)
              .copyWith(
                fontSize: 12.sp,
                color: widget.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_suggestions.length, (index) {
        final suggestion = _suggestions[index];
        final isSelected = _selectedIndex == index;

        return Container(
          color: isSelected
              ? widget.colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          child: InkWell(
            onTap: () {
              // Temporarily remove listener to prevent re-searching
              widget.controller.removeListener(_onSearchChanged);

              widget.controller.text = widget.suggestionDisplay(suggestion);
              widget.onSuggestionSelected(suggestion);

              // Re-add the listener
              widget.controller.addListener(_onSearchChanged);

              setState(() {
                _showSuggestions = false;
                _suggestions = [];
                _selectedIndex = -1;
              });
              _focusNode.unfocus();
            },
            onHover: (isHovering) {
              if (isHovering) {
                setState(() => _selectedIndex = index);
              }
            },
            child: Padding(
              padding: EdgeInsets.all(12.h),
              child: widget.itemBuilder(context, suggestion),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          style: widget.context.font
              .regular(widget.context)
              .copyWith(fontSize: 14.sp),
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: Icon(
              widget.prefixIcon,
              color: widget.colorScheme.primary.withValues(alpha: 0.6),
              size: 18.h,
            ),
            suffixIcon: widget.suffixIcon != null
                ? GestureDetector(
                    onTap: () async {
                      if (widget.onQRScan != null) {
                        final scannedValue = await widget.onQRScan!();
                        if (scannedValue != null && mounted) {
                          setState(() {
                            widget.controller.text = scannedValue;
                            _suggestions = [];
                            _showSuggestions = false;
                          });
                        }
                      } else if (widget.onSuffixTap != null) {
                        widget.onSuffixTap!();
                      }
                    },
                    child: Icon(
                      widget.suffixIcon,
                      color: widget.colorScheme.primary.withValues(alpha: 0.6),
                      size: 18.h,
                    ),
                  )
                : null,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
            isDense: true,
            filled: true,
            fillColor: widget.colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: widget.colorScheme.outline.withValues(alpha: 0.15),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: widget.colorScheme.outline.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: widget.colorScheme.primary,
                width: 2,
              ),
            ),
            hintStyle: widget.context.font
                .regular(widget.context)
                .copyWith(
                  fontSize: 14.sp,
                  color: widget.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
          ),
        ),
        if (_showSuggestions)
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: 4.h),
            decoration: BoxDecoration(
              color: widget.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.colorScheme.outline.withValues(alpha: 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            constraints: BoxConstraints(maxHeight: 300.h),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: _buildSuggestionsList(),
            ),
          ),
      ],
    );
  }
}
