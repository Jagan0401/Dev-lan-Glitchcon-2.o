import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../models/doctor_dashboard_models.dart';

class CaseloadChart extends StatelessWidget {
  final List<CaseloadBar> bars;

  const CaseloadChart({super.key, required this.bars});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: SizedBox(
        height: 140,
        child: Column(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: bars.asMap().entries.map((entry) {
                  final bar = entry.value;
                  final isLast = entry.key == bars.length - 1;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: isLast ? 0 : 10),
                      child: _AnimatedBar(bar: bar),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: bars.asMap().entries.map((entry) {
                final bar = entry.value;
                final isLast = entry.key == bars.length - 1;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: isLast ? 0 : 10),
                    child: Text(
                      bar.label,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedBar extends StatefulWidget {
  final CaseloadBar bar;
  const _AnimatedBar({required this.bar});

  @override
  State<_AnimatedBar> createState() => _AnimatedBarState();
}

class _AnimatedBarState extends State<_AnimatedBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.bar.isCritical ? AppColors.error : AppColors.primary;
    final opacity = widget.bar.isCritical
        ? 1.0
        : switch (widget.bar.label) {
            'Low' => 0.5,
            'Med' => 0.7,
            'High' => 0.9,
            _ => 1.0,
          };

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AnimatedBuilder(
          animation: _anim,
          builder: (_, __) {
            return FractionallySizedBox(
              heightFactor: widget.bar.fraction * _anim.value,
              child: Stack(
                alignment: Alignment.topCenter,
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: color.withOpacity(opacity),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -20,
                    child: Text(
                      '${(widget.bar.fraction * 100).toInt()}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMain,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
