import 'package:flutter/material.dart';
import '../../widgets/notification_popup.dart';
import '../donations/available_donations_screen.dart';
import '../donations/my_claimed_donations_screen.dart';

class ReceiverDashboard extends StatefulWidget {
  const ReceiverDashboard({super.key});

  @override
  State<ReceiverDashboard> createState() => _ReceiverDashboardState();
}

class _ReceiverDashboardState extends State<ReceiverDashboard> {
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
          (_) => Positioned(
            top: kToolbarHeight + 10,
            right: 16,
            child: const NotificationPopup(),
          ),
    );

    overlay.insert(_popup!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5E9),
      appBar: AppBar(
        title: const Text("Receiver Dashboard"),
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
            const Icon(Icons.restaurant_menu, size: 64, color: Colors.orange),
            const SizedBox(height: 20),
            const Text(
              "Welcome, Receiver!",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AvailableDonationsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.fastfood),
              label: const Text("View Available Donations"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size.fromHeight(50),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MyClaimedDonationsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.check_circle),
              label: const Text("My Claimed Donations"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size.fromHeight(50),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
