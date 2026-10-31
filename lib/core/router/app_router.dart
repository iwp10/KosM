import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/property/domain/property.dart';
import '../../features/property/presentation/pages/onboarding_page.dart';
import '../../features/property/presentation/pages/property_form_page.dart';
import '../../features/property/presentation/pages/property_list_page.dart';
import '../../features/property/presentation/providers/property_providers.dart';
import '../../features/settings/presentation/pages/more_page.dart';
import '../theme/theme.dart';
import '../theme/theme_preview_page.dart';
import '../widgets/widgets.dart';
import 'placeholder_page.dart';
import 'scaffold_with_bottom_nav.dart';

/// Provider for ThemeMode that can be toggled anywhere in the app.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.light;

  void toggle() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

final _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter? _activeRouter;

/// Accessor for the active [GoRouter] instance.
GoRouter get appRouter =>
    _activeRouter ??
    GoRouter(
      navigatorKey: _rootNavigatorKey,
      routes: [GoRoute(path: '/', builder: (_, _) => const SizedBox.shrink())],
    );

/// Listenable that notifies GoRouter whenever properties state changes.
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AsyncValue<List<Property>>>(
      propertiesStreamProvider,
      (_, _) => notifyListeners(),
    );
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final propertiesAsync = _ref.read(propertiesStreamProvider);
    final location = state.matchedLocation;

    // Allow debug preview route unconditionally in debug mode
    if (kDebugMode && location == '/dev/preview') {
      return null;
    }

    // 1. Initial loading: hold on /splash
    if (propertiesAsync.isLoading) {
      return location == '/splash' ? null : '/splash';
    }

    if (propertiesAsync.hasError) {
      if (location == '/splash') return '/home';
      return null;
    }

    final properties = propertiesAsync.value ?? const [];

    // 2. If no properties registered: must go to onboarding
    if (properties.isEmpty) {
      return location == '/onboarding' ? null : '/onboarding';
    }

    // 3. Properties exist: redirect away from onboarding, splash, or root
    if (location == '/onboarding' || location == '/splash' || location == '/') {
      return '/home';
    }

    return null;
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

/// Reusable AppBar title widget that renders [PropertySwitcher] connected to Riverpod.
class PropertyAwareAppBarTitle extends ConsumerWidget {
  const PropertyAwareAppBarTitle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertiesAsync = ref.watch(propertiesStreamProvider);
    final activeAsync = ref.watch(activePropertyProvider);
    final activeId = activeAsync.value ?? 'all';

    final properties = propertiesAsync.value ?? const [];
    final propertyItems = properties
        .map((p) => PropertyItem(id: p.id, name: p.name, address: p.address))
        .toList();

    return PropertySwitcher(
      activePropertyId: activeId,
      properties: propertyItems,
      onSelected: (id) {
        ref.read(activePropertyProvider.notifier).setActiveProperty(id);
      },
    );
  }
}

/// Initial splash/loading screen while checking property registration status.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: AppRadius.cardRadius,
              ),
              child: Icon(
                Icons.apartment_rounded,
                color: theme.colorScheme.primary,
                size: 36,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

/// App-wide [GoRouter] provider.
final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    refreshListenable: notifier,
    initialLocation: '/splash',
    redirect: notifier.redirect,
    routes: [
      GoRoute(
        path: '/splash',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/onboarding',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OnboardingPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithBottomNav(navigationShell: navigationShell);
        },
        branches: [
          // Tab 1: Beranda
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const PlaceholderPage(
                  title: 'Beranda',
                  description: 'Ringkasan kos akan ditampilkan di sini.',
                  icon: Icons.home_rounded,
                  titleWidget: PropertyAwareAppBarTitle(),
                ),
              ),
            ],
          ),
          // Tab 2: Penyewa
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tenants',
                builder: (context, state) => const PlaceholderPage(
                  title: 'Daftar Penyewa',
                  description: 'Kelola data penyewa kos Anda di sini.',
                  icon: Icons.people_rounded,
                  titleWidget: PropertyAwareAppBarTitle(),
                ),
              ),
            ],
          ),
          // Tab 3: Kamar
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/rooms',
                builder: (context, state) => const PlaceholderPage(
                  title: 'Data Kamar',
                  description: 'Daftar dan ketersediaan kamar di sini.',
                  icon: Icons.meeting_room_rounded,
                ),
              ),
            ],
          ),
          // Tab 4: Bayar
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/payments',
                builder: (context, state) => const PlaceholderPage(
                  title: 'Tagihan & Bayar',
                  description: 'Pencatatan tagihan dan pembayaran di sini.',
                  icon: Icons.receipt_long_rounded,
                ),
              ),
            ],
          ),
          // Tab 5: Lainnya
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/more',
                builder: (context, state) => const MorePage(),
                routes: [
                  GoRoute(
                    path: 'properties',
                    builder: (context, state) => const PropertyListPage(),
                    routes: [
                      GoRoute(
                        path: 'new',
                        builder: (context, state) => const PropertyFormPage(),
                      ),
                      GoRoute(
                        path: ':id/edit',
                        builder: (context, state) => PropertyFormPage(
                          propertyId: state.pathParameters['id'],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      if (kDebugMode)
        GoRoute(
          path: '/dev/preview',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Consumer(
              builder: (context, ref, _) {
                return ThemePreviewPage(
                  isDarkMode: isDark,
                  onToggleTheme: () {
                    ref.read(themeModeProvider.notifier).toggle();
                  },
                );
              },
            );
          },
        ),
    ],
  );

  _activeRouter = router;
  return router;
});
