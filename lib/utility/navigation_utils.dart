import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/booking_bill_group.dart';
import '../model/response/room_type_response.dart';
import '../model/response/service_response.dart';
import '../screen/booking_detail_screen.dart';
import '../screen/service_detail_screen.dart';
import '../screen/services_screen.dart';
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

  static void openServices(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ServicesScreen(),
      ),
    );
  }

  static void openServiceDetail(BuildContext context, ServiceResponse service) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ServiceDetailScreen(service: service),
      ),
    );
  }

  static Future<bool> openExternalUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}


