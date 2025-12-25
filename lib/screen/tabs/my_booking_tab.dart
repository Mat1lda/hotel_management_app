import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utility/app_colors.dart';
import '../../utility/app_date_utils.dart';
import '../../utility/custom_app_bar.dart';
import '../../utility/navigation_utils.dart';
import '../../utility/price_utils.dart';
import '../../utility/search_header.dart';
import '../../provider/auth_provider.dart';
import '../../provider/my_booking_provider.dart';
import '../../model/booking_model.dart';
import '../../model/booking_bill_group.dart';

class MyBookingTab extends ConsumerWidget {
  const MyBookingTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isLoggedIn = authState.isLoggedIn;

    if (!isLoggedIn) {
      return _buildNotLoggedInView(context);
    }

    final user = authState.user;
    final token = user?.token;
    if (user == null || token == null || token.isEmpty) {
      return _buildNotLoggedInView(context);
    }

    // Initialize booking data if not already done (or user changed)
    final bookingState = ref.watch(myBookingProvider);
    if (!bookingState.initialized || bookingState.userId != user.id) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(myBookingProvider.notifier).initialize(
              userId: user.id,
              token: token,
            );
      });
    }

    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      appBar: CustomAppBar(
        title: 'Đặt phòng của tôi',
        showBackButton: false,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.more_horiz,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          SearchHeader(
            hintText: 'Tìm kiếm...',
            margin: const EdgeInsets.all(16),
            onChanged: (value) {
              // Handle search for bookings
            },
            onFilterPressed: () {
              // Handle filter for bookings
            },
          ),
          _buildTabBar(context, ref, bookingState),
          Expanded(
            child: _buildBookingList(context, ref, bookingState),
          ),
        ],
      ),
    );
  }

  Widget _buildNotLoggedInView(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Main content - centered
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 48),
                  Text(
                    'Đăng nhập để xem tất cả kỳ nghỉ của bạn',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Đăng nhập',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/register');
                    },
                    child: Text(
                      'Tham gia',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Fixed text at bottom
            Container(
              padding: const EdgeInsets.only(bottom: 16, left: 32, right: 32),
              child: Column(
                children: [
                  Text(
                    'Tìm kiếm đặt phòng cụ thể?',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Tìm kỳ nghỉ của bạn',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildTabBar(BuildContext context, WidgetRef ref, MyBookingState bookingState) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                ref.read(myBookingProvider.notifier).setSelectedTab(BookingStatus.booked);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: bookingState.selectedTab == BookingStatus.booked
                          ? AppColors.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  'Đã đặt',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: bookingState.selectedTab == BookingStatus.booked
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                ref.read(myBookingProvider.notifier).setSelectedTab(BookingStatus.history);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: bookingState.selectedTab == BookingStatus.history
                          ? AppColors.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  'Lịch sử',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: bookingState.selectedTab == BookingStatus.history
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingList(
    BuildContext context,
    WidgetRef ref,
    MyBookingState bookingState,
  ) {
    final bookings = bookingState.selectedTab == BookingStatus.booked
        ? bookingState.bookedBookings
        : bookingState.historyBookings;

    if (bookingState.isLoading && bookings.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (bookingState.errorMessage != null && bookings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 56, color: AppColors.error),
              const SizedBox(height: 12),
              Text(
                bookingState.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: () => ref.read(myBookingProvider.notifier).refresh(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Thử lại'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hotel_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              bookingState.selectedTab == BookingStatus.booked
                  ? 'Chưa có đặt phòng nào'
                  : 'Chưa có lịch sử đặt phòng',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(myBookingProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return _buildBookingCard(context, booking);
        },
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, BookingBillGroup group) {
    final dateRange =
        '${AppDateUtils.formatDmy(group.contractCheckInTime)} - ${AppDateUtils.formatDmy(group.contractCheckOutTime)}';

    final roomNumbers = group.bookings.map((b) => b.roomNumber).toList()..sort();
    final roomsText =
        roomNumbers.isEmpty ? '—' : roomNumbers.map((e) => e.toString()).join(', ');

    final roomTypes = group.bookings.map((b) => b.roomType).toSet().toList();
    final roomTypeText = roomTypes.isEmpty
        ? ''
        : (roomTypes.length == 1 ? roomTypes.first : 'Nhiều loại phòng');

    return InkWell(
      onTap: () => NavigationUtils.openBookingDetail(context, group),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Hóa đơn #${group.billId}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                _buildStatusChip(group.paymentStatus),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.meeting_room_outlined,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    group.bookings.length <= 1
                        ? 'Phòng $roomsText • $roomTypeText'
                        : '${group.bookings.length} phòng ($roomsText) • $roomTypeText',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    dateRange,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.payments_outlined,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    PriceUtils.formatVnd(group.totalMoney),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final normalized = status.toLowerCase().trim();
    final Color bg;
    final Color fg;

    if (normalized == 'paid') {
      bg = AppColors.success.withOpacity(0.12);
      fg = AppColors.success;
    } else if (normalized == 'pending') {
      bg = AppColors.warning.withOpacity(0.12);
      fg = AppColors.warning;
    } else {
      bg = AppColors.border.withOpacity(0.6);
      fg = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
