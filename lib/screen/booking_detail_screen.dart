import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/booking_bill_group.dart';
import '../model/response/booking_response.dart';
import '../provider/my_booking_provider.dart';
import '../utility/app_colors.dart';
import '../utility/app_date_utils.dart';
import '../utility/custom_app_bar.dart';
import '../utility/price_utils.dart';

class BookingDetailScreen extends ConsumerStatefulWidget {
  final BookingBillGroup group;

  const BookingDetailScreen({
    super.key,
    required this.group,
  });

  @override
  ConsumerState<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends ConsumerState<BookingDetailScreen> {
  bool _isCancelling = false;

  bool _isCancelledStatus(String status) {
    final s = status.toLowerCase().trim();
    return s == 'cancelled' ||
        s == 'canceled' ||
        s == 'cancel' ||
        s == 'đã hủy' ||
        s == 'hủy' ||
        s == 'da huy';
  }

  @override
  Widget build(BuildContext context) {
    final group = widget.group;
    final BookingResponse? first =
        group.bookings.isEmpty ? null : group.bookings.first;

    final services = _aggregateServices(group.bookings);

    final canCancel = group.bookings.isNotEmpty &&
        !_isCancelledStatus(group.paymentStatus) &&
        group.bookings.every((b) => b.actualCheckInTime == null);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Chi tiết hóa đơn #${group.billId}',
      ),
      bottomNavigationBar: canCancel
          ? SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isCancelling ? null : () => _onCancelPressed(group),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isCancelling
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Hủy đặt phòng (${group.bookings.length} phòng)',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                  ),
                ),
              ),
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            title: 'Thời gian theo từng phòng',
            children: [
              if (group.bookings.isEmpty)
                const Text(
                  'Không có phòng',
                  style: TextStyle(color: AppColors.textSecondary),
                )
              else
                ...group.bookings.map(_buildRoomTimeItem),
            ],
          ),
          const SizedBox(height: 12),
          _buildSection(
            title: 'Phòng',
            children: [
              if (group.bookings.isEmpty)
                const Text(
                  'Không có phòng',
                  style: TextStyle(color: AppColors.textSecondary),
                )
              else
                ...group.bookings.map(
                  (b) => Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.border, width: 1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Phòng ${b.roomNumber} • ${b.roomType}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Giá/đêm',
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                            ),
                            Text(
                              PriceUtils.formatVnd(b.roomPrice),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSection(
            title: 'Khách hàng',
            children: [
              _buildRow('Tên', group.customerName),
              _buildRow('SĐT', group.customerPhone),
            ],
          ),
          const SizedBox(height: 12),
          _buildSection(
            title: 'Thanh toán',
            children: [
              _buildRow('Mã hoá đơn', group.billId.toString()),
              _buildRow('Trạng thái', group.paymentStatus),
              if (group.promotionName != null &&
                  group.promotionName!.trim().isNotEmpty)
                _buildRow('Khuyến mãi', group.promotionName!),
              if (group.discount != null) _buildRow('Giảm giá', '${group.discount}%'),
              _buildRow('Tổng tiền', PriceUtils.formatVnd(group.totalMoney)),
              if (first?.employeeName != null && first!.employeeName!.trim().isNotEmpty)
                _buildRow('Nhân viên', first.employeeName!),
            ],
          ),
          const SizedBox(height: 12),
          _buildSection(
            title: 'Dịch vụ',
            children: [
              if (services.isEmpty)
                const Text(
                  'Không có dịch vụ',
                  style: TextStyle(color: AppColors.textSecondary),
                )
              else
                ...services.map(
                  (s) => Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.border, width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            s.serviceName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          'x${s.quantity}',
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          PriceUtils.formatVnd(s.total),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _onCancelPressed(BookingBillGroup group) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hủy đặt phòng'),
          content: Text(
            'Bạn có chắc muốn hủy hóa đơn #${group.billId}?\n'
            'Thao tác này sẽ hủy tất cả phòng trong hóa đơn.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Không'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Hủy hóa đơn'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() {
      _isCancelling = true;
    });

    final res = await ref.read(myBookingProvider.notifier).cancelBill(group);

    if (!mounted) return;

    setState(() {
      _isCancelling = false;
    });

    final ok = res['success'] == true;
    final msg = (res['message'] as String?)?.trim();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg?.isNotEmpty == true ? msg! : (ok ? 'Thành công' : 'Thất bại')),
        backgroundColor: ok ? AppColors.primary : AppColors.error,
      ),
    );

    if (ok) {
      Navigator.of(context).pop();
    }
  }

  List<BookingServiceInfo> _aggregateServices(List<BookingResponse> bookings) {
    final Map<String, _Agg> map = {};
    for (final b in bookings) {
      for (final s in b.services) {
        final key = '${s.serviceName}::${s.price}';
        final current = map[key];
        if (current == null) {
          map[key] = _Agg(
            serviceName: s.serviceName,
            price: s.price,
            quantity: s.quantity,
          );
        } else {
          map[key] = current.copyWith(quantity: current.quantity + s.quantity);
        }
      }
    }

    final result = map.values
        .map(
          (a) => BookingServiceInfo(
            serviceName: a.serviceName,
            quantity: a.quantity,
            price: a.price,
            total: a.price * a.quantity,
          ),
        )
        .toList();

    result.sort((a, b) => a.serviceName.compareTo(b.serviceName));
    return result;
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomTimeItem(BookingResponse b) {
    final plannedRange =
        '${AppDateUtils.formatDmy(b.contractCheckInTime)} - ${AppDateUtils.formatDmy(b.contractCheckOutTime)}';

    final actualIn = b.actualCheckInTime == null
        ? 'Chưa nhận phòng'
        : AppDateUtils.formatDmy(b.actualCheckInTime!);
    final actualOut = b.actualCheckOutTime == null
        ? 'Chưa trả phòng'
        : AppDateUtils.formatDmy(b.actualCheckOutTime!);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phòng ${b.roomNumber} • ${b.roomType}',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          _buildRow('Dự kiến', plannedRange),
          _buildRow('Nhận phòng', actualIn),
          _buildRow('Trả phòng', actualOut),
        ],
      ),
    );
  }
}

class _Agg {
  final String serviceName;
  final int quantity;
  final double price;

  const _Agg({
    required this.serviceName,
    required this.quantity,
    required this.price,
  });

  _Agg copyWith({int? quantity}) {
    return _Agg(
      serviceName: serviceName,
      quantity: quantity ?? this.quantity,
      price: price,
    );
  }
}


