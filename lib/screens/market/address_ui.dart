import 'package:flutter/material.dart';

import '../../theme/colors.dart';

class AddressModal extends StatefulWidget {
  const AddressModal({super.key});

  @override
  _AddressModalState createState() => _AddressModalState();
}

class _AddressModalState extends State<AddressModal> {
  final TextEditingController _addressController = TextEditingController();

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _addressController,
              minLines: 3,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Enter Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
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
                Spacer(),
                FilledButton.tonal(
                  onPressed: () {
                    String address = _addressController.text.trim();
                    if (address.isEmpty) {
                      return;
                    }
                    Navigator.of(context).pop(address);
                  },
                  style: FilledButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
    );
  }
}
