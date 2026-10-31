import 'package:daily_tracking/core/theme/app_colors.dart';
import 'package:daily_tracking/core/theme/app_dimens.dart';
import 'package:daily_tracking/core/utils/money.dart';
import 'package:daily_tracking/core/widgets/hero_daily_limit_card.dart';
import 'package:daily_tracking/core/widgets/neo_background.dart';
import 'package:daily_tracking/core/widgets/neo_box.dart';
import 'package:daily_tracking/core/widgets/primary_button.dart';
import 'package:daily_tracking/core/widgets/transaction_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

Color? _colorOf(WidgetTester tester, String text) =>
    tester.widget<Text>(find.text(text)).style?.color;

void main() {
  group('LimitStatus.from', () {
    test('negatif -> over', () {
      expect(LimitStatus.from(remaining: -1, spentRatio: 1), LimitStatus.over);
    });
    test('terpakai >= 80% -> warning', () {
      expect(
        LimitStatus.from(remaining: 10000, spentRatio: 0.8),
        LimitStatus.warning,
      );
    });
    test('sisa banyak -> healthy', () {
      expect(
        LimitStatus.from(remaining: 50000, spentRatio: 0.2),
        LimitStatus.healthy,
      );
    });
  });

  testWidgets('HeroDailyLimitCard menampilkan nominal & status overbudget', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const HeroDailyLimitCard(remaining: -5000, spentRatio: 1.2)),
    );

    expect(find.text(formatRupiah(-5000)), findsOneWidget);
    expect(find.text('Overbudget'), findsOneWidget);
    expect(_colorOf(tester, formatRupiah(-5000)), AppColors.danger);
  });

  testWidgets('HeroDailyLimitCard: border progress tidak tertimpa indikator', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const HeroDailyLimitCard(remaining: 5000, spentRatio: 0.5)),
    );

    final indicator = find.byType(LinearProgressIndicator);
    final frame = find.ancestor(
      of: indicator,
      matching: find.byType(Container),
    );
    expect(
      tester.getSize(frame.first).height,
      tester.getSize(indicator).height + AppNeo.borderWidth * 2,
    );
  });

  testWidgets('NeoBackground menjaga konten di atas navigation bar', (
    tester,
  ) async {
    late double bottomPadding;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(padding: EdgeInsets.only(bottom: 48)),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: NeoBackground(
            child: Builder(
              builder: (context) {
                bottomPadding = MediaQuery.paddingOf(context).bottom;
                return const SizedBox.expand(key: ValueKey('content'));
              },
            ),
          ),
        ),
      ),
    );

    final screenHeight =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
    expect(
      tester.getBottomLeft(find.byKey(const ValueKey('content'))).dy,
      screenHeight - 48,
    );
    expect(bottomPadding, 0);
  });

  testWidgets('TransactionListTile: pengeluaran merah dengan tanda minus', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      _wrap(
        TransactionListTile(
          icon: Icons.restaurant,
          title: 'Makan',
          subtitle: 'Nasi padang',
          amount: 25000,
          onTap: () => tapped = true,
        ),
      ),
    );

    final amount = '-${formatRupiah(25000)}';
    expect(find.text(amount), findsOneWidget);
    expect(_colorOf(tester, amount), AppColors.danger);

    await tester.tap(find.text('Makan'));
    expect(tapped, isTrue);
  });

  testWidgets('PrimaryButton nonaktif saat loading', (tester) async {
    await tester.pumpWidget(
      _wrap(PrimaryButton(label: 'Simpan', onPressed: () {}, isLoading: true)),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(tester.widget<NeoButton>(find.byType(NeoButton)).onPressed, isNull);
  });
}
