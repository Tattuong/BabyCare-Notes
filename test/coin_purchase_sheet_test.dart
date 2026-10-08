import 'package:babycare_notes/core/constants/iap_constants.dart';
import 'package:babycare_notes/providers/locale_provider.dart';
import 'package:babycare_notes/providers/shop_provider.dart';
import 'package:babycare_notes/widgets/coin_purchase_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ShopProvider shop;

  setUp(() {
    shop = ShopProvider();
  });

  tearDown(() {
    shop.dispose();
  });

  Future<void> openSheet(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: shop),
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => CoinPurchaseSheet.show(context),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets(
      'star pack sheet stays under 72% of the screen and keeps the footer',
      (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    shop.billing.isAvailable = true;
    shop.billing.coinProducts = [
      for (var i = 0; i < IapConstants.coinPackIds.length; i++)
        ProductDetails(
          id: IapConstants.coinPackIds[i],
          title: 'Pack ${i + 1}',
          description: 'Stars',
          price: '\$${i + 1}',
          rawPrice: (i + 1).toDouble(),
          currencyCode: 'USD',
        ),
    ];

    await openSheet(tester);

    final height = tester.getSize(find.byType(BottomSheet)).height;
    expect(height, lessThan(800));
    expect(height, lessThanOrEqualTo(800 * 0.72 + 48));
    expect(find.text('Buy stars'), findsOneWidget);
    expect(find.text('Pack 1'), findsOneWidget);
    expect(find.text('You can also earn stars by logging activities'),
        findsOneWidget);
  });

  testWidgets('empty billing state stays a short sheet', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await openSheet(tester);

    final height = tester.getSize(find.byType(BottomSheet)).height;
    expect(height, lessThan(400));
    expect(
        find.text('Billing is not available on this device'), findsOneWidget);
    expect(find.text('You can also earn stars by logging activities'),
        findsOneWidget);
  });
}
