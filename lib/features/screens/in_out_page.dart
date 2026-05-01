import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InOutReportPage extends StatefulWidget {
  const InOutReportPage({super.key});

  @override
  State<InOutReportPage> createState() => _InOutReportPageState();
}

class _InOutReportPageState extends State<InOutReportPage> {
  DateTime? fromDate;
  DateTime? toDate;

  final List<Map<String, dynamic>> attendanceData = [
    {
      "date": DateTime(2026, 2, 18),
      "checkIn": "09:05 AM",
      "checkOut": "06:02 PM",
      "status": "Present",
    },
    {
      "date": DateTime(2026, 2, 19),
      "checkIn": "09:45 AM",
      "checkOut": "06:00 PM",
      "status": "Late",
    },
    {
      "date": DateTime(2026, 2, 20),
      "checkIn": "--",
      "checkOut": "--",
      "status": "Absent",
    },
  ];

  Color getStatusColor(String status) {
    switch (status) {
      case "Present":
        return Colors.green;
      case "Late":
        return Colors.orange;
      case "Absent":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  int getTotal(String status) {
    return attendanceData.where((e) => e["status"] == status).length;
  }

  Future<void> pickDate(bool isFrom) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isFrom) {
          fromDate = picked;
        } else {
          toDate = picked;
        }
      });
    }
  }

  Widget dateField(String text, VoidCallback onTap) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      height: 55,
      decoration: BoxDecoration(
        color: const Color(0xffE5EAF3),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text("Select"),
          ),
        ],
      ),
    );
  }

  Widget summaryCard(String title, int count, Color color) {
    return Container(
      width: 100,
      height: 80,
      decoration: BoxDecoration(
        color: color.withOpacity(.15),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "$count",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 5),
          Text(title, style: TextStyle(color: color)),
        ],
      ),
    );
  }

  Widget attendanceTile(Map<String, dynamic> item) {
    Color statusColor = getStatusColor(item["status"]);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xffE5EAF3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: statusColor.withOpacity(.2),
            child: Icon(Icons.access_time, color: statusColor),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('dd MMM yyyy').format(item["date"]),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text("In: ${item["checkIn"]}"),
                Text("Out: ${item["checkOut"]}"),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(item["status"], style: TextStyle(color: statusColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF3F5FA),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Icon(Icons.menu),
                  Text(
                    "In/Out Report",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: Icon(Icons.add, color: Colors.white),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              /// DATE FILTER
              dateField(
                fromDate == null
                    ? "From Date"
                    : DateFormat('dd MMM yyyy').format(fromDate!),
                () => pickDate(true),
              ),

              const SizedBox(height: 15),

              dateField(
                toDate == null
                    ? "To Date"
                    : DateFormat('dd MMM yyyy').format(toDate!),
                () => pickDate(false),
              ),

              const SizedBox(height: 30),

              /// SUMMARY
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  summaryCard("Present", getTotal("Present"), Colors.green),
                  summaryCard("Late", getTotal("Late"), Colors.orange),
                  summaryCard("Absent", getTotal("Absent"), Colors.red),
                ],
              ),

              const SizedBox(height: 25),

              /// LIST
              Expanded(
                child: ListView.builder(
                  itemCount: attendanceData.length,
                  itemBuilder: (context, index) {
                    return attendanceTile(attendanceData[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
