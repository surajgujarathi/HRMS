import 'package:equatable/equatable.dart';
import 'package:flutter_app/features/profile/models/holiday_model.dart';

abstract class HolidayState extends Equatable {
  const HolidayState();

  @override
  List<Object?> get props => [];
}

class HolidayInitial extends HolidayState {}

class HolidayLoading extends HolidayState {}

class HolidayLoaded extends HolidayState {
  final List<HolidayModel> holidays;

  const HolidayLoaded(this.holidays);

  @override
  List<Object?> get props => [holidays];
}

class HolidayError extends HolidayState {
  final String message;

  const HolidayError(this.message);

  @override
  List<Object?> get props => [message];
}
