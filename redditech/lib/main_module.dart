import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:localization/localization.dart';

import 'package:redditech/constants/app_path.dart';
import 'package:redditech/constants/app_theme.dart';
import 'package:redditech/modules/home_module.dart';
import 'package:redditech/modules/login/authentification_guard.dart';
import 'package:redditech/modules/login/login_screen.dart';
import 'package:redditech/services/bloc/localization/localization_bloc.dart';
import 'package:redditech/services/repositories/user_repository.dart';

class AppModule extends Module {
  @override
  List<Bind> get binds => [
        Bind.singleton((i) => UserRepository()),
      ];

  @override
  List<ModularRoute> get routes => [
        ModuleRoute(
          AppPath.basePath,
          transition: TransitionType.fadeIn,
          guards: [IsAuthenticateGuard()],
          module: HomeModule(),
        ),
        ChildRoute(
          AppPath.loginScreenPath,
          transition: TransitionType.fadeIn,
          guards: [IsNotAuthenticatedGuard()],
          child: (context, args) => const LoginScreen(),
        ),
        WildcardRoute(
          child: (BuildContext context, _) {
            return SizedBox(
              child: Center(
                child: Text("404-not-found".i18n()),
              ),
            );
          },
        ),
      ];
}

class AppWidget extends StatelessWidget {
  const AppWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    LocalJsonLocalization.delegate.directories = ['assets/i18n'];

    return BlocProvider(
      create: (context) => LocalizationBloc(),
      child: BlocBuilder<LocalizationBloc, LocalizationState>(
        builder: (context, state) {
          return KeyedSubtree(
            key: UniqueKey(),
            child: MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: 'Redditech',
              localizationsDelegates: [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                LocalJsonLocalization.delegate,
              ],
              supportedLocales: const [
                Locale('en', 'US'),
                Locale('fr', 'FR'),
              ],
              locale: state.locale,
              routeInformationParser: Modular.routeInformationParser,
              routerDelegate: Modular.routerDelegate,
              theme: ThemeData(
                textTheme: const TextTheme(
                  bodyMedium: TextStyle(
                    color: AppTheme.textColor,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
