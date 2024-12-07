import 'package:agro_care_app/model/product_model.dart';
import 'package:agro_care_app/services/firestore_services.dart';
import 'package:flutter/material.dart';

import '../../widgets/product_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  var ref;
  var original_ref;

  var sortOptions = [
    'Default',
    'Price: Low to High',
    'Price: High to Low',
  ];

  var selectedSortOption = 'Default';

  String searchQuery = '';

  late TextEditingController _controller;

  List<Product> products = [];
  List<Product> filteredProducts = [];

  bool isFetching = true;

  @override
  void initState() {
    super.initState();
    original_ref = FireStoreServices.db.collection('products');
    ref = original_ref;
    _controller = TextEditingController();
    _controller.addListener(() async {
      if (searchQuery == _controller.text) return;
      setState(() {
        searchQuery = _controller.text;
      });
    });
    fetchProducts();
  }

  void fetchProducts() async {
    products.clear();
    final snapshot = await ref.get();
    if (snapshot.docs.isNotEmpty) {
      for (var doc in snapshot.docs) {
        products.add(
            Product.fromFirestore(doc.data() as Map<String, dynamic>, doc.id));
      }
    }

    setState(() {
      isFetching = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void onSortOptionChanged(String value) {
    if (value == selectedSortOption) return;
    selectedSortOption = value;
    switch (value) {
      case 'Price: Low to High':
        ref = original_ref.orderBy('current_price');
        break;
      case 'Price: High to Low':
        ref = original_ref.orderBy('current_price', descending: true);
        break;
      default:
        ref = original_ref;
    }
    setState(() {
      isFetching = true;
    });
    fetchProducts();
  }

  void onPressSort() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sort by'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: sortOptions
                .map((e) => RadioListTile(
                      title: Text(e),
                      value: e,
                      groupValue: selectedSortOption,
                      onChanged: (value) {
                        onSortOptionChanged(value.toString());
                        Navigator.pop(context);
                      },
                    ))
                .toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
        title: Container(
          height: 38,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(6),
          ),
          child: TextField(
            textAlign: TextAlign.left,
            textAlignVertical: TextAlignVertical.center,
            controller: _controller,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search here ...',
              hintStyle: const TextStyle(fontSize: 13),
              prefixIcon: const Icon(Icons.search, size: 16),
              isDense: true,
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 16),
                      onPressed: () {
                        _controller.clear();
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 6),
            ),
            maxLines: 1,
          ),
        ),
        actions: [
          IconButton(
            icon: Image.asset(
              "assets/icons/sort.png",
              color: Colors.black,
              height: 24,
            ),
            onPressed: () {
              onPressSort();
            },
          ),
        ],
      ),
      body: searchQuery.isEmpty
          ? const Center(child: Text('Search for products'))
          : isFetching
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Builder(builder: (context) {
                    filteredProducts = products
                        .where((product) => product.name
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase()))
                        .toList();
                    return GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                      ),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return MiniProductCard(
                            product: product, biggerAddButton: true);
                      },
                    );
                  }),
                ),
    );
  }
}
