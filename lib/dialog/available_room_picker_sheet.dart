import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/selected_room_result.dart';
import '../model/response/promotion_response.dart';
import '../model/response/room_response.dart';
import '../provider/available_room_provider.dart';
import '../provider/room_type_promotion_provider.dart';
import '../utility/app_colors.dart';
import '../utility/app_date_utils.dart';

class AvailableRoomPickerSheet extends ConsumerStatefulWidget {
  final int roomTypeId;
  final DateTime checkIn;
  final DateTime checkOut;

  const AvailableRoomPickerSheet({
    super.key,
    required this.roomTypeId,
    required this.checkIn,
    required this.checkOut,
  });

  @override
  ConsumerState<AvailableRoomPickerSheet> createState() =>
      _AvailableRoomPickerSheetState();
}

class _AvailableRoomPickerSheetState
    extends ConsumerState<AvailableRoomPickerSheet> {
  final Set<int> _selectedRoomIds = <int>{};
  int? _selectedRoomPromotionId;

  PromotionResponse? _getSelectedPromotion(List<PromotionResponse> promotions) {
    final int? id = _selectedRoomPromotionId;
    if (id == null) return null;
    for (final p in promotions) {
      if ((p.roomPromotionId ?? 0) == id) return p;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(availableRoomProvider);
    final promoState = ref.watch(roomTypePromotionProvider);
    final String checkInIso = AppDateUtils.formatIsoDate(widget.checkIn);
    final String checkOutIso = AppDateUtils.formatIsoDate(widget.checkOut);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final current = ref.read(availableRoomProvider);
      final shouldLoad = current.roomTypeId != widget.roomTypeId ||
          current.checkIn != checkInIso ||
          current.checkOut != checkOutIso ||
          (!current.hasLoaded && !current.isLoading);
      if (shouldLoad) {
        ref
            .read(availableRoomProvider.notifier)
            .loadAvailableRoomsByRoomType(
              roomTypeId: widget.roomTypeId,
              checkIn: widget.checkIn,
              checkOut: widget.checkOut,
            );
      }

      final promoCurrent = ref.read(roomTypePromotionProvider);
      final promoShouldLoad = promoCurrent.roomTypeId != widget.roomTypeId ||
          (!promoCurrent.hasLoaded && !promoCurrent.isLoading);
      if (promoShouldLoad) {
        ref
            .read(roomTypePromotionProvider.notifier)
            .loadActivePromotionsByRoomType(widget.roomTypeId);
      }
    });

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 42,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withOpacity(0.25),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Chọn phòng trống',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${AppDateUtils.formatDmy(widget.checkIn)} - ${AppDateUtils.formatDmy(widget.checkOut)}',
                        style: TextStyle(
                          color: AppColors.textSecondary.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          if (state.isLoading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else if (state.errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    state.errorMessage ?? 'Có lỗi xảy ra',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      onPressed: () {
                        ref
                            .read(availableRoomProvider.notifier)
                            .loadAvailableRoomsByRoomType(
                              roomTypeId: widget.roomTypeId,
                              checkIn: widget.checkIn,
                              checkOut: widget.checkOut,
                            );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(
                          color: AppColors.primary.withOpacity(0.35),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Thử lại',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (state.rooms.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 26),
              child: Text(
                'Hiện chưa có phòng trống cho loại phòng này trong khoảng ngày đã chọn.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.3,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                itemCount: state.rooms.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final room = state.rooms[index];
                  final selected = _selectedRoomIds.contains(room.id);
                  return _RoomTile(
                    room: room,
                    selected: selected,
                    onTap: () => setState(() {
                      if (selected) {
                        _selectedRoomIds.remove(room.id);
                      } else {
                        _selectedRoomIds.add(room.id);
                      }
                    }),
                  );
                },
              ),
            ),
          if (promoState.isLoading)
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 6, 20, 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Đang tải khuyến mãi...',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          else if (promoState.errorMessage != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      promoState.errorMessage ?? 'Có lỗi xảy ra',
                      style: const TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 36,
                    child: OutlinedButton(
                      onPressed: () {
                        ref
                            .read(roomTypePromotionProvider.notifier)
                            .loadActivePromotionsByRoomType(widget.roomTypeId);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(
                          color: AppColors.primary.withOpacity(0.35),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Thử lại',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (promoState.promotions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.textSecondary.withOpacity(0.18),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
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
                        const Expanded(
                          child: Text(
                            'Khuyến mãi áp dụng',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(
                          '${promoState.promotions.length}',
                          style: TextStyle(
                            color: AppColors.textSecondary.withOpacity(0.9),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: const Text('Không áp dụng'),
                              selected: _selectedRoomPromotionId == null,
                              onSelected: (_) =>
                                  setState(() => _selectedRoomPromotionId = null),
                              selectedColor: AppColors.primary.withOpacity(0.12),
                              backgroundColor: AppColors.cardBackground,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                              labelPadding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: _selectedRoomPromotionId == null
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                              shape: StadiumBorder(
                                side: BorderSide(
                                  color: (_selectedRoomPromotionId == null)
                                      ? AppColors.primary.withOpacity(0.35)
                                      : AppColors.textSecondary.withOpacity(0.2),
                                ),
                              ),
                            ),
                          ),
                          ...promoState.promotions.map((p) {
                            final int? roomPromotionId = p.roomPromotionId;
                            final bool selected = roomPromotionId != null &&
                                _selectedRoomPromotionId == roomPromotionId;
                            final String discountText = p.discount % 1 == 0
                                ? p.discount.toStringAsFixed(0)
                                : p.discount.toStringAsFixed(1);
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                selected: selected,
                                onSelected: roomPromotionId == null
                                    ? null
                                    : (_) => setState(() =>
                                        _selectedRoomPromotionId = roomPromotionId),
                                selectedColor:
                                    AppColors.primary.withOpacity(0.12),
                                backgroundColor: AppColors.cardBackground,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                                labelPadding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                label: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      p.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: selected
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? AppColors.primary.withOpacity(0.16)
                                            : AppColors.textSecondary
                                                .withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        '-$discountText%',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 12,
                                          color: selected
                                              ? AppColors.primary
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                shape: StadiumBorder(
                                  side: BorderSide(
                                    color: selected
                                        ? AppColors.primary.withOpacity(0.35)
                                        : AppColors.textSecondary.withOpacity(0.2),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    Builder(builder: (context) {
                      final PromotionResponse? selectedPromotion =
                          _getSelectedPromotion(promoState.promotions);
                      if (selectedPromotion == null) return const SizedBox();
                      if (selectedPromotion.details.trim().isEmpty) {
                        return const SizedBox();
                      }
                      return Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.18),
                          ),
                        ),
                        child: Text(
                          selectedPromotion.details,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            height: 1.3,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _selectedRoomIds.isEmpty
                          ? null
                          : () {
                              final List<RoomResponse> selectedRooms = state
                                  .rooms
                                  .where((r) => _selectedRoomIds.contains(r.id))
                                  .toList()
                                ..sort((a, b) =>
                                    a.roomNumber.compareTo(b.roomNumber));
                              Navigator.of(context).pop(
                                SelectedRoomResult(
                                  rooms: selectedRooms,
                                  promotion: _getSelectedPromotion(
                                    promoState.promotions,
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
                      child: const Text(
                        'Tiếp tục',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
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

class _RoomTile extends StatelessWidget {
  final RoomResponse room;
  final bool selected;
  final VoidCallback onTap;

  const _RoomTile({
    required this.room,
    required this.selected,
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? AppColors.primary.withOpacity(0.6)
                  : AppColors.textSecondary.withOpacity(0.18),
            ),
            color: selected
                ? AppColors.primary.withOpacity(0.06)
                : AppColors.cardBackground,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary.withOpacity(0.15)
                      : AppColors.textSecondary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  room.roomNumber.toString(),
                  style: TextStyle(
                    color: selected ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Phòng ${room.roomNumber}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? AppColors.primary
                        : AppColors.textSecondary.withOpacity(0.35),
                  ),
                ),
                child: selected
                    ? const Icon(
                        Icons.check,
                        size: 14,
                        color: AppColors.cardBackground,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


