import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/response/service_category_response.dart';
import '../model/response/service_response.dart';
import '../service/service_service.dart';

class ServiceState {
  final List<ServiceResponse> freeServices;
  final List<ServiceCategoryResponse> categories;
  final bool isLoading;
  final String? errorMessage;
  final bool hasLoaded;

  const ServiceState({
    this.freeServices = const [],
    this.categories = const [],
    this.isLoading = false,
    this.errorMessage,
    this.hasLoaded = false,
  });

  ServiceState copyWith({
    List<ServiceResponse>? freeServices,
    List<ServiceCategoryResponse>? categories,
    bool? isLoading,
    String? errorMessage,
    bool? hasLoaded,
  }) {
    return ServiceState(
      freeServices: freeServices ?? this.freeServices,
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      hasLoaded: hasLoaded ?? this.hasLoaded,
    );
  }
}

class ServiceNotifier extends Notifier<ServiceState> {
  late final HotelServiceService _service;

  @override
  ServiceState build() {
    _service = HotelServiceService();
    return const ServiceState();
  }

  Future<void> loadFreeServices() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await _service.getAllServices();
      if (result['success'] == true) {
        final List<ServiceResponse> all =
            result['data'] as List<ServiceResponse>;
        final List<ServiceResponse> free =
            all.where((s) => (s.price).toDouble() == 0.0).toList();

        final Map<int, ServiceCategoryResponse> catMap = {};
        for (final s in free) {
          if (!catMap.containsKey(s.categoryId)) {
            catMap[s.categoryId] = ServiceCategoryResponse(
              id: s.categoryId,
              name: s.categoryName,
              details: '',
            );
          }
        }
        final List<ServiceCategoryResponse> categories =
            catMap.values.toList();

        state = state.copyWith(
          freeServices: free,
          categories: categories,
          isLoading: false,
          hasLoaded: true,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: result['message'] as String,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Có lỗi không xác định xảy ra: $e',
      );
    }
  }

  List<ServiceResponse> filterByCategoryKey(String key) {
    if (key == 'all') return state.freeServices;
    final int? categoryId = int.tryParse(key);
    if (categoryId == null) return state.freeServices;
    return state.freeServices
        .where((s) => s.categoryId == categoryId)
        .toList();
  }
}

final serviceProvider =
    NotifierProvider.autoDispose<ServiceNotifier, ServiceState>(() {
  return ServiceNotifier();
});

final freeServicesProvider = Provider<List<ServiceResponse>>((ref) {
  return ref.watch(serviceProvider).freeServices;
});

final serviceCategoriesProvider =
    Provider<List<ServiceCategoryResponse>>((ref) {
  return ref.watch(serviceProvider).categories;
});

final serviceLoadingProvider = Provider<bool>((ref) {
  return ref.watch(serviceProvider).isLoading;
});

final serviceErrorProvider = Provider<String?>((ref) {
  return ref.watch(serviceProvider).errorMessage;
});


