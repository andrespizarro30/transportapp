part of 'language_cubit.dart';

sealed class LanguageState {
  const LanguageState();

  @override
  List<Object> get props => [];
}

final class LanguageInitial extends LanguageState {}

final class LanguageChanged extends LanguageState {
  final String languageCode;
  const LanguageChanged(this.languageCode);
}
