import 'package:flutter/material.dart';
import '../model/booking_bill_group.dart';
import '../model/response/room_type_response.dart';
import '../screen/booking_detail_screen.dart';
import '../screen/room_detail_screen.dart';

class NavigationUtils {
  const NavigationUtils._();

  static void openRoomDetail(BuildContext context, RoomTypeResponse room) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RoomDetailScreen(room: room),
      ),
    );
  }

  static void openBookingDetail(BuildContext context, BookingBillGroup group) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BookingDetailScreen(group: group),
      ),
    );
  }
}


