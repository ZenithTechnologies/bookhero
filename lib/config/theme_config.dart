import 'package:flutter/material.dart';

final ThemeData bookHeroTheme = ThemeData(
  scaffoldBackgroundColor: Color(0xFFF9F9F9),
  primaryColor: Color(0xFF2D3142),
  colorScheme: ColorScheme.fromSeed(
    seedColor: Color(0xFFEF8354),
    primary: Color(0xFF2D3142),
    secondary: Color(0xFFEF8354),
    background: Color(0xFFF9F9F9),
    surface: Colors.white,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFF2D3142),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    iconTheme: IconThemeData(color: Colors.white),
  ),
  tabBarTheme: TabBarTheme(
    labelColor: Colors.white, // active tab label
    unselectedLabelColor: Color(0xFFCCCCCC), // inactive tab label
    indicator: UnderlineTabIndicator(
      borderSide: BorderSide(color: Color(0xFFEF8354), width: 2),
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFFEF8354),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: Color(0xFF2D3142)),
    bodyMedium: TextStyle(color: Color(0xFF4F5D75)),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: Color(0xFFEEEEEE),
    selectedColor: Color(0xFFEF8354),
    labelStyle: const TextStyle(
      color: Color(0xFF2D3142),
    ), // default unselected text
    secondaryLabelStyle: const TextStyle(
      color: Colors.white,
    ), // <--- selected text color
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    shape: StadiumBorder(),
    iconTheme: IconThemeData(),
    showCheckmark: false,
  ),
  searchBarTheme: SearchBarThemeData(
    backgroundColor: WidgetStateProperty.resolveWith((states) {
      return states.contains(WidgetState.focused)
          ? Colors.white
          : const Color(0xFFF0F0F0);
    }),
    overlayColor: WidgetStateProperty.all(Colors.transparent),
    elevation: WidgetStateProperty.resolveWith((states) {
      return states.contains(WidgetState.focused) ? 4.0 : 1.0;
    }),
    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    side: WidgetStateProperty.resolveWith((states) {
      return states.contains(WidgetState.focused)
          ? const BorderSide(color: Color(0xFFEF8354), width: 2)
          : const BorderSide(color: Colors.transparent);
    }),
    hintStyle: WidgetStateProperty.all(
      const TextStyle(color: Color(0xFF4F5D75)),
    ),
    textStyle: WidgetStateProperty.all(
      const TextStyle(color: Color(0xFF2D3142), fontWeight: FontWeight.w500),
    ),
  ),

  splashColor: Colors.transparent,
  highlightColor: Colors.transparent,
  hoverColor: Colors.transparent,
);
