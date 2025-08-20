import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/category_widget.dart';
import 'package:ride_sharing_user_app/features/home/controllers/category_controller.dart';
import 'package:ride_sharing_user_app/features/home/widgets/category_shimmer.dart';
import 'package:ride_sharing_user_app/features/parcel/screens/parcel_screen.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/features/set_destination/screens/set_destination_screen.dart';



class CategoryView extends StatelessWidget {
  const CategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CategoryController>(builder: (categoryController){
      return SizedBox(
        height: 105, width: Get.width,
        child: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          children: [
            categoryController.categoryList != null ?
            categoryController.categoryList!.isNotEmpty ?
            ListView.builder(
                shrinkWrap: true,
                itemCount: categoryController.categoryList!.length,
                padding: EdgeInsets.zero,
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return CategoryWidget(index: index,
                      category: categoryController.categoryList![index]);
                }
            ) :
            const SizedBox():
            const CategoryShimmer(),

          ],
        ),
      );
      // return ButtonWidget(
      //         buttonText: 'Book your Ride',
      //         // radius: 50,
      //         onPressed: () {
      //           Get.to(() => const SetDestinationScreen());
      //         },
      //       );
    });
  }
}
