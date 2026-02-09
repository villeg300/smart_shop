import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_shop/controllers/store_controller.dart';
import 'package:smart_shop/utils/app_responsive.dart';
import 'package:smart_shop/utils/app_textstyles.dart';

class CategoryChips extends StatelessWidget {
  const CategoryChips({super.key});

  @override
  Widget build(BuildContext context) {
    final storeController = Get.find<StoreController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final spacing = AppResponsive.itemSpacing(context);

    return Obx(() {
      if (storeController.isLoadingCategories.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(),
          ),
        );
      }

      final categories = storeController.categories;
      final selectedSlug = storeController.selectedCategorySlug.value;

      final chipWidgets = categories.map((category) {
        final isSelected = category.slug == selectedSlug;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: ChoiceChip(
            label: Text(
              category.name,
              style: AppTextStyles.withColor(
                isSelected
                    ? AppTextStyles.withWeight(
                        AppTextStyles.bodySmall,
                        FontWeight.w600,
                      )
                    : AppTextStyles.bodySmall,
                isSelected
                    ? Colors.white
                    : isDark
                    ? Colors.grey[300]!
                    : Colors.grey[600]!,
              ),
            ),
            selected: isSelected,
            onSelected: (bool selected) {
              if (selected) {
                storeController.setCategory(category.slug);
              }
            },
            selectedColor: Theme.of(context).primaryColor,
            backgroundColor: isDark ? Colors.grey[800] : Colors.grey[100],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: isSelected ? 2 : 0,
            pressElevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            labelPadding: const EdgeInsets.symmetric(
              vertical: 1,
              horizontal: 4,
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            side: BorderSide(
              color: isSelected
                  ? Colors.transparent
                  : isDark
                  ? Colors.grey[700]!
                  : Colors.grey[300]!,
              width: 1,
            ),
          ),
        );
      }).toList();

      return AppResponsive.isDesktop(context)
          ? Wrap(
              spacing: spacing,
              runSpacing: spacing / 2,
              children: chipWidgets,
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: chipWidgets
                    .map(
                      (chip) => Padding(
                        padding: EdgeInsets.only(right: spacing),
                        child: chip,
                      ),
                    )
                    .toList(),
              ),
            );
    });
  }
}
