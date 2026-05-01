// import 'package:equatable/equatable.dart';

// class AttendanceState extends Equatable {
//   final bool isCheckedIn;
//   final DateTime? checkInTime;
//   final DateTime? checkOutTime;
//   final Duration workedDuration;

//   const AttendanceState({
//     required this.isCheckedIn,
//     this.checkInTime,
//     this.checkOutTime,
//     required this.workedDuration,
//   });

//   factory AttendanceState.initial() {
//     return const AttendanceState(
//       isCheckedIn: false,
//       workedDuration: Duration.zero,
//     );
//   }

//   AttendanceState copyWith({
//     bool? isCheckedIn,
//     DateTime? checkInTime,
//     DateTime? checkOutTime,
//     Duration? workedDuration,
//   }) {
//     return AttendanceState(
//       isCheckedIn: isCheckedIn ?? this.isCheckedIn,
//       checkInTime: checkInTime ?? this.checkInTime,
//       checkOutTime: checkOutTime ?? this.checkOutTime,
//       workedDuration: workedDuration ?? this.workedDuration,
//     );
//   }

//   @override
//   List<Object?> get props => [
//     isCheckedIn,
//     checkInTime,
//     checkOutTime,
//     workedDuration,
//   ];
// }
