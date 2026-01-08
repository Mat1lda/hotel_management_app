import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/response/location_response.dart';
import '../service/location_service.dart';

class LocationState {
  final List<LocationResponse> locations;
  final bool isLoading;
  final String? errorMessage;
  final bool hasLoaded;

  const LocationState({
    this.locations = const [],
    this.isLoading = false,
    this.errorMessage,
    this.hasLoaded = false,
  });

  LocationState copyWith({
    List<LocationResponse>? locations,
    bool? isLoading,
    String? errorMessage,
    bool? hasLoaded,
  }) {
    return LocationState(
      locations: locations ?? this.locations,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      hasLoaded: hasLoaded ?? this.hasLoaded,
    );
  }
}

class LocationNotifier extends Notifier<LocationState> {
  late final LocationService _locationService;

  @override
  LocationState build() {
    _locationService = LocationService();
    return const LocationState();
  }

  Future<void> loadLocations() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _locationService.getLocations();
      if (result['success'] == true) {
        final List<LocationResponse> locations =
            result['data'] as List<LocationResponse>;
        locations.sort((a, b) => a.id.compareTo(b.id));
        state = state.copyWith(
          locations: locations,
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

  Future<void> refresh() async {
    state = state.copyWith(hasLoaded: false);
    await loadLocations();
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

final locationProvider =
    NotifierProvider<LocationNotifier, LocationState>(() {
  return LocationNotifier();
});


