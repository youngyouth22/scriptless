import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:scriptless/common/resources/app_colors.dart';
import 'package:scriptless/common/resources/image_resources.dart';

/// A circular liquid glass back button with spring physics
/// and scale transitions.
///
/// Tapping the button pops the current route or invokes [onPressed].
class ArrowBackButton extends StatefulWidget {
  /// Creates a new [ArrowBackButton].
  const ArrowBackButton({
    super.key,
    this.onPressed,
    this.isVisible = true,
    this.borderRadius = 96,
  });

  /// Optional callback to be invoked when the button is tapped.
  /// If not provided, the button will pop the current route.
  final VoidCallback? onPressed;

  /// Whether the button is visible.
  /// Animates scaling up when true and scaling down when false.
  final bool isVisible;

  /// Border radius of the button (defaults to 96).
  final double borderRadius;

  @override
  State<ArrowBackButton> createState() => _ArrowBackButtonState();
}

class _ArrowBackButtonState extends State<ArrowBackButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _glassHighlightAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 70),
      reverseDuration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1, end: 0.88).animate(
      CurvedAnimation(
        parent: _pressController,
        curve: Curves.easeOut,
        reverseCurve: Curves.elasticOut,
      ),
    );

    _glassHighlightAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _pressController,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      ),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    unawaited(HapticFeedback.lightImpact());
    _pressController.forward();
  }

  void _handleTapUp(TapUpDetails _) {
    _pressController.reverse();
  }

  void _handleTapCancel() {
    _pressController.reverse();
  }

  void _handleTap() {
    if (widget.onPressed != null) {
      widget.onPressed!();
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(widget.borderRadius);

    return AnimatedScale(
      scale: widget.isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 280),
      curve: widget.isVisible ? Curves.easeOutBack : Curves.easeInBack,
      child: AnimatedOpacity(
        opacity: widget.isVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        child: Center(
          child: AnimatedBuilder(
            animation: _pressController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              );
            },
            child: GestureDetector(
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              onTap: _handleTap,
              behavior: HitTestBehavior.opaque,
              child: ClipRRect(
                borderRadius: radius,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: AnimatedBuilder(
                    animation: _glassHighlightAnimation,
                    builder: (context, child) {
                      final highlight = _glassHighlightAnimation.value;
                      return Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: radius,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.white.withValues(
                                alpha: 0.92 + (highlight * 0.06),
                              ),
                              AppColors.white.withValues(
                                alpha: 0.78 + (highlight * 0.12),
                              ),
                            ],
                          ),
                          border: Border.all(
                            color: Color.lerp(
                              AppColors.grey100,
                              AppColors.white,
                              highlight,
                            )!,
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withValues(
                                alpha: 0.06 - (highlight * 0.02),
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                            if (highlight > 0)
                              BoxShadow(
                                color: AppColors.white.withValues(
                                  alpha: 0.4 * highlight,
                                ),
                                blurRadius: 6,
                              ),
                          ],
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            ImageResources.arrowLeft,
                            height: 14,
                            colorFilter: const ColorFilter.mode(
                              AppColors.grey950,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
