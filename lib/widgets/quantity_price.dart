import 'package:agro_care_app/theme/colors.dart';
import 'package:flutter/material.dart';

class QuantityPriceRow extends StatefulWidget {
  final double singlePrice;
  final Future<bool> Function(int quantity) onAddToCart;

  const QuantityPriceRow({
    super.key,
    required this.singlePrice,
    required this.onAddToCart,
  });

  @override
  State<QuantityPriceRow> createState() => _QuantityPriceRowState();
}

class _QuantityPriceRowState extends State<QuantityPriceRow> {
  late int _quantity;
  String? _totalPrice;
  TextEditingController quantityText = TextEditingController(text: "0");

  @override
  void initState() {
    super.initState();
    _quantity = 1;
    quantityText.text = _quantity.toString();
    _totalPrice = (widget.singlePrice * _quantity).toStringAsFixed(2);
  }

  void _incrementQuantity() {
    setState(() {
      _quantity += 1;
      quantityText.text = _quantity.toString();
      _totalPrice = (widget.singlePrice * _quantity).toStringAsFixed(2);
    });
  }

  void _decrementQuantity() {
    setState(() {
      if (_quantity > 1) {
        _quantity -= 1;
      }
      quantityText.text = _quantity.toString();
      _totalPrice = (widget.singlePrice * _quantity).toStringAsFixed(2);
    });
  }

  void _submit() {
    _quantity = int.parse(quantityText.text);
    setState(() {
      if (_quantity < 1) {
        _quantity = 1;
        quantityText.text = _quantity.toString();
      }
      _totalPrice = (widget.singlePrice * _quantity).toStringAsFixed(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10, left: 14, right: 14),
          child: buildQuantityRow(),
        ),
        Padding(
            padding: const EdgeInsets.only(top: 14, bottom: 0),
            child: buildTotalPriceRow()),
      ],
    );
  }

  Row buildQuantityRow() {
    return Row(
      children: [
        const Padding(
          padding: EdgeInsets.only(right: 16.0),
          child: Text(
            "Quantity",
            style: TextStyle(color: Colors.black54, fontSize: 13),
          ),
        ),
        SizedBox(
          height: 36,
          width: 120,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              buildQuantityDownButton(),
              SizedBox(
                width: 36,
                child: Center(
                  child: TextField(
                    controller: quantityText,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (value) {
                      _submit();
                    },
                  ),
                ),
              ),
              buildQuantityUpButton()
            ],
          ),
        ),
      ],
    );
  }

  void onSuccess() {
    _quantity = 1;
    quantityText.text = _quantity.toString();
    _submit();

    SnackBar addedToCartSnackbar = SnackBar(
      content: const Text(
        "Added to Cart",
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: AppColors.primaryColor,
      duration: const Duration(seconds: 3),
      action: SnackBarAction(
        label: "View Cart",
        onPressed: () {
          // Navigator.push(context, MaterialPageRoute(builder: (context) {
          //   return Cart(hasBottomnav: false);
          // }));
        },
        textColor: AppColors.primaryColor,
        disabledTextColor: Colors.grey,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(addedToCartSnackbar);
  }

  Widget buildTotalPriceRow() {
    return Container(
      height: 50,
      color: AppColors.primaryColor.withOpacity(0.1),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8.0, right: 8.0),
            child: SizedBox(
              width: 75,
              child: Text(
                "Total Price",
                style: TextStyle(
                    color: Color.fromRGBO(103, 103, 103, 1), fontSize: 12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: Text(
              '৳${_totalPrice!}',
              style: const TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600),
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () async {
              if (_quantity != 0 && await widget.onAddToCart(_quantity)) {
                onSuccess();
              }
            },
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primaryColor.withOpacity(0.8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            ),
            child: const Text(
              "Add to Cart",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 14.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  buildQuantityUpButton() => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(36.0),
          color: Colors.white.withOpacity(.80),
          border:
              Border.all(color: Colors.blueGrey.withOpacity(.09), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.09),
              blurRadius: 5,
              spreadRadius: 0.0,
              offset: const Offset(0.0, 8.0),
            )
          ],
        ),
        width: 36,
        child: IconButton(
            icon: const Icon(Icons.add, size: 16, color: Colors.grey),
            onPressed: _incrementQuantity),
      );

  buildQuantityDownButton() => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(36.0),
          color: Colors.white.withOpacity(.80),
          border:
              Border.all(color: Colors.blueGrey.withOpacity(.09), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.09),
              blurRadius: 5,
              spreadRadius: 0.0,
              offset: const Offset(0.0, 8.0),
            )
          ],
        ),
        width: 36,
        child: IconButton(
            icon: const Icon(Icons.remove, size: 16, color: Colors.grey),
            onPressed: _decrementQuantity),
      );
}
