import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'localization_event.dart';

part 'localization_state.dart';

class LocalizationBloc extends Bloc<LocalizationEvent, LocalizationState> {
  LocalizationBloc()
      : super(const LocalizationState(locale: Locale('en', 'US'))) {
    on<LocalizationChangedEvent>((event, emit) {
      emit(state.copyWith(locale: event.locale));
    });
  }
}
