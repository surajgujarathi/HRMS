import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app/core/constants/app_colors.dart';
import 'package:flutter_app/features/profile/cubit/holiday_cubit.dart';
import 'package:flutter_app/features/profile/cubit/holiday_state.dart';
import 'package:flutter_app/features/profile/models/holiday_model.dart';

class HolidayCalendarPage extends StatelessWidget {
  const HolidayCalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HolidayCubit()..fetchHolidays(),
      child: const _HolidayCalendarView(),
    );
  }
}

class _HolidayCalendarView extends StatefulWidget {
  const _HolidayCalendarView();

  @override
  State<_HolidayCalendarView> createState() => _HolidayCalendarViewState();
}

class _HolidayCalendarViewState extends State<_HolidayCalendarView> {
  String searchText = "";
  int selectedDay = DateTime.now().day;
  DateTime currentMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: BlocBuilder<HolidayCubit, HolidayState>(
              builder: (context, state) {
                if (state is HolidayLoading || state is HolidayInitial) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primaryPurple));
                } else if (state is HolidayError) {
                  return Center(child: Text("Error: ${state.message}"));
                } else if (state is HolidayLoaded) {
                  final holidays = state.holidays;

                  // Filter for holidays in the selected year
                  final displayHolidays = holidays.where((h) {
                    final matchSearch = h.name.toLowerCase().contains(searchText.toLowerCase());
                    final matchYear = h.dateFrom != null && h.dateFrom!.year == currentMonth.year;
                    return matchSearch && matchYear;
                  }).toList();

                  // Sort by date
                  displayHolidays.sort((a, b) => (a.dateFrom ?? DateTime(0)).compareTo(b.dateFrom ?? DateTime(0)));

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCalendarCard(holidays),
                        const SizedBox(height: 24),
                        _buildSearchBar(),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Holidays ${currentMonth.year}",
                              style:  TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.indigo.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                "${displayHolidays.length} Holidays",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.indigo,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (displayHolidays.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.event_busy_outlined, size: 48, color: AppColors.textSecondary.withOpacity(0.3)),
                                  const SizedBox(height: 12),
                                  Text(
                                    "No holidays found for ${currentMonth.year}.",
                                    style: const TextStyle(color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ...displayHolidays.map((h) => _buildHolidayCard(h)),
                        const SizedBox(height: 30),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.indigo, AppColors.brightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
              ),
              const Expanded(
                child: Text(
                  'Holidays Calendar',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 20),
          _buildYearDropdown(),
        ],
      ),
    );
  }

  Widget _buildYearDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color?.withOpacity(0.2) ?? Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: currentMonth.year,
          isExpanded: true,
          dropdownColor: AppColors.indigo,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          selectedItemBuilder: (context) {
            return List.generate(10, (index) {
              final year = DateTime.now().year - 5 + index;
              return Center(
                child: Text(
                  "Selected Year: $year",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              );
            });
          },
          items: List.generate(10, (index) {
            final year = DateTime.now().year - 5 + index;
            return DropdownMenuItem(
              value: year,
              child: Text(
                year.toString(),
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
            );
          }),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                currentMonth = DateTime(val, currentMonth.month, currentMonth.day);
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Theme.of(context).shadowColor.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            searchText = value;
          });
        },
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        decoration: InputDecoration(
          hintText: "Search holidays...",
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4), fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Theme.of(context).primaryColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildCalendarCard(List<HolidayModel> holidays) {
    List<String> days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
    final daysInMonth = DateUtils.getDaysInMonth(currentMonth.year, currentMonth.month);
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1).weekday % 7;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Theme.of(context).shadowColor.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 14, color: AppColors.indigo),
                onPressed: () {
                  setState(() {
                    currentMonth = DateTime(currentMonth.year, currentMonth.month - 1, 1);
                  });
                },
              ),
              Text(
                DateFormat('MMMM yyyy').format(currentMonth),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.indigo),
                onPressed: () {
                  setState(() {
                    currentMonth = DateTime(currentMonth.year, currentMonth.month + 1, 1);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days.map((day) => Expanded(
              child: Center(
                child: Text(day, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary)),
              ),
            )).toList(),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daysInMonth + firstDayOfMonth,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
            itemBuilder: (context, index) {
              if (index < firstDayOfMonth) return const SizedBox.shrink();
              
              int day = index - firstDayOfMonth + 1;
              bool isSelected = day == selectedDay && DateTime.now().month == currentMonth.month && DateTime.now().year == currentMonth.year;
              
              final isHoliday = holidays.any((h) => 
                h.dateFrom != null && 
                h.dateFrom!.year == currentMonth.year && 
                h.dateFrom!.month == currentMonth.month && 
                h.dateFrom!.day == day
              );

              return GestureDetector(
                onTap: () => setState(() => selectedDay = day),
                child: Center(
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isHoliday ? AppColors.red.withOpacity(0.1) : (isSelected ? AppColors.indigo.withOpacity(0.1) : Colors.transparent),
                      borderRadius: BorderRadius.circular(10),
                      border: isHoliday ? Border.all(color: AppColors.red.withOpacity(0.3), width: 1) : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      day.toString(),
                      style: TextStyle(
                        color: isHoliday ? AppColors.red : (isSelected ? AppColors.indigo : Theme.of(context).colorScheme.onSurface),
                        fontWeight: (isHoliday || isSelected) ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          _buildSelectedHolidayInfo(holidays),
        ],
      ),
    );
  }

  Widget _buildHolidayCard(HolidayModel holiday) {
    final color = holiday.name.toLowerCase().contains('optional') ? Colors.amber : AppColors.indigo;
    final dateStr = holiday.dateFrom != null ? DateFormat('EEEE, dd MMM').format(holiday.dateFrom!) : "N/A";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Theme.of(context).shadowColor.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.celebration_rounded, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  holiday.name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Theme.of(context).colorScheme.onSurface),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(dateStr, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.textSecondary.withOpacity(0.5)),
        ],
      ),
    );
  }

  Widget _buildSelectedHolidayInfo(List<HolidayModel> holidays) {
    final selectedDateHolidays = holidays.where((h) =>
        h.dateFrom != null &&
        h.dateFrom!.year == currentMonth.year &&
        h.dateFrom!.month == currentMonth.month &&
        h.dateFrom!.day == selectedDay).toList();

    if (selectedDateHolidays.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.red.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, size: 16, color: AppColors.red),
              const SizedBox(width: 8),
              Text(
                "${selectedDay} ${DateFormat('MMM').format(currentMonth)}: ${selectedDateHolidays.first.name}",
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
