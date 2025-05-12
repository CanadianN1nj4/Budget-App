import 'package:flutter/widgets.dart';
import 'package:lucide_icons/lucide_icons.dart'; // Using lucide_flutter

// Helper function to get Lucide icon by name
// This is a simplified mapping. For a full solution, you might need a larger map
// or a more dynamic way if lucide_flutter doesn't offer direct name lookup.
IconData getLucideIcon(String iconName) {
  switch (iconName.toLowerCase()) {
    case 'shoppingbasket':
      return LucideIcons.shoppingCart;
    case 'zap':
      return LucideIcons.zap;
    case 'home':
      return LucideIcons.home;
    case 'car':
      return LucideIcons.car;
    case 'film':
      return LucideIcons.film;
    case 'utensils':
      return LucideIcons.utensils;
    case 'ticket':
      return LucideIcons.ticket;
    case 'piggybank':
      return LucideIcons.piggyBank;
    case 'landmark':
      return LucideIcons.landmark;
    case 'creditcard':
      return LucideIcons.creditCard;
    case 'wallet':
      return LucideIcons.wallet;
    case 'package': // Default
    default:
      return LucideIcons.package;
  }
}
