class ImageUtils {
  static const List<String> defaultRoomImages = [
    'https://images.unsplash.com/photo-1566073771259-6a8506099945?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=80', // Standard room
    'https://images.unsplash.com/photo-1571896349842-33c89424de2d?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=80', // Luxury room
    'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=80', // Modern room
    'https://images.unsplash.com/photo-1578662996442-48f60103fc96?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=80', // Ocean view
    'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=80', // Elegant room
  ];

  static String getRoomImage(List<String> roomImages, int roomId) {
    if (roomImages.isNotEmpty) {
      return roomImages.first;
    }
    final imageIndex = roomId % defaultRoomImages.length;
    return defaultRoomImages[imageIndex];
  }

  static List<String> getRoomImages(List<String> roomImages, int roomId) {
    if (roomImages.isNotEmpty) {
      return roomImages;
    }
    // Xoay danh sách ảnh mặc định dựa trên roomId để đa dạng
    final start = roomId % defaultRoomImages.length;
    final List<String> rotated = [];
    for (int i = 0; i < defaultRoomImages.length; i++) {
      rotated.add(defaultRoomImages[(start + i) % defaultRoomImages.length]);
    }
    return rotated;
  }
  static String getRandomDefaultImage() {
    final randomIndex = DateTime.now().millisecondsSinceEpoch % defaultRoomImages.length;
    return defaultRoomImages[randomIndex];
  }

  static String getServiceImage(List<String> serviceImages, int serviceId) {
    if (serviceImages.isNotEmpty) {
      return serviceImages.first;
    }
    final imageIndex = serviceId % defaultRoomImages.length;
    return defaultRoomImages[imageIndex];
  }
}
