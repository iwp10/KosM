import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/router.dart';
import 'core/theme/theme.dart';
import 'features/tenant/presentation/providers/tenant_providers.dart';

/// Root Application Widget for KosM.
class KosMApp extends ConsumerStatefulWidget {
  const KosMApp({super.key});

  @override
  ConsumerState<KosMApp> createState() => _KosMAppState();
}

class _KosMAppState extends ConsumerState<KosMApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tenantRepositoryProvider).cleanupOrphanPhotos().catchError((e) {
        debugPrint('cleanupOrphanPhotos error: $e');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'KosM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('id', 'ID')],
    );
  }
}
