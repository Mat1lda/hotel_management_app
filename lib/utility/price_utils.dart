class PriceUtils {
  const PriceUtils._();

  static String formatVnd(num value) {
    final String s = value.round().toString();
    final String formatted = s.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return '$formatted VNĐ';
  }
}


