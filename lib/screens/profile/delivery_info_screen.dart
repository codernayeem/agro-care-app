import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../theme/colors.dart';

class DeliveryInfoScreen extends StatefulWidget {
  const DeliveryInfoScreen({super.key});

  @override
  State<DeliveryInfoScreen> createState() => _DeliveryInfoScreenState();
}

class _DeliveryInfoScreenState extends State<DeliveryInfoScreen> {
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

  Future<void> saveInfo() async {
    try {
      await FirebaseFirestore.instance
          .collection('saved_info')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({
        'address': _addressController.text.trim(),
        'phone': _phoneController.text.trim(),
      }).then((value) {
        // toast
        Fluttertoast.showToast(
          msg: 'Information saved successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: AppColors.primaryColor,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Your Delivery Informaton',
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
                        saveInfo();
                      }
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      backgroundColor: AppColors.primaryColor,
                    ),
                    child: const Text('Save Informaton',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
