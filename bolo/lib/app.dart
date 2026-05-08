import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/home_provider.dart';
import 'presentation/providers/search_provider.dart';
import 'presentation/providers/messages_provider.dart';
import 'presentation/providers/booking_provider.dart';
import 'router/app_router.dart';

class BoloApp extends StatelessWidget {
  const BoloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => MessagesProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
      ],
      child: Builder(
        builder: (context) {
          final router = AppRouter.router(context);
          return MaterialApp.router(
            title: 'BOLO',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routerConfig: router,
            builder: (context, child) {
              // Force portrait
              SystemChrome.setPreferredOrientations([
                DeviceOrientation.portraitUp,
                DeviceOrientation.portraitDown,
              ]);
              SystemChrome.setSystemUIOverlayStyle(
                const SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.dark,
                ),
              );
              return child ?? const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }
}
