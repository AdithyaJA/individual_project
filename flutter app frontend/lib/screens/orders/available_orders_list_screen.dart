import 'package:flutter/material.dart';
import '../../services/order_service.dart';

class AvailableOrdersListScreen extends StatefulWidget {
  const AvailableOrdersListScreen({super.key});

  @override
  State<AvailableOrdersListScreen> createState() => _AvailableOrdersListScreenState();
}

class _AvailableOrdersListScreenState extends State<AvailableOrdersListScreen> {
  List<dynamic> availableOrders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAvailableOrders();
  }

  Future<void> fetchAvailableOrders() async {
    final data = await OrderService.getMyAvailableOrders();
    setState(() {
      availableOrders = data;
      isLoading = false;
    });
  }

  Future<void> claimDelivery(String donationId) async {
    final success = await OrderService.claimDelivery(donationId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Delivery claimed successfully")),
      );
      fetchAvailableOrders(); // refresh list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to claim delivery")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Available Orders")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : availableOrders.isEmpty
              ? const Center(child: Text("No available orders"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: availableOrders.length,
                  itemBuilder: (context, index) {
                    final order = availableOrders[index];
                    final donation = order['donationId'];

                    return Card(
                      child: ListTile(
                        title: Text(donation['description'] ?? 'No description'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Qty: ${donation['quantity']}"),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () => claimDelivery(donation['_id']),
                              child: const Text("Accept Delivery"),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
