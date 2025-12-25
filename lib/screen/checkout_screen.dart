import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/response/room_type_response.dart';
import '../provider/auth_provider.dart';
import '../provider/booking_request_provider.dart';
import '../provider/checkout_booking_provider.dart';
import '../provider/search_provider.dart';
import '../screen/booking_success_screen.dart';
import '../utility/app_colors.dart';
import '../utility/app_date_utils.dart';
import '../utility/custom_app_bar.dart';
import '../utility/image_utils.dart';
import '../utility/price_utils.dart';

class CheckoutScreen extends ConsumerWidget {
  final RoomTypeResponse roomType;

  const CheckoutScreen({
    super.key,
    required this.roomType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookingRequestProvider);
    final authState = ref.watch(authProvider);
    final checkoutState = ref.watch(checkoutBookingProvider);
    final searchState = ref.watch(searchProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final current = ref.read(bookingRequestProvider);
      if (!current.initialized) {
        ref.read(bookingRequestProvider.notifier).initialize(
              roomType: roomType,
            );
      }
    });

    ref.listen<CheckoutBookingState>(checkoutBookingProvider, (prev, next) {
      if (prev?.errorMessage != next.errorMessage && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.primary,
          ),
        );
      }

      if (prev?.success != true && next.success) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const BookingSuccessScreen()),
          (route) => false,
        );
      }
    });

    final displayedRoom = state.roomType ?? roomType;
    final displayedSelection = state.selection;
    final DateTime checkIn = state.checkIn ?? DateTime.now();
    final DateTime checkOut = state.checkOut ?? checkIn.add(const Duration(days: 1));

    final int rooms = state.roomCount;
    final int guests =
        (searchState.guests > 0) ? searchState.guests : displayedRoom.maxOccupancy;
    final String phone =
        authState.user?.phone.isNotEmpty == true ? authState.user!.phone : '—';
    final String location = (searchState.selectedLocation.isNotEmpty)
        ? searchState.selectedLocation
        : (authState.user?.address.isNotEmpty == true ? authState.user!.address : '—');

    final String imageUrl =
        ImageUtils.getRoomImage(displayedRoom.images, displayedRoom.id);

    final double grandTotal = state.total;
    final bool canPay = displayedSelection != null && displayedSelection.rooms.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Thanh toán',
        showBackButton: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
              children: [
                _HotelHeaderCard(
                  imageUrl: imageUrl,
                  title: displayedRoom.name,
                  location: location,
                  rating: 4.7,
                  pricePerNight: PriceUtils.formatVnd(displayedRoom.price),
                ),
                const SizedBox(height: 16),
                const _SectionTitle(title: 'Thông tin đặt phòng'),
                const SizedBox(height: 12),
                _InfoCard(
                  children: [
                    _InfoRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Ngày',
                      value:
                          '${AppDateUtils.formatDmy(checkIn)} - ${AppDateUtils.formatDmy(checkOut)}',
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.people_outline,
                      label: 'Khách',
                      value: '$guests khách ($rooms phòng)',
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.bed_outlined,
                      label: 'Loại phòng',
                      value: displayedRoom.name,
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.phone_outlined,
                      label: 'Số điện thoại',
                      value: phone,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const _SectionTitle(title: 'Chi tiết giá'),
                const SizedBox(height: 12),
                _InfoCard(
                  children: [
                    _PriceRow(
                      label: 'Tiền phòng (${state.nights} đêm)',
                      value: PriceUtils.formatVnd(state.roomCost),
                    ),
                    if (state.discountAmount > 0) ...[
                      const SizedBox(height: 10),
                      _PriceRow(
                        label: 'Giảm giá',
                        value: '- ${PriceUtils.formatVnd(state.discountAmount)}',
                        valueColor: AppColors.success,
                      ),
                    ],
                    const SizedBox(height: 14),
                    Container(
                      height: 1,
                      color: AppColors.textSecondary.withOpacity(0.14),
                    ),
                    const SizedBox(height: 14),
                    _PriceRow(
                      label: 'Tổng thanh toán',
                      value: PriceUtils.formatVnd(grandTotal),
                      bold: true,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const _SectionTitle(title: 'Ưu đãi'),
                const SizedBox(height: 12),
                _PromoCard(
                  promoName: displayedSelection?.promotion?.name,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Chức năng chọn ưu đãi sẽ được cập nhật sớm.'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
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
                  height: 56,
                  child: ElevatedButton(
                    onPressed: checkoutState.isSubmitting || !canPay
                        ? null
                        : () async {
                            await ref
                                .read(checkoutBookingProvider.notifier)
                                .submit(
                                  bookingState: ref.read(bookingRequestProvider),
                                  selection: displayedSelection!,
                                  user: authState.user,
                                );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.cardBackground,
                      disabledBackgroundColor: AppColors.primary.withOpacity(0.35),
                      disabledForegroundColor:
                          AppColors.cardBackground.withOpacity(0.9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: checkoutState.isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.cardBackground,
                              ),
                            ),
                          )
                        : Text(
                            'Thanh toán • ${PriceUtils.formatVnd(grandTotal)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
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

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _HotelHeaderCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String location;
  final double rating;
  final String pricePerNight;

  const _HotelHeaderCard({
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.rating,
    required this.pricePerNight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 16,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: pricePerNight,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                      const TextSpan(
                        text: ' / đêm',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;

  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.textSecondary.withOpacity(0.18),
        ),
        color: AppColors.cardBackground,
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.textSecondary.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 18,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  const _PriceRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle labelStyle = TextStyle(
      color: bold ? AppColors.textPrimary : AppColors.textSecondary,
      fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
      fontSize: bold ? 15 : 14,
    );
    final TextStyle valueStyle = TextStyle(
      color: valueColor ?? AppColors.textPrimary,
      fontWeight: bold ? FontWeight.w900 : FontWeight.w800,
      fontSize: bold ? 18 : 14,
    );

    return Row(
      children: [
        Expanded(child: Text(label, style: labelStyle)),
        const SizedBox(width: 10),
        Text(value, style: valueStyle),
      ],
    );
  }
}

class _PromoCard extends StatelessWidget {
  final String? promoName;
  final VoidCallback onTap;

  const _PromoCard({
    required this.promoName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardBackground,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.textSecondary.withOpacity(0.18),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.local_offer_outlined,
                size: 20,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                promoName?.isNotEmpty == true ? promoName! : 'Chọn ưu đãi',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

