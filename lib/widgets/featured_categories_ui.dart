import 'package:agro_care_app/services/firestore_services.dart';
import 'package:agro_care_app/widgets/shimmer_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class HomeFeaturedCategories extends StatefulWidget {
  const HomeFeaturedCategories({Key? key}) : super(key: key);

  @override
  State<HomeFeaturedCategories> createState() => _HomeFeaturedCategoriesState();
}

class _HomeFeaturedCategoriesState extends State<HomeFeaturedCategories> {
  bool isReady = false;

  bool limit = true;
  int limitCount = 6;

  List<dynamic> featuredCategoryList = [];

  @override
  void initState() {
    super.initState();
    fetchFeaturedCategories();
  }

  Future<void> fetchFeaturedCategories() async {
    setState(() {
      isReady = false;
    });

    var ref = FireStoreServices.db.collection('categories');
    var querySnapshot = await ref.limit(limitCount).get();
    featuredCategoryList = querySnapshot.docs.map((doc) => doc.data()).toList();

    setState(() {
      isReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isReady) {
      return ShimmerHelper().buildHorizontalGridShimmerWithAxisCount(
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          item_count: 6,
          mainAxisExtent: 170.0);
    }

    if (featuredCategoryList.isNotEmpty) {
      //snapshot.hasData
      return GridView.builder(
          padding:
              const EdgeInsets.only(left: 8, right: 8, top: 13, bottom: 16),
          scrollDirection: Axis.horizontal,
          itemCount: featuredCategoryList.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: .42,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4),
          itemBuilder: (context, index) {
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              clipBehavior: Clip.hardEdge,
              elevation: 3,
              color: Colors.white,
              surfaceTintColor: Colors.white,
              child: InkWell(
                onTap: () {
                  // Navigator.push(context, MaterialPageRoute(builder: (context) {
                  //   return CategoryProducts(
                  //     slug: featuredCategoryList[index].slug,
                  //   );
                  // }));
                },
                splashColor:
                    const Color.fromARGB(255, 194, 194, 194).withOpacity(0.3),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: AspectRatio(
                          aspectRatio: 1,
                          child: ClipRRect(
                              borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(6), right: Radius.zero),
                              child: CachedNetworkImage(
                                placeholder: (context, url) => Image.asset(
                                  'assets/images/placeholder.jpg',
                                  fit: BoxFit.cover,
                                ),
                                imageUrl: featuredCategoryList[index]
                                    ['img_url'],
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ))),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          featuredCategoryList[index]['title'],
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          softWrap: true,
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
    }

    return SizedBox(
        height: 100,
        child: Center(
            child: Text(
          "No Category Found",
          style: TextStyle(color: Colors.grey[400]),
        )));
  }
}
