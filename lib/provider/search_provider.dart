import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/response/room_type_response.dart';
import 'room_provider.dart';

class SearchState {
  final String searchQuery;
  final String selectedLocation;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final int guests;
  final int rooms;
  final List<RoomTypeResponse> searchResults;
  final bool isLoading;
  final bool hasSearched;

  const SearchState({
    this.searchQuery = '',
    this.selectedLocation = '',
    this.checkInDate,
    this.checkOutDate,
    this.guests = 1,
    this.rooms = 1,
    this.searchResults = const [],
    this.isLoading = false,
    this.hasSearched = false,
  });

  SearchState copyWith({
    String? searchQuery,
    String? selectedLocation,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    int? guests,
    int? rooms,
    List<RoomTypeResponse>? searchResults,
    bool? isLoading,
    bool? hasSearched,
  }) {
    return SearchState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      guests: guests ?? this.guests,
      rooms: rooms ?? this.rooms,
      searchResults: searchResults ?? this.searchResults,
      isLoading: isLoading ?? this.isLoading,
      hasSearched: hasSearched ?? this.hasSearched,
    );
  }
}

class SearchNotifier extends Notifier<SearchState> {
  @override
  SearchState build() {
    return const SearchState();
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setLocation(String location) {
    state = state.copyWith(selectedLocation: location);
  }

  void setCheckInDate(DateTime date) {
    state = state.copyWith(checkInDate: date);
  }

  void setCheckOutDate(DateTime date) {
    state = state.copyWith(checkOutDate: date);
  }

  void setGuests(int guests) {
    state = state.copyWith(guests: guests);
  }

  void setRooms(int rooms) {
    state = state.copyWith(rooms: rooms);
  }

  Future<void> search() async {
    state = state.copyWith(isLoading: true, hasSearched: true);
    
    try {
      // Load room types from API if not already loaded
      final roomNotifier = ref.read(roomProvider.notifier);
      final roomState = ref.read(roomProvider);
      
      if (!roomState.hasLoaded && !roomState.isLoading) {
        await roomNotifier.loadAllRoomTypes();
      }

      final allRoomTypes = ref.read(roomProvider).roomTypes;

      final results = state.searchQuery.isEmpty 
        ? allRoomTypes
        : allRoomTypes.where((room) {
            return room.name.toLowerCase().contains(state.searchQuery.toLowerCase()) ||
                   room.details.toLowerCase().contains(state.searchQuery.toLowerCase());
          }).toList();
      
      state = state.copyWith(
        searchResults: results,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        searchResults: [],
        isLoading: false,
      );
    }
  }


  Future<void> loadAllRooms() async {
    print('SearchProvider: Loading all rooms...');
    state = state.copyWith(isLoading: true, hasSearched: true);
    
    try {
      // Load room types from API
      final roomNotifier = ref.read(roomProvider.notifier);
      await roomNotifier.loadAllRoomTypes();

      final allRoomTypes = ref.read(roomProvider).roomTypes;
      print('SearchProvider: Got ${allRoomTypes.length} room types from provider');
      
      state = state.copyWith(
        searchResults: allRoomTypes,
        isLoading: false,
      );
      print('SearchProvider: Updated search results with ${allRoomTypes.length} rooms');
    } catch (e) {
      print('SearchProvider: Exception in loadAllRooms: $e');
      state = state.copyWith(
        searchResults: [],
        isLoading: false,
      );
    }
  }

  void clearSearch() {
    state = const SearchState();
  }
}

final searchProvider = NotifierProvider.autoDispose<SearchNotifier, SearchState>(() {
  return SearchNotifier();
});
