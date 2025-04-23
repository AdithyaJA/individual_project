import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationPopup extends StatefulWidget {
  const NotificationPopup({super.key});

  @override
  State<NotificationPopup> createState() => _NotificationPopupState();
}

class _NotificationPopupState extends State<NotificationPopup> {
  List<dynamic> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    final data = await NotificationService.getMyNotifications();
    setState(() {
      notifications = data;
      isLoading = false;
    });
  }

  Future<void> deleteNotification(String id) async {
    await NotificationService.deleteNotification(id);
    loadNotifications();
  }

  Future<void> clearAll() async {
    await NotificationService.clearAllNotifications();
    loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 300,
        child:
            isLoading
                ? const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator()),
                )
                : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: const Text(
                        "Notifications",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: TextButton(
                        onPressed: clearAll,
                        child: const Text("Clear All"),
                      ),
                    ),
                    const Divider(height: 0),
                    if (notifications.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text("No notifications"),
                      )
                    else
                      ...notifications.map((n) {
                        return Dismissible(
                          key: Key(n['_id']),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => deleteNotification(n['_id']),
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color: Colors.red,
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          child: ListTile(
                            title: Text(n['message'] ?? 'No message'),
                            subtitle: Text(n['createdAt']?.toString() ?? ''),
                            dense: true,
                          ),
                        );
                      }).toList(),
                  ],
                ),
      ),
    );
  }
}
