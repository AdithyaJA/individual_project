import 'package:flutter/material.dart';
import '../../services/order_service.dart';
import '../../services/donation_service.dart';
import '../../services/notification_service.dart';

class VolunteerOrdersScreen extends StatefulWidget {
  const VolunteerOrdersScreen({super.key});

  @override
  State<VolunteerOrdersScreen> createState() => _VolunteerOrdersScreenState();
}

class _VolunteerOrdersScreenState extends State<VolunteerOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> allOrders = [];
  bool isLoading = true;
  String? myId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchOrders() async {
    final data = await OrderService.getMyAvailableAndAssignedOrders();
    final id = await OrderService.getCurrentUserId();
    setState(() {
      allOrders = data;
      myId = id;
      isLoading = false;
    });
  }

  Future<void> markDelivered(String orderId, String donationId) async {
    final success = await OrderService.confirmDelivery(orderId);
    final success2 = await DonationService.confirmDonationStatus(donationId);

    if (success && success2) {
      // 🔔 Fetch the order and donation info
      final order = allOrders.firstWhere((o) => o['_id'] == orderId);
      final donation = order['donationId'];
      final donationTitle = donation['description'] ?? 'your donation';

      final donorId = donation['donorId'];
      final receiverId = order['receiverId'];

      // 🔔 Notify Donor
      if (donorId != null) {
        await NotificationService.createNotification(
          userId: donorId,
          message: "Your donation '$donationTitle' has been delivered.",
          type: "donation",
        );
      }

      // 🔔 Notify Receiver
      if (receiverId != null) {
        await NotificationService.createNotification(
          userId: receiverId,
          message: "Your claimed donation '$donationTitle' has been delivered.",
          type: "donation",
        );
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Marked as delivered")));
      fetchOrders();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to update status")));
    }
  }

  Widget buildList(String filter) {
    final filtered =
        allOrders.where((o) {
          final status = o['status'];
          final vid = o['volunteerId'];
          if (filter == 'available') {
            return status == 'claimed' && vid == null;
          } else if (filter == 'accepted') {
            return status == 'in-transit' && vid == myId;
          } else if (filter == 'ended') {
            return status == 'delivered' && vid == myId;
          }
          return false;
        }).toList();

    if (filtered.isEmpty) {
      return const Center(child: Text("No orders"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final order = filtered[index];
        final donation = order['donationId'];
        final status = order['status'];

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  donation['description'] ?? 'No description',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text("Qty: ${donation['quantity']}"),
                const SizedBox(height: 6),
                Text(
                  "Status: $status",
                  style: const TextStyle(color: Colors.grey),
                ),
                if (filter == 'accepted')
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed:
                          () => markDelivered(order['_id'], donation['_id']),
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      label: const Text("Mark as Delivered"),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.green,
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5E9),
      appBar: AppBar(
        title: const Text("My Orders"),
        backgroundColor: Colors.orange,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          labelColor: Colors.white,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "Available"),
            Tab(text: "Accepted"),
            Tab(text: "Ended"),
          ],
        ),
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.orange),
              )
              : TabBarView(
                controller: _tabController,
                children: [
                  buildList('available'),
                  buildList('accepted'),
                  buildList('ended'),
                ],
              ),
    );
  }
}
