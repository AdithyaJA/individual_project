import 'package:flutter/material.dart';
import '../donations/available_donations_screen.dart';
import '../donations/my_claimed_donations_screen.dart';

class ReceiverDashboard extends StatelessWidget {
  const ReceiverDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Receiver Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AvailableDonationsScreen()),
                );
              },
              icon: const Icon(Icons.fastfood),
              label: const Text("View Available Donations"),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyClaimedDonationsScreen()),
                );
              },
              icon: const Icon(Icons.check_circle),
              label: const Text("My Claimed Donations"),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            ),
          ],
        ),
      ),
    );
  }
}
