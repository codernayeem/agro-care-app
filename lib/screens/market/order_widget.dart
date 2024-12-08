import 'package:agro_care_app/theme/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class OrderWidget extends StatelessWidget {
  final Map<String, dynamic> data;
  const OrderWidget(this.data, {super.key});

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
        _detailRow(Icons.attach_money, 'Total', '৳${data['total']}',
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
