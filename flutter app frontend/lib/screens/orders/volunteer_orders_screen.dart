import 'package:flutter/material.dart';
import '../../services/order_service.dart';

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
    _tabController = TabController(length: 2, vsync: this);
    fetchOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchOrders() async {
    final data = await OrderService.getMyAssignedOrders(); 
    final id = await OrderService.getCurrentUserId(); // get my volunteer ID
    setState(() {
      allOrders = data;
      myId = id;
      isLoading = false;
    });
  }

  Future<void> markDelivered(String orderId) async {
    final success = await OrderService.confirmDelivery(orderId);
    if (success) {
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

  Widget buildList(String statusFilter) {
    final filtered = allOrders.where((o) => o['status'] == statusFilter && o['volunteerId'] == myId).toList();

    if (filtered.isEmpty) {
      return const Center(child: Text("No orders"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final order = filtered[index];
        final donation = order['donationId'];

        return Card(
          child: ListTile(
            title: Text(donation['description'] ?? 'No description'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Qty: ${donation['quantity']}"),
                Text("Status: ${order['status']}"),
                if (statusFilter == 'in-transit')
                  TextButton(
                    onPressed: () => markDelivered(order['_id']),
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
            Tab(text: "Active"),
            Tab(text: "Ended"),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                buildList('in-transit'),
                buildList('delivered'),
              ],
            ),
    );
  }
}
