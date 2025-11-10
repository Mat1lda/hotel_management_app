import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/response/room_type_response.dart';
import '../utility/app_colors.dart';
import '../utility/image_utils.dart';
import '../provider/room_detail_provider.dart';
import '../utility/custom_app_bar.dart';

class RoomDetailScreen extends ConsumerStatefulWidget {
  final RoomTypeResponse room;
  const RoomDetailScreen({super.key, required this.room});

  @override
  ConsumerState<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends ConsumerState<RoomDetailScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detailState = ref.watch(roomDetailProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final current = ref.read(roomDetailProvider).room;
      if (current == null || current.id != widget.room.id) {
        ref.read(roomDetailProvider.notifier).setRoom(widget.room);
      }
    });
    final displayed = detailState.room ?? widget.room;
    final imageUrls = ImageUtils.getRoomImages(displayed.images, displayed.id);
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        title: 'Chi tiết',
        showBackButton: false,
        backgroundColor: Colors.transparent,
        titleColor: AppColors.cardBackground,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: _roundIcon(
            context,
            icon: Icons.arrow_back,
            onTap: () => Navigator.of(context).maybePop(),
          ),
        ),
        actions: [
          // Padding(
          //   padding: const EdgeInsets.only(right: 16),
          //   child: _roundIcon(
          //     context,
          //     icon: Icons.share,
          //     onTap: () {},
          //   ),
          // ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header image
                Stack(
                  children: [
                    SizedBox(
                      height: 280,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: imageUrls.length,
                        onPageChanged: (i) => setState(() => _currentPage = i),
                        itemBuilder: (context, index) {
                          final url = imageUrls[index];
                          return Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(url),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    IgnorePointer(
                      ignoring: true,
                      child: Container(
                        height: 280,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.15),
                              Colors.black.withOpacity(0.55),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 30,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(imageUrls.length, (i) {
                          final bool active = i == _currentPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            height: 8,
                            width: active ? 18 : 8,
                            decoration: BoxDecoration(
                              color: active
                                  ? AppColors.cardBackground
                                  : AppColors.cardBackground.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
                // Body card
                Container(
                  transform: Matrix4.translationValues(0, -20, 0),
                  decoration: const BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayed.name,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                ],
                              ),
                            ),
                            _roundIcon(
                              context,
                              icon: Icons.favorite_border,
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                      // Quick facts
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Row(
                          children: [
                            _quickFact(
                              icon: Icons.bed,
                              label: '${displayed.bedCount} giường',
                            ),
                            const SizedBox(width: 12),
                            _quickFact(
                              icon: Icons.people,
                              label: 'Tối đa ${displayed.maxOccupancy} khách',
                            ),
                            const SizedBox(width: 12),
                            _quickFact(
                              icon: Icons.square_foot,
                              label: displayed.formattedArea,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Facilities
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'Tiện nghi phổ biến',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: _FacilitiesGrid(room: displayed),
                      ),
                      const SizedBox(height: 12),
                      // Description
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                        child: Text(
                          'Mô tả',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          displayed.details.isNotEmpty
                              ? displayed.details
                              : 'Phòng rộng rãi, thiết kế sang trọng và tiện nghi đầy đủ cho kỳ nghỉ thư thái.',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            height: 1.4,
                            fontSize: 16
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Bottom bar
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
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Giá',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          displayed.formattedPrice,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.cardBackground,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Đặt ngay',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _roundIcon(BuildContext context, {required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.cardBackground.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }

  static Widget _quickFact({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border.all(color: AppColors.textSecondary.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _FacilitiesGrid extends StatelessWidget {
  final RoomTypeResponse room;
  const _FacilitiesGrid({required this.room});

  @override
  Widget build(BuildContext context) {
    final items = <_FacilityItem>[
      _FacilityItem('Phòng tắm riêng', Icons.bathtub, room.isPrivateBathroom),
      _FacilityItem('Đồ vệ sinh', Icons.clean_hands, room.isFreeToiletries),
      _FacilityItem('Điều hòa', Icons.ac_unit, room.isAirConditioning),
      _FacilityItem('Cách âm', Icons.volume_off, room.isSoundproofing),
      _FacilityItem('TV', Icons.tv, room.isTV),
      _FacilityItem('Mini Bar', Icons.local_bar, room.isMiniBar),
      _FacilityItem('Bàn làm việc', Icons.work, room.isWorkDesk),
      _FacilityItem('Khu vực ngồi', Icons.event_seat, room.isSeatingArea),
      _FacilityItem('An toàn', Icons.security, room.isSafetyFeatures),
      _FacilityItem(room.isSmoking ? 'Cho phép hút thuốc' : 'Không hút thuốc', room.isSmoking ? Icons.smoking_rooms : Icons.smoke_free, true),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.9,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final f = items[index];
        final bool enabled = f.enabled;
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: enabled ? AppColors.primary.withOpacity(0.1) : AppColors.textSecondary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                f.icon,
                size: 24,
                color: enabled ? AppColors.primary : AppColors.textSecondary.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              f.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FacilityItem {
  final String title;
  final IconData icon;
  final bool enabled;
  _FacilityItem(this.title, this.icon, this.enabled);
}


