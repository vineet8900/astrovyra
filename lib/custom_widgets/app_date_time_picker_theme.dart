import 'package:flutter/material.dart';

class AppDateTimePickerTheme {
  AppDateTimePickerTheme._();

  static Color get _primary => Colors.blue.shade700;

  static ThemeData pickerTheme(
    BuildContext context, {
    /// Kundli matching: no ring / primary tint on "today"; selected day still uses blue fill.
    bool neutralTodayInCalendar = false,
  }) {
    final Color p = _primary;
    ThemeData theme = Theme.of(context).copyWith(
      colorScheme: ColorScheme.light(
        primary: p,
        onPrimary: Colors.white,
        surface: Colors.white,
        onSurface: Colors.black,
      ),
      dialogTheme: DialogThemeData(backgroundColor: Colors.white),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: p),
      ),
      timePickerTheme: TimePickerThemeData(
        dayPeriodColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) return p;
          return Colors.grey.shade200;
        }),
        dayPeriodTextColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) return Colors.white;
          return Colors.black;
        }),
      ),
    );
    if (neutralTodayInCalendar) {
      final Color onSurface = theme.colorScheme.onSurface;
      // Same grey as disabled / out-of-range days (today is never selectable in Kundli).
      final Color todayLikeDisabled =
          onSurface.withValues(alpha: 0.38);
      theme = theme.copyWith(
        datePickerTheme: DatePickerThemeData(
          todayBorder: BorderSide.none,
          todayBackgroundColor:
              WidgetStateProperty.resolveWith((Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) return null;
            return Colors.transparent;
          }),
          todayForegroundColor:
              WidgetStateProperty.resolveWith((Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) return null;
            return todayLikeDisabled;
          }),
        ),
      );
    }
    return theme;
  }

  static Widget wrap(
    BuildContext context,
    Widget? child, {
    bool neutralTodayInCalendar = false,
  }) {
    return Theme(
      data: pickerTheme(
        context,
        neutralTodayInCalendar: neutralTodayInCalendar,
      ),
      child: child ?? const SizedBox.shrink(),
    );
  }
}
