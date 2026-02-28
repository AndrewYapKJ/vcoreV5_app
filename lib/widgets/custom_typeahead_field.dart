import 'package:flutter/material.dart';
import 'package:flutter_scale_kit/flutter_scale_kit.dart';
import 'package:vcore_v5_app/core/font_styling.dart';

typedef SuggestionsCallback<T> = Future<List<T>> Function(String pattern);
typedef ItemBuilder<T> = Widget Function(BuildContext context, T suggestion);
typedef OnSuggestionSelected<T> = void Function(T suggestion);
typedef SuggestionDisplay<T> = String Function(T suggestion);

class CustomTypeAheadField<T> extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
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
    Key? key,
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    required this.suggestionsCallback,
    required this.itemBuilder,
    required this.onSuggestionSelected,
    required this.suggestionDisplay,
    required this.colorScheme,
    required this.context,
    this.maxSuggestions = 10,
    this.debounceDuration = const Duration(milliseconds: 300),
    this.hideOnEmpty = true,
  }) : super(key: key);

  @override
  State<CustomTypeAheadField<T>> createState() =>
      _CustomTypeAheadFieldState<T>();
}

class _CustomTypeAheadFieldState<T> extends State<CustomTypeAheadField<T>> {
  late FocusNode _focusNode;
  late LayerLink _layerLink;
  OverlayEntry? _overlayEntry;
  List<T> _suggestions = [];
  bool _isLoading = false;
  int _selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _layerLink = LayerLink();
    _focusNode.addListener(_handleFocusChange);
    widget.controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    widget.controller.removeListener(_onSearchChanged);
    _overlayEntry?.remove();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    } else {
      _showOverlay();
    }
  }

  void _onSearchChanged() {
    setState(() {
      _selectedIndex = -1;
    });

    if (widget.controller.text.isEmpty) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      return;
    }

    _searchSuggestions();
  }

  Future<void> _searchSuggestions() async {
    setState(() => _isLoading = true);

    try {
      final suggestions = await widget.suggestionsCallback(
        widget.controller.text,
      );
      setState(() {
        _suggestions = suggestions.take(widget.maxSuggestions).toList();
        _isLoading = false;
      });
      _showOverlay();
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _showOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
    }

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 55),
          child: Material(
            elevation: 16,
            borderRadius: BorderRadius.circular(12),
            color: Colors.transparent,
            child: Container(
              width: 300.w,
              decoration: BoxDecoration(
                color: widget.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.colorScheme.outline.withValues(alpha: 0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              constraints: BoxConstraints(maxHeight: 300.h),
              child: _buildSuggestionsList(),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  Widget _buildSuggestionsList() {
    if (widget.hideOnEmpty && widget.controller.text.isEmpty) {
      return SizedBox.shrink();
    }

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

    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: _suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = _suggestions[index];
        final isSelected = _selectedIndex == index;

        return Container(
          color: isSelected
              ? widget.colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          child: InkWell(
            onTap: () {
              widget.controller.text = widget.suggestionDisplay(suggestion);
              widget.onSuggestionSelected(suggestion);
              _focusNode.unfocus();
              _overlayEntry?.remove();
              _overlayEntry = null;
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
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
                  onTap: widget.onSuffixTap,
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
            borderSide: BorderSide(color: widget.colorScheme.primary, width: 2),
          ),
          hintStyle: widget.context.font
              .regular(widget.context)
              .copyWith(
                fontSize: 14.sp,
                color: widget.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
        ),
      ),
    );
  }
}
