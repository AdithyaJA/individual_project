import 'package:flutter/material.dart';
import '../../services/order_service.dart';
import '../../services/donation_service.dart';

class VolunteerOrdersScreen extends StatefulWidget {
  const VolunteerOrdersScreen({super.key});

  @override
  State<VolunteerOrdersScreen> createState() => _VolunteerOrdersScreenState();
}

class _VolunteerOrdersScreenState extends State<VolunteerOrdersScreen> with SingleTickerProviderStateMixin {
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Marked as delivered")),
      );
      fetchOrders();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update status")),
      );
    }
  }

  Widget buildList(String filter) {
    final filtered = allOrders.where((o) {
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
          child: ListTile(
            title: Text(donation['description'] ?? 'No description'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Qty: ${donation['quantity']}"),
                Text("Status: $status"),
                if (filter == 'accepted')
                  TextButton(
                    onPressed: () => markDelivered(order['_id'], donation['_id']),
                    child: const Text("Mark as Delivered"),
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
      appBar: AppBar(
        title: const Text("My Orders"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Available"),
            Tab(text: "Accepted"),
            Tab(text: "Ended"),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
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
