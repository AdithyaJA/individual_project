import 'package:flutter/material.dart';
import '../../services/order_service.dart';

class AvailableOrdersListScreen extends StatefulWidget {
  const AvailableOrdersListScreen({super.key});

  @override
  State<AvailableOrdersListScreen> createState() =>
      _AvailableOrdersListScreenState();
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
      fetchAvailableOrders();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to claim delivery")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5E9),
      appBar: AppBar(
        title: const Text("Available Orders"),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.orange),
              )
              : availableOrders.isEmpty
              ? const Center(
                child: Text(
                  "No available orders",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: availableOrders.length,
                itemBuilder: (context, index) {
                  final order = availableOrders[index];
                  final donation = order['donationId'];

                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.only(bottom: 16),
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
                          const SizedBox(height: 8),
                          Text("Qty: ${donation['quantity']}"),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => claimDelivery(donation['_id']),
                              icon: const Icon(Icons.delivery_dining),
                              label: const Text("Accept Delivery"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                textStyle: const TextStyle(fontSize: 16),
                              ),
                            ),
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
