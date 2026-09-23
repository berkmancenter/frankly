import 'package:flutter_test/flutter_test.dart';
import 'package:client/features/admin/presentation/views/members_tab.dart';
import 'package:client/core/localization/app_localization_service.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:data_models/community/membership.dart';

@TestOn('browser')
@GenerateNiceMocks([
  MockSpec<MembersTab>(),
])
Widget _wrapWithLocalizedApp(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(body: child),
  );
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    GetIt.instance.registerSingleton(AppLocalizationService());
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    GetIt.instance<AppLocalizationService>().setLocalization(l10n);
  });

  tearDownAll(() async {
    await GetIt.instance.reset();
  });

  group('StringExtension capitalize', () {
    test('capitalizes first letter of a lowercase string', () {
      expect('hello'.capitalize(), 'Hello');
    });

    test('returns empty string for empty string', () {
      expect(''.capitalize(), '');
    });

    test('capitalizes single character', () {
      expect('a'.capitalize(), 'A');
    });

    test('keeps already capitalized string', () {
      expect('Hello'.capitalize(), 'Hello');
    });

    test('handles all uppercase string', () {
      expect('HELLO'.capitalize(), 'HELLO');
    });
  });

  group('MembershipDataSource', () {
    test('rowCount returns correct count', () {
      final memberships = [
        Membership(
          userId: 'user1',
          communityId: 'c1',
          status: MembershipStatus.member,
        ),
        Membership(
          userId: 'user2',
          communityId: 'c1',
          status: MembershipStatus.admin,
        ),
      ];
      final source = MembershipDataSource(
        memberships,
        _FakeBuildContext(),
      );
      expect(source.rowCount, 2);
    });

    test('rowCount returns 0 for null list', () {
      final source = MembershipDataSource(null, _FakeBuildContext());
      expect(source.rowCount, 0);
    });

    test('isRowCountApproximate is false', () {
      final source = MembershipDataSource([], _FakeBuildContext());
      expect(source.isRowCountApproximate, false);
    });

    test('selectedRowCount is 0', () {
      final source = MembershipDataSource([], _FakeBuildContext());
      expect(source.selectedRowCount, 0);
    });
  });

  group('RolePermissionListTile', () {
    testWidgets('displays title and permissions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RolePermissionListTile(
              title: 'Admin',
              permissions: const ['Can edit', 'Can delete'],
              icon: Icon(Icons.admin_panel_settings),
            ),
          ),
        ),
      );

      expect(find.text('Admin'), findsOneWidget);
      expect(find.text('Can edit'), findsOneWidget);
      expect(find.text('Can delete'), findsOneWidget);
    });

    testWidgets('displays empty permissions list', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RolePermissionListTile(
              title: 'Member',
              permissions: const [],
              icon: Icon(Icons.person),
            ),
          ),
        ),
      );

      expect(find.text('Member'), findsOneWidget);
    });
  });

  group('_MembershipDropdownState', () {
    testWidgets('renders MembershipDropdown widget', (tester) async {
      await tester.pumpWidget(
        _wrapWithLocalizedApp(
          MembershipDropdown(
            membership: Membership(
              userId: 'user1',
              communityId: 'c1',
              status: MembershipStatus.member,
            ),
          ),
        ),
      );

      expect(find.byType(MembershipDropdown), findsOneWidget);
    });

    testWidgets('displays current membership status', (tester) async {
      await tester.pumpWidget(
        _wrapWithLocalizedApp(
          MembershipDropdown(
            membership: Membership(
              userId: 'user1',
              communityId: 'c1',
              status: MembershipStatus.admin,
            ),
          ),
        ),
      );

      expect(find.text('Admin'), findsOneWidget);
    });

    testWidgets('changing MembershipStatus to admin via dropdown',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithLocalizedApp(
          MembershipDropdown(
            membership: Membership(
              userId: 'user1',
              communityId: 'c1',
              status: MembershipStatus.member,
            ),
          ),
        ),
      );

      // Tap the dropdown to open it
      await tester.tap(find.byType(MembershipDropdown));
      await tester.pumpAndSettle();

      // Select a different status
      await tester.tap(find.text('Admin').last);
      await tester.pumpAndSettle();

      expect(find.text('Admin'), findsOneWidget);
    });

    testWidgets('if ID in communityProvider is null, does not throw exception',
        (tester) async {
      // communityProvider.community.id throws until initialize() runs (it's
      // backed by a `late` field), so an unloaded community's id is empty.
      const unloadedCommunityId = '';
      await tester.pumpWidget(
        _wrapWithLocalizedApp(
          MembershipDropdown(
            membership: Membership(
              userId: 'user1',
              communityId: unloadedCommunityId,
              status: MembershipStatus.member,
            ),
          ),
        ),
      );

      // output result
      await tester.tap(find.byType(MembershipDropdown));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Admin').last);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}

class _FakeBuildContext extends Fake implements BuildContext {}
