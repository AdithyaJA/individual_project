import 'package:flutter/material.dart';
import '../../services/order_service.dart';

class MyClaimedDonationsScreen extends StatefulWidget {
  const MyClaimedDonationsScreen({super.key});

  @override
  State<MyClaimedDonationsScreen> createState() => _MyClaimedDonationsScreenState();
}

class _MyClaimedDonationsScreenState extends State<MyClaimedDonationsScreen> with SingleTickerProviderStateMixin {
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Donation confirmed")),
      );
      fetchClaimedDonations();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Confirmation failed")),
      );
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
        final donation = filtered[index]['donationId'];
        final orderId = filtered[index]['_id'];
        final status = filtered[index]['status'];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(donation['description'] ?? 'No description'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Qty: ${donation['quantity']}"),
                Text("Status: $status"),
                if (status == 'claimed')
                  TextButton(
                    onPressed: () => confirmReceived(orderId),
                    child: const Text("Confirm Received"),
                  )
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
        title: const Text("My Claimed Donations"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Claimed"),
            Tab(text: "On Delivery"),
            Tab(text: "Ended"),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
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
