import 'package:flutter/material.dart';
import '../../services/order_service.dart';

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
    final id = await OrderService.getCurrentUserId();
    setState(() {
      allOrders = data;
      myId = id;
      isLoading = false;
    });
  }

  Future<void> markDelivered(String orderId) async {
    final success = await OrderService.confirmDelivery(orderId);
    if (success) {
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

  Widget buildList(String statusFilter) {
    final filtered =
        allOrders
            .where(
              (o) => o['status'] == statusFilter && o['volunteerId'] == myId,
            )
            .toList();

    if (filtered.isEmpty) {
      return const Center(child: Text("No orders in this category"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final order = filtered[index];
        final donation = order['donationId'];

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
                  "Status: ${order['status']}",
                  style: const TextStyle(color: Colors.grey),
                ),
                if (statusFilter == 'in-transit')
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => markDelivered(order['_id']),
                      icon: const Icon(
                        Icons.check_circle_outline,
                        color: Colors.green,
                      ),
                      label: const Text("Mark as Delivered"),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.green,
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
          tabs: const [Tab(text: "Active"), Tab(text: "Ended")],
        ),
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.orange),
              )
              : TabBarView(
                controller: _tabController,
                children: [buildList('in-transit'), buildList('delivered')],
              ),
    );
  }
}
