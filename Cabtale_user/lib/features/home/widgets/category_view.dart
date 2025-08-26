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
    return GetBuilder<CategoryController>(builder: (categoryController) {
      final list = categoryController.categoryList;

      if (list == null) {
        return const SizedBox(
          height: 105,
          child: CategoryShimmer(),
        );
      }
      if (list.isEmpty) {
        return const SizedBox(height: 105);
      }

      const itemWidth = 90.0; 
      const spacing = 13.0;

      return SizedBox(
        height: 105,
        width: double.infinity,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth =
                list.length * itemWidth + (list.length - 1) * spacing;

            if (totalWidth <= constraints.maxWidth) {
              return Center(
                child: Wrap(
                  spacing: spacing,
                  children: List.generate(
                    list.length,
                    (i) => CategoryWidget(index: i, category: list[i]),
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(width: spacing),
              itemBuilder: (context, i) =>
                  CategoryWidget(index: i, category: list[i]),
            );
          },
        ),
      );
    });
  }
}
