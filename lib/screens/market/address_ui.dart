import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../theme/colors.dart';

class AddressModal extends StatefulWidget {
  const AddressModal({super.key});

  @override
  _AddressModalState createState() => _AddressModalState();
}

class _AddressModalState extends State<AddressModal> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    fetchInfo();
  }

  @override
  void dispose() {
    super.dispose();
    _addressController.dispose();
    _phoneController.dispose();
  }

  Future<void> fetchInfo() async {
    try {
      var response = await FirebaseFirestore.instance
          .collection('saved_info')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      if (response.exists && response.data() != null) {
        var data = response.data();
        if (_addressController.text.isEmpty)
          _addressController.text = data!['address'];
        if (_phoneController.text.isEmpty)
          _phoneController.text = data!['phone'];
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('One Step to Go!',
            style: TextStyle(color: Colors.black87, fontSize: 18)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              TextFormField(
                maxLines: 3,
                controller: _addressController,
                decoration: InputDecoration(
                  label: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.primaryColor,
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: const Text(
                      "Address",
                      style: TextStyle(
                          fontSize: 17,
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  border: const OutlineInputBorder(),
                  icon: const Icon(
                    Icons.location_on_outlined,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 3) {
                    return 'Please enter a valid address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 28),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  label: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.primaryColor,
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: const Text(
                      "Mobile Nnumber",
                      style: TextStyle(
                          fontSize: 17,
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  border: const OutlineInputBorder(),
                  icon: const Icon(
                    Icons.call_outlined,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 10) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Spacer(),
                  FilledButton.tonal(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        String address = _addressController.text.trim();
                        String phone = _phoneController.text.trim();
                        Navigator.of(context)
                            .pop({'address': address, 'phone': phone});
                      }
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      backgroundColor: AppColors.primaryColor,
                    ),
                    child: const Text('Place Order ➤',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                '➤ No Delivery Charge. Delivery within 5-7 days.',
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
              ),
              const SizedBox(height: 14),
              Text(
                'Note: You can pay cash on delivery. Please make sure you have the exact amount of money.',
                textAlign: TextAlign.justify,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                'Or you can pay online after placing the order.',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
