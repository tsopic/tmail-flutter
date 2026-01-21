import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/manage_account_menu_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:jmap_dart_client/jmap/quotas/quota.dart';

import 'manage_account_menu_controller_test.mocks.dart';

mockControllerCallback() => InternalFinalCallback<void>(callback: () {});
const fallbackGenerators = {
  #onStart: mockControllerCallback,
  #onDelete: mockControllerCallback,
};

@GenerateNiceMocks([
  MockSpec<ManageAccountDashBoardController>(fallbackGenerators: fallbackGenerators),
  MockSpec<ResponsiveUtils>(),
  MockSpec<ImagePaths>(),
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockManageAccountDashBoardController mockDashboardController;
  late MockResponsiveUtils mockResponsiveUtils;
  late MockImagePaths mockImagePaths;

  setUp(() {
    // Reset GetX bindings
    Get.reset();

    mockDashboardController = MockManageAccountDashBoardController();
    mockResponsiveUtils = MockResponsiveUtils();
    mockImagePaths = MockImagePaths();

    // Register mocks with GetX
    Get.put<ManageAccountDashBoardController>(mockDashboardController);
    Get.put<ResponsiveUtils>(mockResponsiveUtils);
    Get.put<ImagePaths>(mockImagePaths);

    // Default stubs for dashboard controller
    when(mockDashboardController.isRuleFilterCapabilitySupported)
        .thenReturn(false);
    when(mockDashboardController.isForwardCapabilitySupported)
        .thenReturn(false);
    when(mockDashboardController.isVacationCapabilitySupported)
        .thenReturn(false);
    when(mockDashboardController.isLanguageSettingDisplayed)
        .thenReturn(false);
    when(mockDashboardController.octetsQuota)
        .thenReturn(Rxn<Quota>(null));
  });

  tearDown(() {
    Get.reset();
  });

  group('ManageAccountMenuController', () {
    group('onInit', () {
      test('should refresh menu items immediately when accountId is already set', () {
        // arrange
        final accountId = AccountId(Id('test-account-id'));
        when(mockDashboardController.accountId)
            .thenReturn(Rxn<AccountId>(accountId));

        // act
        final controller = ManageAccountMenuController();
        controller.onInit();

        // assert - preferences should be included after refresh
        expect(
          controller.listAccountMenuItem,
          contains(AccountMenuItem.preferences),
        );
      });

      test('should not refresh menu items when accountId is null', () {
        // arrange
        when(mockDashboardController.accountId)
            .thenReturn(Rxn<AccountId>(null));

        // act
        final controller = ManageAccountMenuController();
        controller.onInit();

        // assert - initial list should not contain preferences
        // (preferences is added only via buildMenuItems)
        expect(
          controller.listAccountMenuItem,
          isNot(contains(AccountMenuItem.preferences)),
        );
      });

      test('should include profiles and mailboxVisibility in initial list', () {
        // arrange
        when(mockDashboardController.accountId)
            .thenReturn(Rxn<AccountId>(null));

        // act
        final controller = ManageAccountMenuController();
        controller.onInit();

        // assert
        expect(
          controller.listAccountMenuItem,
          contains(AccountMenuItem.profiles),
        );
        expect(
          controller.listAccountMenuItem,
          contains(AccountMenuItem.mailboxVisibility),
        );
      });

      test('should include keyboardShortcuts on web platform', () {
        // arrange
        PlatformInfo.isTestingForWeb = true;
        when(mockDashboardController.accountId)
            .thenReturn(Rxn<AccountId>(null));

        // act
        final controller = ManageAccountMenuController();
        controller.onInit();

        // assert
        expect(
          controller.listAccountMenuItem,
          contains(AccountMenuItem.keyboardShortcuts),
        );

        // cleanup
        PlatformInfo.isTestingForWeb = false;
      });
    });

    group('menu item refresh', () {
      test('should include all always-show items after refresh', () {
        // arrange
        final accountId = AccountId(Id('test-account-id'));
        when(mockDashboardController.accountId)
            .thenReturn(Rxn<AccountId>(accountId));

        // act
        final controller = ManageAccountMenuController();
        controller.onInit();

        // assert
        expect(
          controller.listAccountMenuItem,
          contains(AccountMenuItem.profiles),
        );
        expect(
          controller.listAccountMenuItem,
          contains(AccountMenuItem.preferences),
        );
        expect(
          controller.listAccountMenuItem,
          contains(AccountMenuItem.mailboxVisibility),
        );
      });

      test('should include capability-based items when capabilities are supported', () {
        // arrange
        final accountId = AccountId(Id('test-account-id'));
        when(mockDashboardController.accountId)
            .thenReturn(Rxn<AccountId>(accountId));
        when(mockDashboardController.isRuleFilterCapabilitySupported)
            .thenReturn(true);
        when(mockDashboardController.isForwardCapabilitySupported)
            .thenReturn(true);
        when(mockDashboardController.isVacationCapabilitySupported)
            .thenReturn(true);

        // act
        final controller = ManageAccountMenuController();
        controller.onInit();

        // assert
        expect(
          controller.listAccountMenuItem,
          contains(AccountMenuItem.emailRules),
        );
        expect(
          controller.listAccountMenuItem,
          contains(AccountMenuItem.forward),
        );
        expect(
          controller.listAccountMenuItem,
          contains(AccountMenuItem.vacation),
        );
      });
    });
  });
}
