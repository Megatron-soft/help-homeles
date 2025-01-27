import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shelter/helper/helper.dart';
import 'package:shelter/splash_screen/screen/splash_screen.dart';
import 'package:shelter/ui/bloc/homeless_bloc.dart';
import 'package:shelter/ui/bloc/language_bloc.dart';
import 'package:shelter/ui/bloc/needs_bloc.dart';
import 'package:shelter/ui/home_screen.dart';
import 'package:shelter/ui/map_screen/logic/map_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // await dotenv.load(fileName: ".env");
  // await Supabase.initialize(
  //   url: 'your_url',
  //   anonKey:
  //       'annon_key of supabase',
  // );
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  await CacheHelper.init();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<HomelessCubit>(
          create: (_) => HomelessCubit(),
        ),
        BlocProvider<MapCubit>(
          create: (_) => MapCubit(),
        ),
        BlocProvider<NeedsCubit>(
          create: (_) => NeedsCubit(),
        ),
        BlocProvider<LanguageBloc>(
          create: (_) => LanguageBloc(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
Future<void> _initializeCache() async {
  try {
    await CacheHelper.init();
  } catch (error) {
    print("Error initializing cache: $error");
  }
}
Future<void> _initializeApp() async {

  await _initializeCache();
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageBloc, String>(builder: (context, state) {
      return ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        child: MaterialApp(
          title: state == "en" ? "Help Homeless" : "ساعد المحتاجين",
          locale: Locale(state),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'), // English
            Locale('ar'), // arabic
          ],
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
              child: child!,
            );
          },
          home: const SplashScreen(),
          debugShowCheckedModeBanner: false,
        ),
      );
    });
  }
}
