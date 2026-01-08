import 'package:flutter/material.dart';

import '../utility/app_colors.dart';
import '../utility/custom_app_bar.dart';

class PolicyScreen extends StatelessWidget {
  const PolicyScreen({super.key});

  Widget _section({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '•  ',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Chính sách',
        showBackButton: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          children: [
            const Text(
              'CHÍNH SÁCH DÀNH CHO KHÁCH HÀNG',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),
            _section(
              title: '1. Phạm vi áp dụng',
              children: const [
                Text(
                  'Chính sách này áp dụng cho tất cả khách hàng sử dụng website và ứng dụng di động của hệ thống quản lý khách sạn để thực hiện việc đặt phòng và sử dụng dịch vụ lưu trú.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _section(
              title: '2. Chính sách check-in',
              children: [
                _bullet('Khách hàng không được phép check-in sớm hơn thời gian quy định của khách sạn.'),
                _bullet(
                  'Trường hợp khách hàng check-in muộn so với thời gian đã đăng ký mà không thông báo trước, nhân viên khách sạn có quyền hủy phòng nhằm đảm bảo khả năng phục vụ cho khách hàng khác.',
                ),
              ],
            ),
            const SizedBox(height: 12),
            _section(
              title: '3. Chính sách check-out',
              children: [
                _bullet('Khách hàng phải check-out đúng thời gian quy định của khách sạn.'),
                _bullet('Trường hợp khách hàng check-out muộn, hệ thống sẽ áp dụng mức phạt 10% trên tổng hóa đơn của kỳ lưu trú.'),
              ],
            ),
            const SizedBox(height: 12),
            _section(
              title: '4. Chính sách hủy phòng và đánh dấu vi phạm',
              children: [
                _bullet('Nếu khách hàng hủy phòng trong vòng 3 ngày trước ngày check-in, hệ thống sẽ ghi nhận 1 lần vi phạm vào tài khoản khách hàng.'),
                _bullet('Khi khách hàng bị ghi nhận 03 lần vi phạm, tài khoản khách hàng sẽ bị khóa chức năng đặt phòng trên ứng dụng khách hàng.'),
                _bullet('Trong thời gian bị hạn chế, khách hàng vẫn có thể đăng nhập để xem thông tin nhưng không thể thực hiện đặt phòng mới.'),
              ],
            ),
            const SizedBox(height: 12),
            _section(
              title: '5. Hiệu lực chính sách',
              children: const [
                Text(
                  'Chính sách này có hiệu lực kể từ thời điểm được công bố trên hệ thống và áp dụng cho tất cả các giao dịch đặt phòng của khách hàng.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


