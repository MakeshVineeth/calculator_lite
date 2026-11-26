import 'package:flutter/material.dart';

class FlagIcon extends StatelessWidget {
  final String flagURL;
  static const double _size = 25.0;

  const FlagIcon({required this.flagURL, super.key});

  @override
  Widget build(BuildContext context) {
    final trimmed = flagURL.trim();
    final cachePx = (_size * MediaQuery.devicePixelRatioOf(context)).round();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: trimmed.isNotEmpty
          ? ClipOval(
              child: Image.asset(
                trimmed,
                package: 'country_icons',
                width: _size,
                height: _size,
                fit: BoxFit.cover,
                cacheWidth: cachePx > 0 ? cachePx : null,
                cacheHeight: cachePx > 0 ? cachePx : null,
                errorBuilder: (_, __, ___) => _fallbackIcon(),
              ),
            )
          : _fallbackIcon(),
    );
  }

  Widget _fallbackIcon() => Container(
    width: _size,
    height: _size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.grey[200],
    ),
    child: Icon(
      Icons.public,
      size: 16,
      color: Colors.grey[600],
    ),
  );
}
