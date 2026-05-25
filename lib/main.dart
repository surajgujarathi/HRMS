import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app/l10n/app_localizations.dart';

import 'package:flutter_app/splashscreen/splashscreen.dart';
import 'package:flutter_app/features/auth/login/cubit/login_cubit.dart';
import 'package:flutter_app/core/widget/network_wrapper.dart';
import 'package:flutter_app/core/widget/in_app_notification_wrapper.dart';
import 'package:flutter_app/core/localization/locale_cubit.dart';
import 'package:flutter_app/features/leave/cubit/leave_cubit.dart';
import 'package:flutter_app/features/notifications/cubit/notification_cubit.dart';
import 'package:flutter_app/features/profile/cubit/profile_cubit.dart';
import 'package:flutter_app/core/theme/theme_cubit.dart';
import 'package:flutter_app/core/theme/app_theme.dart';
import 'package:flutter_app/features/events/cubit/event_cubit.dart';
import 'package:flutter_app/features/profile/cubit/holiday_cubit.dart';
import 'package:flutter_app/features/chat/cubit/chat_cubit.dart';
import 'package:flutter_app/routes.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LoginCubit()),
        BlocProvider(create: (context) => LocaleCubit()),
        BlocProvider(create: (context) => LeaveCubit()),
        BlocProvider(create: (context) => NotificationCubit()..fetchNotifications()),
        BlocProvider(create: (context) => ProfileCubit()..fetchProfile()),
        BlocProvider(create: (context) => ThemeCubit()..loadTheme()),
        BlocProvider(create: (context) => EventCubit()..fetchEvents()),
        BlocProvider(create: (context) => HolidayCubit()..fetchHolidays()),
        BlocProvider(create: (context) => ChatCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return BlocBuilder<LocaleCubit, String>(
            builder: (context, langCode) {
              return MaterialApp(
                navigatorKey: navigatorKey,
                debugShowCheckedModeBanner: false,
                locale: Locale(langCode),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeMode,
                routes: Routes.getAll(),
                home: const SplashScreen(),
                builder: (context, child) {
                  return NetworkWrapper(
                    child: InAppNotificationWrapper(
                      child: child!,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
