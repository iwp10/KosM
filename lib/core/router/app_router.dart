import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/theme_preview_page.dart';
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

/// The app-wide [GoRouter] configuration with 5 tabs and a debug-only preview route.
final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  routes: [
    GoRoute(path: '/', redirect: (context, state) => '/home'),
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
              builder: (context, state) => const PlaceholderPage(
                title: 'Menu Lainnya',
                description: 'Pengingat, cadangan, laporan, dan pengaturan.',
                icon: Icons.more_horiz_rounded,
              ),
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
