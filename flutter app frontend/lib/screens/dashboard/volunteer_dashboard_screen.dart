import 'package:flutter/material.dart';
import '../orders/available_orders_list_screen.dart';
import '../orders/volunteer_orders_screen.dart';


class VolunteerDashboardScreen extends StatelessWidget {
  const VolunteerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Volunteer Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
  onPressed: () {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => const AvailableOrdersListScreen()));
  },
  child: Text("Available Orders"),
),
            const SizedBox(height: 20),
           ElevatedButton(
  onPressed: () {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => const VolunteerOrdersScreen()));
  },
  child: Text("My Orders"),
),
          ],
        ),
      ),
    );
  }
}
