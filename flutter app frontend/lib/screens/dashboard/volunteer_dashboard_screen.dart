import 'package:flutter/material.dart';
import '../../widgets/notification_popup.dart';
import '../orders/available_orders_list_screen.dart';
import '../orders/volunteer_orders_screen.dart';

class VolunteerDashboardScreen extends StatefulWidget {
  const VolunteerDashboardScreen({super.key});

  @override
  State<VolunteerDashboardScreen> createState() =>
      _VolunteerDashboardScreenState();
}

class _VolunteerDashboardScreenState extends State<VolunteerDashboardScreen> {
  OverlayEntry? _popup;

  void _toggleNotificationPopup(BuildContext context) {
    if (_popup != null) {
      _popup!.remove();
      _popup = null;
      return;
    }

    final overlay = Overlay.of(context);
    _popup = OverlayEntry(
      builder:
          (context) => Stack(
            children: [
              // 🔘 Click-outside to close
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    _popup?.remove();
                    _popup = null;
                  },
                  behavior: HitTestBehavior.translucent,
                ),
              ),
              // 🔔 Notification popup
              Positioned(
                top: kToolbarHeight + 10,
                right: 16,
                child: Material(
                  color: Colors.transparent,
                  child: const NotificationPopup(),
                ),
              ),
            ],
          ),
    );

    overlay.insert(_popup!);
  }

  @override
  void dispose() {
    _popup?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5E9),
      appBar: AppBar(
        title: const Text("Volunteer Dashboard"),
        backgroundColor: Colors.orange,
        centerTitle: true,
        actions: [
          Builder(
            builder:
                (context) => IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () => _toggleNotificationPopup(context),
                ),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.volunteer_activism,
              size: 64,
              color: Colors.orange,
            ),
            const SizedBox(height: 20),
            const Text(
              "Welcome, Volunteer!",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.delivery_dining),
                label: const Text("Available Orders"),
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AvailableOrdersListScreen(),
                      ),
                    ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.assignment_turned_in),
                label: const Text("My Orders"),
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const VolunteerOrdersScreen(),
                      ),
                    ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
