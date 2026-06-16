class AppConstants {
  AppConstants._();

  // API
  static const String baseUrl = 'https://melon-detection.higherlearn.xyz';
  static const String predictEndpoint = '/predict';
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 60000;

  // Profile - daftar mahasiswa
  static const List<Map<String, String>> students = [
    {
      'name': 'Kristina Anggriani Marbun',
      'nim': '11S22042',
      'photo': 'assets/images/kristina.jpg',
    },
    {
      'name': 'Fretty Debora Sirait',
      'nim': '11S22016',
      'photo': 'assets/images/fretty.jpg',
    },
    {
      'name': 'Baha Ambrosius Sibarani',
      'nim': '11S22014',
      'photo': 'assets/images/baha.jpg',
    },
  ];

  static const String university = 'Institut Teknologi Del';
  static const String major = 'Sarjana Informatika';
  static const String className = 'TAIF-13';

  // Storage Keys
  static const String themeKey = 'app_theme';

  // Detection
  static const double boxStrokeWidth = 2.5;
  static const double minConfidence = 0.3;
  static const double labelFontSize = 12.0;
  static const double labelPadding = 4.0;

  // Label Translations
  static const Map<String, String> labelMap = {
    'kirin_mentah': 'Kirin Mentah',
    'kirin_matang': 'Kirin Matang',
    'melon_mentah': 'Melon Mentah',
    'melon_matang': 'Melon Matang',
    'melon': 'Melon',
  };

  static String translateLabel(String label) =>
      labelMap[label.toLowerCase()] ?? label;
}