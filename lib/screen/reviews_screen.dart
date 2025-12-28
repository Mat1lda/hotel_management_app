import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../dialog/login_required_dialog.dart';
import '../model/request/review_create_request.dart';
import '../model/response/review_response.dart';
import '../provider/auth_provider.dart';
import '../provider/review_provider.dart';
import '../service/review_service.dart';
import '../service/sentiment_service.dart';
import '../utility/app_colors.dart';
import '../utility/custom_app_bar.dart';

class ReviewsScreen extends ConsumerStatefulWidget {
  const ReviewsScreen({super.key});

  @override
  ConsumerState<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends ConsumerState<ReviewsScreen> {
  final _detailsController = TextEditingController();
  final _reviewService = ReviewService();
  final _sentimentService = SentimentService();

  Timer? _debounce;
  bool _isAnalyzing = false;
  SentimentResult? _sentiment;
  double? _suggestedStars;
  String? _analyzeError;

  bool _isSubmitting = false;
  int _selectedStar = 5;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(reviewProvider);
      if (!state.hasLoaded && !state.isLoading) {
        ref.read(reviewProvider.notifier).loadAll();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _detailsController.dispose();
    super.dispose();
  }

  void _onDetailsChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 650), () async {
      final text = _detailsController.text.trim();
      if (text.isEmpty) {
        if (!mounted) return;
        setState(() {
          _isAnalyzing = false;
          _sentiment = null;
          _suggestedStars = null;
          _analyzeError = null;
        });
        return;
      }

      setState(() {
        _isAnalyzing = true;
        _analyzeError = null;
      });

      try {
        final res = await _sentimentService.analyze(text);
        final stars = SentimentService.suggestStars(
          pos: res.pos,
          neg: res.neg,
          neu: res.neu,
        );
        if (!mounted) return;
        setState(() {
          _sentiment = res;
          _suggestedStars = stars;
          _isAnalyzing = false;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isAnalyzing = false;
          _analyzeError =
              'Không phân tích được. Bạn vẫn có thể gửi đánh giá bình thường.';
        });
      }
    });
  }

  Future<void> _onSubmit() async {
    final authState = ref.read(authProvider);
    if (!authState.isLoggedIn) {
      final bool? goLogin = await showDialog<bool>(
        context: context,
        barrierDismissible: true,
        builder: (ctx) => const LoginRequiredDialog(
          message: 'Bạn cần đăng nhập để gửi đánh giá. Vui lòng đăng nhập để tiếp tục.',
        ),
      );
      if (!mounted) return;
      if (goLogin == true) {
        Navigator.of(context).pushNamed('/login');
      }
      return;
    }

    final text = _detailsController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập nhận xét trước khi gửi.'),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final token = authState.user?.token;
      final req = ReviewCreateRequest(
        details: text,
        star: _selectedStar,
        type: 'HOTEL',
        idCustomer: authState.user!.id,
      );
      final result = await _reviewService.createReview(req, token: token);
      if (!mounted) return;

      if (result['success'] == true) {
        _detailsController.clear();
        setState(() {
          _sentiment = null;
          _suggestedStars = null;
          _analyzeError = null;
          _selectedStar = 5;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cảm ơn bạn! Đánh giá đã được gửi.'),
            backgroundColor: AppColors.primary,
          ),
        );
        await ref.read(reviewProvider.notifier).loadAll();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']?.toString() ?? 'Gửi đánh giá thất bại'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } finally {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
    }
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildStarPicker() {
    return Row(
      children: [
        ...List.generate(5, (i) {
          final star = i + 1;
          final filled = star <= _selectedStar;
          return InkWell(
            onTap: _isSubmitting ? null : () => setState(() => _selectedStar = star),
            borderRadius: BorderRadius.circular(999),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
              child: Icon(
                filled ? Icons.star : Icons.star_border,
                size: 26,
                color: filled ? AppColors.warning : AppColors.iconUnselected,
              ),
            ),
          );
        }),
        const SizedBox(width: 10),
        Text(
          '$_selectedStar/5',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestedBox() {
    final suggest = _suggestedStars;
    final sentiment = _sentiment;

    if (_isAnalyzing) {
      return Row(
        children: const [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Đang phân tích cảm xúc để gợi ý số sao...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ),
        ],
      );
    }

    if (_analyzeError != null) {
      return Text(
        _analyzeError!,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          height: 1.3,
        ),
      );
    }

    if (suggest == null || sentiment == null) return const SizedBox.shrink();

    final diff = (suggest - _selectedStar).abs();
    final bool highlight = diff >= 2;
    final Color badgeColor = highlight ? AppColors.warning : AppColors.primary;

    String message;
    if (suggest >= 4.5) {
      message = 'Nghe có vẻ bạn rất hài lòng. Gợi ý giúp chúng tôi tổng hợp điểm mạnh để phát huy.';
    } else if (suggest >= 3.5) {
      message = 'Nhận xét khá tích cực. Gợi ý giúp chúng tôi hiểu điều bạn thích và điều cần cải thiện.';
    } else if (suggest >= 2.5) {
      message = 'Có vài điểm chưa ổn. Gợi ý giúp chúng tôi ưu tiên khắc phục đúng vấn đề.';
    } else {
      message = 'Có vẻ bạn chưa hài lòng. Gợi ý giúp chúng tôi nhận diện vấn đề quan trọng để cải thiện sớm.';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Gợi ý: ${suggest.toStringAsFixed(1)} sao',
                  style: TextStyle(
                    color: badgeColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'POS ${(sentiment.pos * 100).toStringAsFixed(0)}% • NEG ${(sentiment.neg * 100).toStringAsFixed(0)}% • NEU ${(sentiment.neu * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.35,
            ),
          ),
          if (highlight) ...[
            const SizedBox(height: 8),
            const Text(
              'Lưu ý: Số sao bạn chọn đang lệch khá nhiều so với nội dung comment. Bạn vẫn có thể giữ nguyên theo ý bạn.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }

  ({double avg, int count, List<int> dist}) _calcStats(List<ReviewResponse> items) {
    if (items.isEmpty) return (avg: 0, count: 0, dist: List.filled(5, 0));
    final dist = List<int>.filled(5, 0);
    int sum = 0;
    for (final r in items) {
      final s = r.star.clamp(1, 5);
      sum += s;
      dist[s - 1] += 1;
    }
    return (avg: sum / items.length, count: items.length, dist: dist);
  }

  Widget _starsRow(double rating) {
    final full = rating.floor();
    final hasHalf = (rating - full) >= 0.5;
    return Row(
      children: List.generate(5, (i) {
        if (i < full) {
          return const Icon(Icons.star, size: 18, color: AppColors.warning);
        }
        if (i == full && hasHalf) {
          return const Icon(Icons.star_half, size: 18, color: AppColors.warning);
        }
        return const Icon(Icons.star_border, size: 18, color: AppColors.iconUnselected);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final bool isLoggedIn = authState.isLoggedIn;
    final reviewState = ref.watch(reviewProvider);
    final items = reviewState.reviews;
    final stats = _calcStats(items);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Reviews',
        showBackButton: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          children: [
            _card(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stats.avg == 0 ? '—' : stats.avg.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _starsRow(stats.avg),
                        const SizedBox(height: 8),
                        Text(
                          'Dựa trên ${stats.count} đánh giá',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: List.generate(5, (i) {
                        final star = 5 - i;
                        final count = stats.dist[star - 1];
                        final ratio = stats.count == 0 ? 0.0 : count / stats.count;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 16,
                                child: Text(
                                  '$star',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(999),
                                  child: LinearProgressIndicator(
                                    value: ratio,
                                    minHeight: 7,
                                    backgroundColor: AppColors.background,
                                    valueColor: const AlwaysStoppedAnimation<Color>(
                                      AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (isLoggedIn)
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Viết đánh giá',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildStarPicker(),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _detailsController,
                      maxLines: 4,
                      onChanged: _onDetailsChanged,
                      decoration: InputDecoration(
                        hintText: 'Chia sẻ trải nghiệm của bạn để chúng tôi cải thiện tốt hơn...',
                        hintStyle: const TextStyle(color: AppColors.textSecondary),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primary.withOpacity(0.8)),
                        ),
                        contentPadding: const EdgeInsets.all(14),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildSuggestedBox(),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _onSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.cardBackground,
                          disabledBackgroundColor: AppColors.primary.withOpacity(0.35),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Gửi đánh giá',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              )
            else
              _card(
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.lock_outline,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Đăng nhập để viết đánh giá và giúp chúng tôi cải thiện chất lượng dịch vụ.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.3,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: () => Navigator.of(context).pushNamed('/login'),
                      child: const Text(
                        'Đăng nhập',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 14),
            Row(
              children: const [
                Text(
                  'Reviews',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (reviewState.isLoading && items.isEmpty)
              const SizedBox(
                height: 180,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              )
            else if (reviewState.errorMessage != null && items.isEmpty)
              _card(
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        reviewState.errorMessage!,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                    TextButton(
                      onPressed: () => ref.read(reviewProvider.notifier).loadAll(),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              )
            else ...items.map((r) => _ReviewItem(review: r)).toList(),
          ],
        ),
      ),
    );
  }
}

class _ReviewItem extends StatelessWidget {
  final ReviewResponse review;
  const _ReviewItem({required this.review});

  @override
  Widget build(BuildContext context) {
    final String name = review.customerName;
    final String initial = name.isNotEmpty ? name.characters.first : '?';
    final String dateText = review.day != null
        ? '${review.day!.day.toString().padLeft(2, '0')}/${review.day!.month.toString().padLeft(2, '0')}/${review.day!.year}'
        : '';
    final String footerText =
        (review.type != null && review.type!.isNotEmpty) ? review.type! : dateText;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: List.generate(5, (i) {
                        return Icon(
                          Icons.star,
                          size: 14,
                          color: i < review.star ? AppColors.warning : AppColors.iconUnselected,
                        );
                      }),
                    ),
                  ],
                ),
              ),
              Text(
                dateText,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.details,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          if (footerText.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              footerText,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}


