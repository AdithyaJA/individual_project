import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/donation_service.dart';
import '../../firebase/image_upload.dart';

class EditDonationScreen extends StatefulWidget {
  final Map<String, dynamic> donation;

  const EditDonationScreen({super.key, required this.donation});

  @override
  State<EditDonationScreen> createState() => _EditDonationScreenState();
}

class _EditDonationScreenState extends State<EditDonationScreen> {
  late TextEditingController descriptionController;
  late TextEditingController quantityController;
  DateTime? selectedDateTime;
  File? selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    descriptionController = TextEditingController(text: widget.donation['description']);
    quantityController = TextEditingController(text: widget.donation['quantity'].toString());
    selectedDateTime = DateTime.tryParse(widget.donation['expiresAt'] ?? '');
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  Future<void> _pickDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDateTime ?? DateTime.now()),
      );

      if (pickedTime != null) {
        setState(() {
          selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _saveChanges() async {
    if (descriptionController.text.isEmpty ||
        quantityController.text.isEmpty ||
        selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required")),
      );
      return;
    }

    String imageUrl = widget.donation['image'];

    if (selectedImage != null) {
      final uploaded = await ImageUploader.uploadImage(selectedImage!);
      if (uploaded != null) imageUrl = uploaded;
    }

    final updated = await DonationService.updateDonation(
      widget.donation['_id'],
      {
        'description': descriptionController.text,
        'quantity': int.tryParse(quantityController.text) ?? 1,
        'expiresAt': selectedDateTime!.toIso8601String(),
        'image': imageUrl,
      },
    );

    if (updated) {
      Navigator.pushReplacementNamed(context, '/donation/my');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Update failed")),
      );
    }
  }

  Future<void> _deleteDonation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this donation?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
        ],
      ),
    );

    if (confirmed == true) {
      final deleted = await DonationService.deleteDonation(widget.donation['_id']);
      if (deleted) {
        Navigator.pushReplacementNamed(context, '/donation/my');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Delete failed")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Donation")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Image.network(
              widget.donation['image'],
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 100),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text("Change Image"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: "Description"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Quantity"),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickDateTime,
              icon: const Icon(Icons.timer),
              label: Text(
                selectedDateTime == null
                    ? "Pick Expiry Time"
                    : selectedDateTime.toString(),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _deleteDonation,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text("Delete"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveChanges,
                    child: const Text("Save"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
