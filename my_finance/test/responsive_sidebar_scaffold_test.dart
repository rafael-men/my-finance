import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_finance/widgets/responsive_sidebar_scaffold.dart';
import 'package:my_finance/widgets/sidebar.dart';

void main() {
  Future<void> pumpMobile(
    WidgetTester tester, {
    required String title,
    required double width,
    List<Widget> actions = const [
      IconButton(
        icon: Icon(Icons.refresh),
        tooltip: 'Atualizar',
        onPressed: null,
      ),
    ],
  }) async {
    tester.view.physicalSize = Size(width, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: ResponsiveSidebarScaffold(
          title: title,
          destination: SidebarDestination.home,
          actions: actions,
          body: const SizedBox(),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('AppBar mobile não estoura com título curto', (tester) async {
    await pumpMobile(tester, title: 'Minhas Finanças', width: 400);
    expect(tester.takeException(), isNull);
  });

  testWidgets('AppBar mobile não estoura com título longo e actions',
      (tester) async {
    await pumpMobile(
      tester,
      width: 360,
      title: 'Minhas Viagens para a Europa Ocidental e Mediterrânea',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('AppBar mobile muito estreito não estoura', (tester) async {
    await pumpMobile(
      tester,
      width: 250,
      title: 'Minhas Finanças e Compras',
    );
    expect(tester.takeException(), isNull);
  });
}