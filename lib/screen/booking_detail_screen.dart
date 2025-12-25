import 'package:flutter/material.dart';
import '../model/booking_bill_group.dart';
import '../model/response/booking_response.dart';
import '../utility/app_colors.dart';
import '../utility/app_date_utils.dart';
import '../utility/custom_app_bar.dart';
import '../utility/price_utils.dart';

class BookingDetailScreen extends StatelessWidget {
  final BookingBillGroup group;

  const BookingDetailScreen({
    super.key,
    required this.group,
  });

  @override
  Widget build(BuildContext context) {
    final BookingResponse? first = group.bookings.isEmpty ? null : group.bookings.first;

    final services = _aggregateServices(group.bookings);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Chi tiết hóa đơn #${group.billId}',
      ),
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


