import 'package:flutter/material.dart';

extension CustomColorScheme on ColorScheme {
  Color get input_Background => brightness == Brightness.light
      ? const Color(0xFFF4F4F4)
      : const Color(0xFFF4F4F4);

  Color get linkColor => brightness == Brightness.light
      ? const Color(0xFF1890FF)
      : const Color(0xFF1890FF);

  Color get border_Input => brightness == Brightness.light
      ? const Color(0xffE3E2E6)
      : const Color(0xffE3E2E6);

  Color get border_Icon => brightness == Brightness.light
      ? const Color(0xff9D9D9D)
      : const Color(0xff9D9D9D);

  Color get Color_Divider => brightness == Brightness.light
      ? const Color(0xFFEEEEEE)
      : const Color(0xFFEEEEEE);

  //...........

  Color get Color_PriceGreen => brightness == Brightness.light
      ? const Color(0xff3DB46E)
      : const Color(0xff3DB46E);

  Color get starColore => brightness == Brightness.light
      ? const Color(0xffF8AA00)
      : const Color(0xffF8AA00);

  Color get rateColore => brightness == Brightness.light
      ? const Color(0xffDB7876)
      : const Color(0xffDB7876);

  Color get hiteTextColore => brightness == Brightness.light
      ? const Color(0xff9EA0A7)
      : const Color(0xff9EA0A7);
}

abstract class AppThemes {
  static const lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF711f7e),
    background: Color(0xFFFFFFFF),
    onSurface: Color(0xff170128),
    onPrimary: Color(0xFFFFFFFF), // بگراند appbar / رنگ متن روی ویجت ها
    //..........
    onSecondary: Color(0xff3A3A3A), // رنگ ایکن روی ویجت ها
    secondary: Colors.pink,
    surface: Color(0xFF711f7e), // خط زیر تب بار
    error: Color(0xFFC60505),
    onBackground: Color(0xffE3E2E6), // بردر دور ویجت ها
    onError: Color(0xFF246672),
  );
  static const darkColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color.fromARGB(255, 14, 103, 204),
    background: Color.fromARGB(255, 243, 148, 148),
    onSurface: Color(0xff170128),
    onPrimary: Color(0xffFFFFFF), // بگراند appbar / رنگ متن روی ویجت ها
    //..........
    onSecondary: Color(0xff3A3A3A), // رنگ ایکن روی ویجت ها
    secondary: Colors.pink,
    surface: Color(0xFFE5F501),
    error: Colors.red,
    onBackground: Color(0xffE3E2E6), // بردر دور ویجت ها
    onError: Color(0xFF246672),
  );
  static ThemeData light() {
    String fontsRegular = 'IRANSansX_Regular';
    String fontsMedium = 'IRANSansX_Medium';

    return ThemeData.light().copyWith(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: lightColorScheme,
        scaffoldBackgroundColor: lightColorScheme.background,
        dividerTheme: DividerThemeData(
            color: ThemeData.light().colorScheme.Color_Divider),
        progressIndicatorTheme:
            const ProgressIndicatorThemeData(color: Colors.red),
        radioTheme: RadioThemeData(
          fillColor: MaterialStateColor.resolveWith(
              (states) => lightColorScheme.primary),
        ),
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: lightColorScheme.onPrimary,
          iconTheme: IconThemeData(color: lightColorScheme.onSecondary),
        ),
        tabBarTheme: TabBarTheme(
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: lightColorScheme.primary,
          labelColor: lightColorScheme.background,
          indicator: BoxDecoration(
              color: lightColorScheme.primary,
              borderRadius: BorderRadius.circular(2.5)),
        ),
        cardTheme: CardTheme(
          elevation: 0,
          color: lightColorScheme.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.0),
            side: BorderSide(color: Colors.grey.withOpacity(0.3), width: 0.5),
          ),
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
            contentPadding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: lightColorScheme.primary,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(12.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: ThemeData.light().colorScheme.border_Input,
                  width: 1.5),
              borderRadius: BorderRadius.circular(12.0),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: lightColorScheme.primary,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(12.0),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: ThemeData.light().colorScheme.border_Input,
                  width: 1.5),
              borderRadius: BorderRadius.circular(12.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: ThemeData.light().colorScheme.border_Input,
                  width: 1.5),
              borderRadius: BorderRadius.circular(12.0),
            ),
            hintStyle: TextStyle(
                fontSize: 14,
                fontFamily: fontsRegular,
                color: lightColorScheme.hiteTextColore,
                fontWeight: FontWeight.w400),
            labelStyle: const TextStyle(
              fontSize: 14,
            )),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: TextButton.styleFrom(
              textStyle: TextStyle(
                fontSize: 16.0,
                fontFamily: fontsMedium,
                color: lightColorScheme.background,
              ),
              backgroundColor: lightColorScheme.primary,
              foregroundColor: lightColorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12))),
        ),
        buttonTheme: const ButtonThemeData(height: 100),
        drawerTheme: DrawerThemeData(
            elevation: 0,
            backgroundColor: lightColorScheme.onPrimary,
            scrimColor: Colors.transparent),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: lightColorScheme.primary,
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: const TextStyle(
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          selectedIconTheme: const IconThemeData(size: 29),
          unselectedIconTheme: const IconThemeData(size: 29),
        ),
        textTheme: TextTheme(
            bodyLarge: TextStyle(
                fontSize: 16,
                fontFamily: fontsRegular,
                color: lightColorScheme.onSurface),
            bodySmall: TextStyle(
                fontSize: 12,
                fontFamily: fontsRegular,
                color: lightColorScheme.onSurface),
            bodyMedium: TextStyle(
                fontSize: 14,
                fontFamily: fontsRegular,
                color: lightColorScheme.onSurface),
            labelSmall: TextStyle(
                fontSize: 11,
                fontFamily: fontsMedium,
                color: lightColorScheme.onSurface),
            labelMedium: TextStyle(
                fontSize: 14,
                fontFamily: fontsMedium,
                color: lightColorScheme.onSurface),
            labelLarge: TextStyle(
                fontSize: 14,
                fontFamily: fontsMedium,
                color: lightColorScheme.onSurface),
            displayLarge: TextStyle(
                fontSize: 45,
                fontFamily: fontsRegular,
                color: lightColorScheme.onSurface),
            displayMedium: TextStyle(
                fontSize: 36,
                fontFamily: fontsRegular,
                color: lightColorScheme.onSurface),
            displaySmall: TextStyle(
                fontSize: 32,
                fontFamily: fontsRegular,
                color: lightColorScheme.onSurface),
            headlineLarge: TextStyle(
                fontSize: 32,
                fontFamily: fontsRegular,
                color: lightColorScheme.onSurface),
            headlineMedium: TextStyle(
                fontSize: 28,
                fontFamily: fontsRegular,
                color: lightColorScheme.onSurface),
            headlineSmall: TextStyle(
                fontSize: 24,
                fontFamily: fontsRegular,
                color: lightColorScheme.onSurface),
            titleLarge: TextStyle(
                fontSize: 22,
                fontFamily: fontsMedium,
                color: lightColorScheme.onSurface),
            titleMedium: TextStyle(
                fontSize: 16,
                fontFamily: fontsMedium,
                color: lightColorScheme.onSurface),
            titleSmall: TextStyle(
                fontSize: 14,
                fontFamily: fontsMedium,
                color: lightColorScheme.onSurface)));
  }
}
