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

      Map<String, int> order = {
        'HatchBack': 1,
        'Sedan': 2,
        'SUV(7 Seater)': 3,
        'RideSafe(CCTV+Wifi)': 4,
      };

      final sortedList = list
          .where((c) => order.containsKey(c.name)) 
          .toList()
        ..sort((a, b) {
          int aOrder = order[a.name] ?? 999;
          int bOrder = order[b.name] ?? 999;
          return aOrder.compareTo(bOrder);
        });

      const itemWidth = 90.0;
      const spacing = 19.0;

      return SizedBox(
        height: 105,
        width: double.infinity,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth =
                sortedList.length * itemWidth + (sortedList.length - 1) * spacing;

            if (totalWidth <= constraints.maxWidth) {
              return Center(
                child: Wrap(
                  spacing: spacing,
                  children: List.generate(
                    sortedList.length,
                    (i) => CategoryWidget(index: i, category: sortedList[i]),
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              itemCount: sortedList.length,
              separatorBuilder: (_, __) => const SizedBox(width: spacing),
              itemBuilder: (context, i) =>
                  CategoryWidget(index: i, category: sortedList[i]),
            );
          },
        ),
      );
    });
  }
}

