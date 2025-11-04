import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utility/app_colors.dart';
import '../utility/custom_app_bar.dart';
import '../utility/search_header.dart';
import '../utility/image_utils.dart';
import '../provider/search_provider.dart';
import '../provider/room_provider.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  void _onHotelPressed(int roomId) {
    // TODO: Navigate to room detail screen
    debugPrint('Room pressed: $roomId');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchProvider);
    final roomState = ref.watch(roomProvider);
    
    // Load all rooms when first entering the screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!searchState.hasSearched && !roomState.isLoading) {
        ref.read(searchProvider.notifier).loadAllRooms();
      }
    });
    
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      appBar: CustomAppBar(
        title: 'Tìm Phòng',
        showBackButton: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.tune,
              color: AppColors.textPrimary,
              size: 24,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          SearchHeader(
            hintText: 'Tìm kiếm phòng...',
            onChanged: (value) {
              ref.read(searchProvider.notifier).setSearchQuery(value);
              if (value.isEmpty) {
                // Nếu search trống, hiển thị tất cả phòng
                ref.read(searchProvider.notifier).loadAllRooms();
              } else {
                // Nếu có text, thực hiện search
                ref.read(searchProvider.notifier).search();
              }
            },
            onFilterPressed: () {
              // Handle filter action
            },
          ),
          Expanded(
            child: _buildSearchResults(context, ref),
          ),
        ],
      ),
    );
  }




  Widget _buildSearchResults(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchProvider);
    final roomState = ref.watch(roomProvider);
    
    // Hiển thị loading khi đang tải dữ liệu
    if (searchState.isLoading || roomState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }
    
    // Hiển thị loading khi chưa có dữ liệu gì (lần đầu vào trang)
    if (!searchState.hasSearched && !roomState.hasLoaded) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }
    
    if (searchState.searchResults.isEmpty && searchState.hasSearched && !searchState.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy phòng nào',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Thử tìm kiếm với từ khóa khác',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: searchState.searchResults.length,
      itemBuilder: (context, index) {
        final room = searchState.searchResults[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () => _onHotelPressed(room.id),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Room image
                  Stack(
                    children: [
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          image: DecorationImage(
                            image: NetworkImage(
                              ImageUtils.getRoomImage(room.images, room.id)
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadow.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.favorite_border,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                '4.5',
                                style: TextStyle(
                                  fontSize: 12,
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
                  
                  // Room info
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          room.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          room.details,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.bed,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              room.bedInfo,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.people,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              room.guestInfo,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Amenities
                        if (room.amenities.isNotEmpty) ...[
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: room.amenities.take(3).map((amenity) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                amenity,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )).toList(),
                          ),
                          const SizedBox(height: 12),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: room.formattedPrice,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: ' Mỗi đêm',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
