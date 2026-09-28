import 'package:flutter/material.dart';

/// Curated Material icons for custom categories (tasks + notes).
///
/// Stored as stable string keys in [AppSettings.categoryIcons], not code points.
class CategoryIconCatalog {
  CategoryIconCatalog._();

  static const defaultKey = 'label';
  static const noneKey = 'none';

  static const Map<String, IconData> icons = {
    noneKey: Icons.label_off_outlined,
    defaultKey: Icons.label_outline,
    'home': Icons.home_outlined,
    'work': Icons.work_outline,
    'school': Icons.school_outlined,
    'health': Icons.favorite_outline,
    'fitness': Icons.fitness_center_outlined,
    'medical': Icons.medical_services_outlined,
    'cart': Icons.shopping_cart_outlined,
    'store': Icons.storefront_outlined,
    'finance': Icons.account_balance_wallet_outlined,
    'bank': Icons.account_balance_outlined,
    'receipt': Icons.receipt_long_outlined,
    'car': Icons.directions_car_outlined,
    'bike': Icons.directions_bike_outlined,
    'bus': Icons.directions_bus_outlined,
    'train': Icons.train_outlined,
    'flight': Icons.flight_outlined,
    'map': Icons.map_outlined,
    'food': Icons.restaurant_outlined,
    'coffee': Icons.local_cafe_outlined,
    'groceries': Icons.local_grocery_store_outlined,
    'pets': Icons.pets_outlined,
    'sports': Icons.sports_soccer_outlined,
    'music': Icons.music_note_outlined,
    'movie': Icons.movie_outlined,
    'game': Icons.sports_esports_outlined,
    'camera': Icons.photo_camera_outlined,
    'book': Icons.menu_book_outlined,
    'edit': Icons.edit_outlined,
    'lightbulb': Icons.lightbulb_outline,
    'build': Icons.build_outlined,
    'cleaning': Icons.cleaning_services_outlined,
    'laundry': Icons.local_laundry_service_outlined,
    'garden': Icons.yard_outlined,
    'nature': Icons.park_outlined,
    'child': Icons.child_care_outlined,
    'people': Icons.people_outline,
    'family': Icons.family_restroom_outlined,
    'gift': Icons.card_giftcard_outlined,
    'celebration': Icons.celebration_outlined,
    'star': Icons.star_outline,
    'flag': Icons.flag_outlined,
    'bookmark': Icons.bookmark_outline,
    'bolt': Icons.bolt_outlined,
    'calendar': Icons.calendar_today_outlined,
    'alarm': Icons.alarm_outlined,
    'timer': Icons.timer_outlined,
    'mail': Icons.mail_outline,
    'chat': Icons.chat_bubble_outline,
    'phone': Icons.phone_outlined,
    'computer': Icons.computer_outlined,
    'wifi': Icons.wifi_outlined,
    'cloud': Icons.cloud_outlined,
    'lock': Icons.lock_outline,
    'key': Icons.key_outlined,
    'travel': Icons.luggage_outlined,
    'beach': Icons.beach_access_outlined,
    'bed': Icons.bed_outlined,
    'bathtub': Icons.bathtub_outlined,
    'kitchen': Icons.kitchen_outlined,
    'inventory': Icons.inventory_2_outlined,
  };

  /// Keys shown in the icon picker (excludes the synthetic "none" slot).
  static List<String> get pickerKeys =>
      icons.keys.where((k) => k != noneKey).toList(growable: false);

  static IconData resolve(String? key, {required bool isNone}) {
    if (isNone) return icons[noneKey]!;
    if (key == null || key.isEmpty) return icons[defaultKey]!;
    return icons[key] ?? icons[defaultKey]!;
  }
}
