import 'package:flutter_bloc/flutter_bloc.dart';
part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeState(isDark: true));

  void setTheme(bool isDark) => emit(ThemeState(isDark: isDark));

  void toggleTheme() => emit(ThemeState(isDark: !state.isDark));
}
