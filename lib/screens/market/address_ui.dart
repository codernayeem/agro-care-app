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
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _addressController.dispose();
    _phoneController.dispose();
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
              TextFormField(
                controller: _addressController,
                minLines: 3,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Enter Address',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 3) {
                    return 'Please enter a valid address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Enter Phone Number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 10) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Radio(
                    value: true,
                    groupValue: true,
                    onChanged: (bool? value) {},
                  ),
                  const Text('COD Method'),
                ],
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
                    child: const Text('Place Order',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
