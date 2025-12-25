import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/response/room_promotion_offer_response.dart';
import '../provider/room_promotion_offer_provider.dart';
import '../screen/room_promotion_detail_screen.dart';
import '../utility/app_colors.dart';
import '../utility/custom_app_bar.dart';

class RoomPromotionListScreen extends ConsumerWidget {
  const RoomPromotionListScreen({super.key});

  String _formatDate(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return '';
    final int t = s.indexOf('T');
    if (t > 0) return s.substring(0, t);
    if (s.length >= 10) return s.substring(0, 10);
    return s;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(roomPromotionOfferProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final current = ref.read(roomPromotionOfferProvider);
      if (!current.hasLoaded && !current.isLoading) {
        ref.read(roomPromotionOfferProvider.notifier).load();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      appBar: const CustomAppBar(
        title: 'Ưu đãi',
        showBackButton: true,
      ),
      body: SafeArea(
        child: Builder(
          builder: (_) {
            if (state.isLoading && state.offers.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              );
            }

            if (state.errorMessage != null && state.offers.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 54, color: AppColors.error),
                    const SizedBox(height: 12),
                    Text(
                      state.errorMessage ?? 'Có lỗi xảy ra',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () =>
                            ref.read(roomPromotionOfferProvider.notifier).load(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(color: AppColors.primary.withOpacity(0.35)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Thử lại',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state.offers.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Hiện chưa có ưu đãi nào.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => ref.read(roomPromotionOfferProvider.notifier).load(),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                itemCount: state.offers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final RoomPromotionOfferResponse offer = state.offers[index];
                  final p = offer.promotion;
                  final discountText = p.discount % 1 == 0
                      ? p.discount.toStringAsFixed(0)
                      : p.discount.toStringAsFixed(1);

                  final start = _formatDate(p.startTime);
                  final end = _formatDate(p.endTime);
                  final timeText =
                      (start.isNotEmpty || end.isNotEmpty) ? '$start - $end' : '';

                  final desc = (offer.roomPromotionDetails.trim().isNotEmpty)
                      ? offer.roomPromotionDetails.trim()
                      : p.details.trim();

                  return InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => RoomPromotionDetailScreen(offer: offer),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                          ),
                        ],
                        border: Border.all(
                          color: AppColors.textSecondary.withOpacity(0.10),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Banner
                          Stack(
                            children: [
                              Container(
                                height: 170,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                  color: AppColors.textSecondary.withOpacity(0.08),
                                  image: p.banner.trim().isEmpty
                                      ? null
                                      : DecorationImage(
                                          image: NetworkImage(p.banner),
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                child: p.banner.trim().isEmpty
                                    ? const Center(
                                        child: Icon(
                                          Icons.local_offer_outlined,
                                          size: 46,
                                          color: AppColors.primary,
                                        ),
                                      )
                                    : null,
                              ),
                              Positioned(
                                left: 12,
                                top: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.cardBackground.withOpacity(0.92),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    '-$discountText%',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 12,
                                top: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.cardBackground.withOpacity(0.92),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    offer.roomTypeName,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                if (desc.isNotEmpty)
                                  Text(
                                    desc,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      height: 1.3,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                if (timeText.trim().isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time,
                                        size: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          timeText,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(0.10),
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                        child: const Text(
                                          'Xem',
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}


