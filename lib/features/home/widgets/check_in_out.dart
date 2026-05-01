import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CheckInOutCard extends StatefulWidget {
  const CheckInOutCard({super.key});

  @override
  State<CheckInOutCard> createState() => _CheckInOutCardState();
}

class _CheckInOutCardState extends State<CheckInOutCard> {
  DateTime? clockInTime;
  DateTime? clockOutTime;

  bool isCheckedIn = false;
  double progress = 0.0; // working hours % (0 to 1)
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel(); // cancel timer when widget is destroyed
    super.dispose();
  }

  String formatTime(DateTime? time) {
    if (time == null) return '--:--';
    return DateFormat.jm().format(time);
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes % 60);
    final seconds = twoDigits(duration.inSeconds % 60);
    return "$hours:$minutes:$seconds";
  }

  Duration getWorkingDuration() {
    if (clockInTime != null) {
      final end = clockOutTime ?? DateTime.now(); // live timer
      return end.difference(clockInTime!);
    }
    return Duration.zero;
  }

  void handleCheckInOut() {
    setState(() {
      if (!isCheckedIn) {
        // Check In
        clockInTime = DateTime.now();
        clockOutTime = null;
        progress = 0.0;

        // Start live timer
        _timer = Timer.periodic(const Duration(seconds: 1), (_) {
          if (!mounted) return;
          setState(() {
            final workingDuration = getWorkingDuration();
            progress = workingDuration.inSeconds / (8 * 3600);
            if (progress > 1.0) progress = 1.0;
          });
        });
      } else {
        // Check Out
        clockOutTime = DateTime.now();
        _timer?.cancel(); // stop timer
        final workingDuration = getWorkingDuration();
        progress = workingDuration.inSeconds / (8 * 3600);
        if (progress > 1.0) progress = 1.0;
      }
      isCheckedIn = !isCheckedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    double size = 150;
    double strokeWidth = 10;
    double radius = (size / 7) - (strokeWidth / 7);
    double angle = (2 * math.pi * progress) - math.pi / 2;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // Time & Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Time',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat.jm().format(DateTime.now()),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Date',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('d MMM yyyy').format(DateTime.now()),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Circular Progress
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: size,
                width: size,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: strokeWidth,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation(
                    Color.fromARGB(255, 76, 175, 80),
                  ),
                ),
              ),
              if (clockInTime != null)
                Positioned(
                  left: (size / 2) + radius * math.cos(angle) - 10,
                  top: (size / 2) + radius * math.sin(angle) - 7,
                  child: Container(
                    width: 0,
                    height: 0,
                    decoration: BoxDecoration(
                      // color: const Color.fromARGB(255, 242, 245, 242),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                  ),
                ),
              Column(
                children: [
                  Text(
                    formatDuration(getWorkingDuration()),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Working Hours',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Clock In / Out Times
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'Clock In',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatTime(clockInTime),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'Clock Out',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatTime(clockOutTime),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Check In / Out Button
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: isCheckedIn ? Colors.red : Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: handleCheckInOut,
              icon: Icon(
                isCheckedIn ? Icons.login : Icons.logout,
                size: 20,
                color: Colors.white,
              ),
              label: Text(
                isCheckedIn ? 'Check Out' : 'Check In',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
