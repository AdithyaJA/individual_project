import 'package:flutter/material.dart';
import '../../services/donation_service.dart';
import '../../services/notification_service.dart';

class DonationDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> donation;

  const DonationDetailsScreen({super.key, required this.donation});

  Future<void> _claimDonation(BuildContext context) async {
    final success = await DonationService.claimDonation(donation['_id']);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Donation claimed successfully")),
      );

      // ✅ Notify donor with donation title
      final donorId = donation['donorId'];
      final title = donation['description'] ?? 'your donation';

      if (donorId != null) {
        await NotificationService.createNotification(
          userId: donorId,
          message: "Your donation '$title' has been claimed by a receiver.",
          type: 'donation',
        );
      }

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to claim donation")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5E9),
      appBar: AppBar(
        title: const Text("Donation Details"),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.fastfood, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            Text(
              donation['description'] ?? 'No description',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _infoRow("Quantity", donation['quantity']),
            _infoRow("Expires at", donation['expiresAt']),
            _infoRow(
              "Location",
              "(${donation['location']['lat']}, ${donation['location']['lng']})",
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _claimDonation(context),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text("Claim Donation"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value?.toString() ?? 'N/A')),
        ],
      ),
    );
  }
}
