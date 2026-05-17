import 'package:flutter/material.dart';

class AppSwitch extends StatelessWidget {
  final bool value;
  final String label;
  final String? subtitle;
  final ValueChanged<bool>? onChanged;

  const AppSwitch({
    super.key,
    required this.value,
    required this.label,
    this.subtitle,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}