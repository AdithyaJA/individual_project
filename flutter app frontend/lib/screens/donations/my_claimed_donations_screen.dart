import 'package:flutter/material.dart';
import 'package:frontend/services/order_service.dart';
import 'package:frontend/services/notification_service.dart';

class MyClaimedDonationsScreen extends StatefulWidget {
  const MyClaimedDonationsScreen({super.key});

  @override
  State<MyClaimedDonationsScreen> createState() =>
      _MyClaimedDonationsScreenState();
}

class _MyClaimedDonationsScreenState extends State<MyClaimedDonationsScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> claimed = [];
  bool isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchClaimedDonations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchClaimedDonations() async {
    final data = await OrderService.getMyOrders();
    setState(() {
      claimed = data;
      isLoading = false;
    });
  }

  Future<void> confirmReceived(String orderId) async {
    final success = await OrderService.confirmOrder(orderId);
    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Donation confirmed")));

      // Get related order and donation data
      final order = claimed.firstWhere((o) => o['_id'] == orderId);
      final donation = order['donationId'] ?? {};
      final donorId = donation['donorId'];
      final volunteerId = order['volunteerId'];
      final donationTitle = donation['description'] ?? 'your donation';

      // ✅ Notify Donor
      if (donorId != null) {
        await NotificationService.createNotification(
          userId: donorId,
          message:
              "Your donation '$donationTitle' has been confirmed by the receiver.",
          type: "donation",
        );
      }

      // ✅ Notify Volunteer
      if (volunteerId != null) {
        await NotificationService.createNotification(
          userId: volunteerId,
          message: "Receiver has confirmed delivery of '$donationTitle'.",
          type: "donation",
        );
      }

      fetchClaimedDonations();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Confirmation failed")));
    }
  }

  Widget _buildList(String statusFilter) {
    final filtered = claimed.where((o) => o['status'] == statusFilter).toList();

    if (filtered.isEmpty) {
      return const Center(child: Text("No donations in this category"));
    }

    return ListView.builder(
      itemCount: filtered.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final order = filtered[index];
        final donation = order['donationId'] ?? {}; // ✅ fallback if null
        final orderId = order['_id'];
        final status = order['status'];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  donation['description'] ?? 'No description',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text("Qty: ${donation['quantity'] ?? 'N/A'}"),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Status: $status",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    if (status == 'claimed')
                      TextButton(
                        onPressed: () => confirmReceived(orderId),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.green,
                        ),
                        child: const Text("Confirm Received"),
                      ),
                  ],
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
        title: const Text("My Claimed Donations"),
        backgroundColor: Colors.orange,
        bottom: TabBar(
          controller: _tabController,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          labelColor: Colors.white,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: "Claimed"),
            Tab(text: "On Delivery"),
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
                  _buildList('claimed'),
                  _buildList('in-transit'),
                  _buildList('delivered'),
                ],
              ),
    );
  }
}
