import 'package:flutter/material.dart';
import '../../services/donation_service.dart';

class DonationDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> donation;

  const DonationDetailsScreen({super.key, required this.donation});

  Future<void> _claimDonation(BuildContext context) async {
    final success = await DonationService.claimDonation(donation['_id']);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Donation claimed successfully")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to claim donation")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Donation Details")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              donation['description'] ?? 'No description',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text("Quantity: ${donation['quantity']}"),
            const SizedBox(height: 8),
            Text("Expires at: ${donation['expiresAt'] ?? 'N/A'}"),
            const SizedBox(height: 8),
            Text("Location: (${donation['location']['lat']}, ${donation['location']['lng']})"),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => _claimDonation(context),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text("Claim Donation"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
