import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

class ExperiencePreview {
  final String url;
  final String title;
  final String? description;
  final String? imageUrl;
  final List<String> highlights;

  const ExperiencePreview({
    required this.url,
    required this.title,
    this.description,
    this.imageUrl,
    this.highlights = const [],
  });
}

class HomeState {
  final bool initialized;
  final String selectedCategory;

  const HomeState({
    this.initialized = false,
    this.selectedCategory = 'all',
  });

  HomeState copyWith({
    bool? initialized,
    String? selectedCategory,
  }) {
    return HomeState(
      initialized: initialized ?? this.initialized,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}

class HomeNotifier extends Notifier<HomeState> {
  @override
  HomeState build() {
    return const HomeState();
  }

  void initialize() {
    state = state.copyWith(initialized: true);
  }

  void setSelectedCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }
}

final homeProvider = NotifierProvider<HomeNotifier, HomeState>(() {
  return HomeNotifier();
});

final boutiqueExperiencePreviewProvider = FutureProvider<ExperiencePreview>((ref) async {
  const url = 'https://hanoilechateauhotelandspa.com/boutique-experience/';

  Future<ExperiencePreview> fallback() async {
    return const ExperiencePreview(
      url: url,
      title: 'Boutique Experience',
      description: 'Trải nghiệm cùng khách sạn — nghỉ dưỡng, khám phá và thư giãn.',
      highlights: [
        'Chào đón tại lễ tân',
        'Thư giãn trong phòng',
        'Khám phá phố cổ Hà Nội',
        'Thư giãn tại Château Spa',
      ],
    );
  }

  try {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 12),
        responseType: ResponseType.plain,
        headers: const {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120 Safari/537.36',
        },
      ),
    );

    final res = await dio.get(url);
    final html = (res.data ?? '').toString();
    if (html.trim().isEmpty) return fallback();

    String? _firstMeta(String propertyOrName) {
      final re = RegExp(
        '(?:property|name)=["\\\']$propertyOrName["\\\'][^>]*content=["\\\']([^"\\\']+)["\\\']',
        caseSensitive: false,
      );
      final m = re.firstMatch(html);
      return m?.group(1);
    }

    String _stripTags(String input) {
      return input
          .replaceAll(RegExp('<[^>]+>'), ' ')
          .replaceAll('&amp;', '&')
          .replaceAll('&quot;', '"')
          .replaceAll('&#39;', "'")
          .replaceAll('&nbsp;', ' ')
          .replaceAll(RegExp('\\s+'), ' ')
          .trim();
    }

    final ogTitle = _firstMeta('og:title');
    final ogDesc = _firstMeta('og:description');
    final ogImage = _firstMeta('og:image');

    final h3Matches = RegExp(
      '<h3[^>]*>([\\s\\S]*?)<\\/h3>',
      caseSensitive: false,
    ).allMatches(html);

    final highlights = <String>[];
    for (final m in h3Matches) {
      final t = _stripTags(m.group(1) ?? '');
      if (t.isEmpty) continue;
      if (highlights.contains(t)) continue;
      highlights.add(t);
      if (highlights.length >= 4) break;
    }

    final title = _stripTags(ogTitle ?? 'Boutique Experience');

    return ExperiencePreview(
      url: url,
      title: title.isEmpty ? 'Boutique Experience' : title,
      description: ogDesc != null ? _stripTags(ogDesc) : null,
      imageUrl: ogImage,
      highlights: highlights,
    );
  } catch (_) {
    return fallback();
  }
});


