import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import 'period_form.dart';

/// Memulai siklus gajian baru; periode lama otomatis diarsipkan.
class NewPeriodScreen extends StatelessWidget {
  const NewPeriodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Periode Baru'),
        leading: BackButton(onPressed: () => context.go(homePath)),
      ),
      body: PeriodForm(isNewPeriod: true, onSaved: () => context.go(setupPath)),
    );
  }
}
