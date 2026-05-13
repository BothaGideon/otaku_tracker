/// Formats [value] with thousands separators (e.g. 1234567 → "1,234,567").
String formatNumberWithSeparator(num? value, {String fallback = 'N/A'}) {
  if (value == null) return fallback;
  return value
      .toInt()
      .toString()
      .replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
}

/// Formats [value] in compact notation (e.g. 1200 → "1.2K", 2000000 → "2M", 2430000000 → "2.43B").
String formatNumberCompact(num? value, {String fallback = 'N/A'}) {
  if (value == null) return fallback;
  final n = value.toDouble();
  if (n >= 1e9) return '${_trimmed(n / 1e9)}B';
  if (n >= 1e6) return '${_trimmed(n / 1e6)}M';
  if (n >= 1e3) return '${_trimmed(n / 1e3)}K';
  return value.toInt().toString();
}

String _trimmed(double v) =>
    v.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
