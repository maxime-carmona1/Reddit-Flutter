part of 'localization_bloc.dart';

abstract class LocalizationEvent extends Equatable {
  const LocalizationEvent();
}

class LocalizationChangedEvent extends LocalizationEvent {
  const LocalizationChangedEvent({required this.locale});

  final Locale locale;

  @override
  List<Object> get props => [locale];
}
