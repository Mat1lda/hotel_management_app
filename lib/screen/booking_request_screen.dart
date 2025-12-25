import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../dialog/available_room_picker_sheet.dart';
import '../model/response/room_type_response.dart';
import '../model/selected_room_result.dart';
import '../provider/booking_request_provider.dart';
import '../screen/checkout_screen.dart';
import '../utility/app_colors.dart';
import '../utility/app_date_utils.dart';
import '../utility/custom_app_bar.dart';
import '../utility/price_utils.dart';

class BookingRequestScreen extends ConsumerWidget {
  final RoomTypeResponse roomType;

  const BookingRequestScreen({
    super.key,
    required this.roomType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookingRequestProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final current = ref.read(bookingRequestProvider);
      if (!current.initialized) {
        ref.read(bookingRequestProvider.notifier).initialize(
              roomType: roomType,
            );
      }
    });

    final rooms = state.selection?.rooms ?? const [];
    final promotion = state.selection?.promotion;
    final DateTime checkIn = state.checkIn ?? DateTime.now();
    final DateTime checkOut = state.checkOut ?? checkIn.add(const Duration(days: 1));

    Future<void> pickCheckIn() async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: checkIn,
        firstDate: DateTime.now().subtract(const Duration(days: 0)),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppColors.primary,
                onPrimary: AppColors.cardBackground,
                onSurface: AppColors.textPrimary,
              ),
            ),
            child: child!,
          );
        },
      );
      if (picked == null) return;
      ref.read(bookingRequestProvider.notifier).setCheckIn(picked);
    }

    Future<void> pickCheckOut() async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: checkOut,
        firstDate: checkIn.add(const Duration(days: 1)),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppColors.primary,
                onPrimary: AppColors.cardBackground,
                onSurface: AppColors.textPrimary,
              ),
            ),
            child: child!,
          );
        },
      );
      if (picked == null) return;
      ref.read(bookingRequestProvider.notifier).setCheckOut(picked);
    }

    Future<void> pickRooms() async {
      final SelectedRoomResult? selected =
          await showModalBottomSheet<SelectedRoomResult>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) {
          return AvailableRoomPickerSheet(
            roomTypeId: roomType.id,
            checkIn: checkIn,
            checkOut: checkOut,
          );
        },
      );
      if (!context.mounted || selected == null) return;
      ref.read(bookingRequestProvider.notifier).setSelection(selected);
    }

    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      appBar: const CustomAppBar(
        title: 'Yêu cầu đặt phòng',
        showBackButton: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
              children: [
                _SectionTitle(title: 'Ngày'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _DateCard(
                        label: 'Nhận phòng',
                        value: AppDateUtils.formatDmy(checkIn),
                        onTap: pickCheckIn,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DateCard(
                        label: 'Trả phòng',
                        value: AppDateUtils.formatDmy(checkOut),
                        onTap: pickCheckOut,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _SectionTitle(title: 'Phòng đã chọn'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.textSecondary.withOpacity(0.18),
                    ),
                    color: AppColors.cardBackground,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${state.roomType?.name ?? roomType.name} • ${state.roomCount} phòng • ${state.nights} đêm',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (rooms.isEmpty)
                        const Text(
                          'Chưa chọn phòng. Vui lòng chọn ngày nhận/trả phòng trước, sau đó chọn phòng trống.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            height: 1.3,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: rooms
                              .map(
                                (r) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.textSecondary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    'Phòng ${r.roomNumber}',
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      if (promotion != null) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.18),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.local_offer_outlined,
                                size: 20,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '${promotion.name} (-${promotion.discount % 1 == 0 ? promotion.discount.toStringAsFixed(0) : promotion.discount.toStringAsFixed(1)}%)',
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
                      ],
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          onPressed: pickRooms,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: BorderSide(
                              color: AppColors.primary.withOpacity(0.35),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            rooms.isEmpty ? 'Chọn phòng trống' : 'Đổi phòng',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _SectionTitle(title: 'Chi tiết thanh toán'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.textSecondary.withOpacity(0.18),
                    ),
                    color: AppColors.cardBackground,
                  ),
                  child: Column(
                    children: [
                      _LineItem(
                        label: 'Tổng: ${state.nights} đêm',
                        value: PriceUtils.formatVnd(state.roomCost),
                      ),
                      if (state.discountAmount > 0) ...[
                        const SizedBox(height: 12),
                        _LineItem(
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
                      _LineItem(
                        label: 'Tổng thanh toán',
                        value: PriceUtils.formatVnd(state.total),
                        bold: true,
                      ),
                    ],
                  ),
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
                    onPressed: state.roomCount <= 0
                        ? null
                        : () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CheckoutScreen(
                                  roomType: roomType,
                                ),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.cardBackground,
                      disabledBackgroundColor:
                          AppColors.primary.withOpacity(0.35),
                      disabledForegroundColor:
                          AppColors.cardBackground.withOpacity(0.9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Gửi yêu cầu đặt phòng',
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

class _DateCard extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateCard({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardBackground,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
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
                  color: AppColors.textSecondary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.calendar_today_outlined,
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
          ),
        ),
      ),
    );
  }
}

class _LineItem extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  const _LineItem({
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
      color: valueColor ?? (bold ? AppColors.textPrimary : AppColors.textPrimary),
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


