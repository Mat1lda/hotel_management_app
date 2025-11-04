import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/booking_model.dart';

class MyBookingState {
  final bool initialized;
  final List<BookingModel> bookedBookings;
  final List<BookingModel> historyBookings;
  final BookingStatus selectedTab;

  const MyBookingState({
    this.initialized = false,
    this.bookedBookings = const [],
    this.historyBookings = const [],
    this.selectedTab = BookingStatus.booked,
  });

  MyBookingState copyWith({
    bool? initialized,
    List<BookingModel>? bookedBookings,
    List<BookingModel>? historyBookings,
    BookingStatus? selectedTab,
  }) {
    return MyBookingState(
      initialized: initialized ?? this.initialized,
      bookedBookings: bookedBookings ?? this.bookedBookings,
      historyBookings: historyBookings ?? this.historyBookings,
      selectedTab: selectedTab ?? this.selectedTab,
    );
  }
}

class MyBookingNotifier extends Notifier<MyBookingState> {
  @override
  MyBookingState build() {
    return const MyBookingState();
  }

  void initialize() {
    // Fake data cho booking
    final bookedBookings = [
      const BookingModel(
        id: '1',
        hotelName: 'Grand Hotel Saigon',
        hotelImage: 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=80',
        rating: 4.7,
        dates: '15 - 17 Tháng 11, 2024',
        guests: 2,
        rooms: 1,
        price: '3,200,000',
        status: BookingStatus.booked,
      ),
      const BookingModel(
        id: '2',
        hotelName: 'Resort Mystic Palms',
        hotelImage: 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=80',
        rating: 4.0,
        dates: '20 - 25 Tháng 11, 2024',
        guests: 1,
        rooms: 1,
        price: '2,300,000',
        status: BookingStatus.booked,
      ),
    ];

    final historyBookings = [
      const BookingModel(
        id: '3',
        hotelName: 'Khách sạn Luxury Da Nang',
        hotelImage: 'https://images.unsplash.com/photo-1564501049412-61c2a3083791?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=80',
        rating: 4.8,
        dates: '15 - 17 Tháng 10, 2024',
        guests: 2,
        rooms: 1,
        price: '2,500,000',
        status: BookingStatus.history,
      ),
      const BookingModel(
        id: '4',
        hotelName: 'Resort Horizon Đà Lạt',
        hotelImage: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=80',
        rating: 4.9,
        dates: '5 - 8 Tháng 9, 2024',
        guests: 3,
        rooms: 2,
        price: '4,800,000',
        status: BookingStatus.history,
      ),
    ];

    state = state.copyWith(
      initialized: true,
      bookedBookings: bookedBookings,
      historyBookings: historyBookings,
    );
  }

  void setSelectedTab(BookingStatus tab) {
    state = state.copyWith(selectedTab: tab);
  }
}

final myBookingProvider = NotifierProvider<MyBookingNotifier, MyBookingState>(() {
  return MyBookingNotifier();
});


