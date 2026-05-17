import 'dart:math';
import 'package:flutter/material.dart';

class AudioWaveform extends StatefulWidget {
  final double amplitude;
  final bool isActive;
  final int barCount;
  final Color? color;

  const AudioWaveform({
    super.key,
    required this.amplitude,
    this.isActive = false,
    this.barCount = 20,
    this.color,
  });

  @override
  State<AudioWaveform> createState() => _AudioWaveformState();
}

class _AudioWaveformState extends State<AudioWaveform>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<double> _bars = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _bars.addAll(List.generate(widget.barCount, (_) => 0.1));
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..addListener(_updateBars);
  }

  void _updateBars() {
    if (widget.isActive) {
      setState(() {
        for (int i = 0; i < _bars.length; i++) {
          final target = widget.amplitude * (0.5 + _random.nextDouble() * 0.5);
          _bars[i] = _bars[i] + (target - _bars[i]) * 0.3;
        }
      });
    }
  }

  @override
  void didUpdateWidget(AudioWaveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isActive && _controller.isAnimating) {
      _controller.stop();
      setState(() {
        for (int i = 0; i < _bars.length; i++) {
          _bars[i] = _bars[i] * 0.9;
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;

    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(widget.barCount, (index) {
          final height = max(4.0, _bars[index] * 50);
          return AnimatedContainer(
            duration: const Duration(milliseconds: 50),
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 4,
            height: height,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }
}