import 'package:flutter/material.dart';
import 'package:weather_app/core/secure_storage.dart';
import 'package:weather_app/screens/main/reminders/reminder_modal.dart';
import 'package:weather_app/services/api_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:weather_app/widgets/custom_button.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  List<Map<String, dynamic>> reminders = [];
  bool loading = true;
  int toggleLoadingIndex = -1;

  @override
  void initState() {
    super.initState();
    fetchReminders();
  }

  Future<void> fetchReminders() async {
    setState(() => loading = true);
    try {
      final userId = await SecureStore.getUserId();
      final response = await ApiService.getRequest(
        "/reminderList",
        queryParameters: {"user_id": userId},
      );

      if (response.data['status'] == true) {
        reminders = List<Map<String, dynamic>>.from(response.data['data']);
      } else {
        Fluttertoast.showToast(msg: "No reminders found");
      }
    } catch (_) {
      Fluttertoast.showToast(msg: "Something went wrong");
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> deleteReminder(String id) async {
    try {
      final userId = await SecureStore.getUserId();
      final response = await ApiService.getRequest(
        "/reminderDelete",
        queryParameters: {"user_id": userId, "reminder_id": id},
      );

      if (response.data['status'] == true) {
        fetchReminders();
      }
    } catch (_) {
      Fluttertoast.showToast(msg: "Error deleting reminder");
    }
  }

  Future<void> toggleReminder(Map<String, dynamic> item, int index) async {
    try {
      setState(() => toggleLoadingIndex = index);
      await ApiService.postRequest(
        "/createReminder",
        body: {
          ...item,
          "reminder_id": item['id'],
          "r_status": item['r_status'] == 1 ? 0 : 1,
        },
      );
      await fetchReminders();
    } finally {
      setState(() => toggleLoadingIndex = -1);
    }
  }

  String getTimeRange(String? start, String? end) {
    if (start == null || end == null) return "Invalid time";
    final s = start
        .split(' ')[1]
        .substring(0, 5)
        .replaceFirst(RegExp(r'^0'), '');
    final e = end.split(' ')[1].substring(0, 5).replaceFirst(RegExp(r'^0'), '');
    return "$s to $e";
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF191919),
      appBar: AppBar(
        backgroundColor: const Color(0xFF191919),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Set your reminders",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ),
      body: reminders.isEmpty && loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 90),
              itemCount: reminders.length,
              itemBuilder: (_, index) {
                final item = reminders[index];
                final days = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
                final selectedDays = days.where((d) => item[d] == 1).toList();

                return GestureDetector(
                  onTap: () async {
                    final updated = await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => ReminderModal(
                        selectedReminder: item, 
                      ),
                    );

                    if (updated == true) {
                      fetchReminders();
                    }
                  },
                  child: Container(
                    height: 90,
                    width: width * 0.9,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A4949),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      children: [
                        /// Close Button
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => deleteReminder(item['id'].toString()),
                            child: Container(
                              height: 20,
                              width: 20,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 12,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Title & Time
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item['title'] ?? "Daily Practice",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 33),
                                  child: Text(
                                    getTimeRange(
                                      item['start_at'],
                                      item['end_at'],
                                    ),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const Spacer(),

                            /// Frequency & Toggle
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${item['repeat']}X ${selectedDays.length == 7 ? 'Every Day' : selectedDays.join(', ')}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                                toggleLoadingIndex == index
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Color(0xFFB72658),
                                        ),
                                      )
                                    : FlutterSwitch(
                                        width: 46,
                                        height: 22,
                                        toggleSize: 18,
                                        value: item['r_status'] == 1,
                                        borderRadius: 30,
                                        padding: 2,
                                        activeColor: Colors.grey.shade300,
                                        toggleColor: const Color(0xFFB72658),
                                        inactiveToggleColor: const Color(
                                          0xFF191919,
                                        ),
                                        onToggle: (_) =>
                                            toggleReminder(item, index),
                                      ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: Container(
        padding: EdgeInsets.all(15),
        child: CustomButton(
          title: "Create Reminder",
          height: 55,
          onPress: () async {
            final updated = await showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const ReminderModal(),
            );

            if (updated == true) fetchReminders();
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
