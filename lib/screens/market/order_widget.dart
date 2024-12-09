import 'package:agro_care_app/services/firestore_services.dart';
import 'package:agro_care_app/theme/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sslcommerz/model/SSLCSdkType.dart';
import 'package:flutter_sslcommerz/model/SSLCTransactionInfoModel.dart';
import 'package:flutter_sslcommerz/model/SSLCommerzInitialization.dart';
import 'package:flutter_sslcommerz/model/SSLCurrencyType.dart';
import 'package:flutter_sslcommerz/sslcommerz.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:timeago/timeago.dart' as timeago;

class OrderWidget extends StatelessWidget {
  final Map<String, dynamic> data;
  const OrderWidget(this.data, {super.key});

  void onSuccessFullPay(String orderId) {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    var data_ref = FireStoreServices.db.collection('orders').doc(orderId);

    data_ref.update({'isPaid': true});
  }

  void onClickPay(String orderId, double total) {
    Sslcommerz sslcommerz = Sslcommerz(
        initializer: SSLCommerzInitialization(
            multi_card_name: "visa,master,bkash,nexus,nagad,rocket",
            currency: SSLCurrencyType.BDT,
            product_category: "Product",
            sdkType: SSLCSdkType.TESTBOX,
            store_id: "agroc6757350dc5689",
            store_passwd: "agroc6757350dc5689@ssl",
            total_amount: total,
            tran_id: "custom_transaction_id"));

    sslcommerz.payNow().then((value) {
      SSLCTransactionInfoModel result = value;
      try {
        print("result status ::${result.status ?? ""}");

        if (result.status!.toLowerCase() == "failed") {
          Fluttertoast.showToast(
            msg: "Transaction Failed",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        } else if (result.status!.toLowerCase() == "closed") {
          Fluttertoast.showToast(
            msg: "Canceled By User",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        } else {
          Fluttertoast.showToast(
              msg: "Amount paid ৳${result.amount ?? 0}",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: AppColors.primaryColor,
              textColor: Colors.white,
              fontSize: 16.0);
          onSuccessFullPay(orderId);
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const Divider(),
            _buildOrderDetails(),
            const SizedBox(height: 10),
            ExpansionTile(
              title: Text(
                'Order Items (${(data['items'] as Map<String, dynamic>).keys.length})',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              children: [
                _buildItemsList(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'Order ID: ${data['orderId']}',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        Chip(
          backgroundColor: _getStatusColor(data['status']),
          side: const BorderSide(color: Colors.white),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          label: Text(
            data['status'],
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _detailRow(Icons.location_on, 'Address', data['address']),
        _detailRow(Icons.phone, 'Contact', data['phone'] ?? 'Not Provided'),
        _detailRow(Icons.access_time, 'Ordered At',
            timeago.format((data['createdAt'] as Timestamp).toDate())),
        _detailRow2(Icons.attach_money, 'Total', '৳${data['total']}',
            highlight: true),
      ],
    );
  }

  Widget _buildItemsList() {
    return Column(
      children: data['items'].entries.map<Widget>((entry) {
        final item = entry.value;
        return ListTile(
          title: Text(
            item['name'],
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
          leading: CachedNetworkImage(
            imageUrl: item['image_url'],
            imageBuilder: (context, imageProvider) => Container(
              width: 50.0,
              height: 50.0,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            placeholder: (context, url) => Image.asset(
              'assets/images/placeholder.jpg',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Qty: ${item['quantity']}',
                  style: const TextStyle(fontSize: 11)),
              // const Spacer(),
              Text(
                '৳${item['current_price']} / Unit',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: Color.fromARGB(255, 40, 108, 42)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _detailRow(IconData icon, String label, String value,
      {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label: $value',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: highlight ? FontWeight.bold : FontWeight.w400,
                  color: highlight
                      ? const Color.fromARGB(255, 41, 122, 44)
                      : AppColors.grayDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow2(IconData icon, String label, String value,
      {bool highlight = false}) {
    bool isPaid = data['isPaid'] ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label: $value',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: highlight ? FontWeight.bold : FontWeight.w400,
                  color: highlight
                      ? const Color.fromARGB(255, 41, 122, 44)
                      : AppColors.grayDark),
            ),
          ),
          // paid status
          if (isPaid)
            // a text
            const Text(
              'Paid',
              style: TextStyle(
                color: Color.fromARGB(255, 41, 122, 44),
                fontWeight: FontWeight.bold,
              ),
            ),
          if (!isPaid)
            FilledButton.tonal(
              onPressed: () {
                onClickPay(data['orderId'], data['total']);
              },
              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                backgroundColor: Colors.white,
                side: const BorderSide(
                  color: Colors.blue,
                ),
              ),
              child: const Text(
                'Pay Online',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'pending':
        return const Color.fromARGB(255, 19, 145, 204);
      case 'canceled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
