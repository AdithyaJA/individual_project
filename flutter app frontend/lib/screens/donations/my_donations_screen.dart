import 'package:flutter/material.dart';
import '../../services/donation_service.dart';

class MyDonationsScreen extends StatefulWidget {
  const MyDonationsScreen({super.key});

  @override
  State<MyDonationsScreen> createState() => _MyDonationsScreenState();
}

class _MyDonationsScreenState extends State<MyDonationsScreen> with SingleTickerProviderStateMixin {
  List<dynamic> donations = [];
  bool isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchDonations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchDonations() async {
    final data = await DonationService.getMyDonations();
    setState(() {
      donations = data;
      isLoading = false;
    });
  }

  Widget _buildDonationCard(Map<String, dynamic> donation) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/donation/edit',
          arguments: donation,
        ).then((_) => fetchDonations());
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10),
        elevation: 3,
        child: ListTile(
          leading: Image.network(
            donation['image'],
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.image),
          ),
          title: Text(donation['description']),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Qty: ${donation['quantity']}'),
              Text('Status: ${donation['status']}'),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTabContent(String statusFilter) {
    final filtered = donations.where((d) => d['status'] == statusFilter).toList();

    if (filtered.isEmpty) {
      return const Center(child: Text("No donations found"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return _buildDonationCard(filtered[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Donations'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'On Delivery'),
            Tab(text: 'Ended'),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                buildTabContent('pending'), // Active
                buildTabContent('claimed'), // On Delivery
                buildTabContent('confirmed'), // Ended
              ],
            ),
    );
  }
}
