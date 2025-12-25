import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../dialog/login_required_dialog.dart';
import '../model/response/room_promotion_offer_response.dart';
import '../provider/auth_provider.dart';
import '../provider/room_provider.dart';
import '../screen/booking_request_screen.dart';
import '../utility/app_colors.dart';
import '../utility/custom_app_bar.dart';

class RoomPromotionDetailScreen extends ConsumerStatefulWidget {
  final RoomPromotionOfferResponse offer;

  const RoomPromotionDetailScreen({
    super.key,
    required this.offer,
  });

  @override
  ConsumerState<RoomPromotionDetailScreen> createState() =>
      _RoomPromotionDetailScreenState();
}

class _RoomPromotionDetailScreenState
    extends ConsumerState<RoomPromotionDetailScreen> {
  bool _isBooking = false;

  String _formatDate(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return '';
    final int t = s.indexOf('T');
    if (t > 0) return s.substring(0, t);
    if (s.length >= 10) return s.substring(0, 10);
    return s;
  }

  Future<void> _bookNow(BuildContext context) async {
    if (_isBooking) return;

    setState(() => _isBooking = true);
    try {
      final isLoggedIn = ref.read(authProvider).isLoggedIn;
      if (!isLoggedIn) {
        final bool? goLogin = await showDialog<bool>(
          context: context,
          barrierDismissible: true,
          builder: (_) => const LoginRequiredDialog(
            message:
                'Bạn cần đăng nhập để đặt phòng và áp dụng khuyến mãi. Vui lòng đăng nhập để tiếp tục.',
          ),
        );
        if (!mounted) return;
        if (goLogin == true) {
          Navigator.of(context).pushNamed('/login');
        }
        return;
      }

      // Ensure room types are loaded, then find the applied room type.
      var roomState = ref.read(roomProvider);
      if (!roomState.hasLoaded && !roomState.isLoading) {
        await ref.read(roomProvider.notifier).loadAllRoomTypes();
        roomState = ref.read(roomProvider);
      }

      final roomType = roomState.roomTypes.firstWhere(
        (r) => r.id == widget.offer.roomTypeId,
        orElse: () => throw StateError('ROOM_TYPE_NOT_FOUND'),
      );

      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BookingRequestScreen(roomType: roomType),
        ),
      );
    } on StateError catch (e) {
      if (!mounted) return;
      if (e.message == 'ROOM_TYPE_NOT_FOUND') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không tìm thấy loại phòng để áp dụng ưu đãi này.'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Có lỗi xảy ra: $e')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Có lỗi xảy ra: $e')),
      );
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Keep `roomProvider` alive while on this screen (it's autoDispose).
    ref.watch(roomProvider);

    final offer = widget.offer;
    final p = offer.promotion;
    final discountText =
        p.discount % 1 == 0 ? p.discount.toStringAsFixed(0) : p.discount.toStringAsFixed(1);

    final start = _formatDate(p.startTime);
    final end = _formatDate(p.endTime);
    final String timeText =
        (start.isNotEmpty || end.isNotEmpty) ? '$start - $end' : '';

    final String mappingDetails = offer.roomPromotionDetails.trim();
    final String promotionDetails = p.details.trim();

    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      appBar: const CustomAppBar(
        title: 'Chi tiết ưu đãi',
        showBackButton: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 130),
              children: [
                // Banner
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
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
                            size: 56,
                            color: AppColors.primary,
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.08),
                                Colors.black.withOpacity(0.55),
                              ],
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Row(
                              children: [
                                Container(
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
                                const SizedBox(width: 10),
                                Expanded(
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
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 16),

                Text(
                  p.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),

                if (timeText.trim().isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          timeText,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.18),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.local_offer_outlined,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Áp dụng cho: ${offer.roomTypeName}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                if (mappingDetails.isNotEmpty) ...[
                  const Text(
                    'Điều kiện áp dụng',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    mappingDetails,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 18),
                ],

                if (promotionDetails.isNotEmpty) ...[
                  const Text(
                    'Mô tả khuyến mãi',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    promotionDetails,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isBooking ? null : () => _bookNow(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.cardBackground,
                      disabledBackgroundColor: AppColors.primary.withOpacity(0.35),
                      disabledForegroundColor: AppColors.cardBackground.withOpacity(0.9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _isBooking ? 'Đang xử lý...' : 'Đặt phòng để áp dụng',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


