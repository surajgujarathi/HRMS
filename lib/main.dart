import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app/l10n/app_localizations.dart';

import 'package:flutter_app/splashscreen/splashscreen.dart';
import 'package:flutter_app/features/auth/login/cubit/login_cubit.dart';
import 'package:flutter_app/core/localization/locale_cubit.dart';
import 'package:flutter_app/features/leave/cubit/leave_cubit.dart';
import 'package:flutter_app/routes.dart';

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
      ],
      child: BlocBuilder<LocaleCubit, String>(
        builder: (context, langCode) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: Locale(langCode),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routes: Routes.getAll(),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
