import 'package:flutter/material.dart';

import '../domain/entities.dart';

extension TransactionCategoryUi on TransactionCategory {
  String get label => switch (this) {
    TransactionCategory.food => 'Makan',
    TransactionCategory.transport => 'Transport',
    TransactionCategory.shopping => 'Belanja',
    TransactionCategory.other => 'Lainnya',
  };

  IconData get icon => switch (this) {
    TransactionCategory.food => Icons.restaurant,
    TransactionCategory.transport => Icons.directions_bus,
    TransactionCategory.shopping => Icons.shopping_bag,
    TransactionCategory.other => Icons.more_horiz,
  };
}
