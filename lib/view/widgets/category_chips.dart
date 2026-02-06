import 'package:flutter/material.dart';
import 'package:smart_shop/data/mock_data.dart';
import 'package:smart_shop/utils/app_responsive.dart';
import 'package:smart_shop/utils/app_textstyles.dart';

class CategoryChips extends StatefulWidget {
  final EdgeInsetsGeometry? padding;
  final List<String>? categories;
  final int? selectedIndex;
  final ValueChanged<int>? onSelected;
  const CategoryChips({
    super.key,
    this.padding,
    this.categories,
    this.selectedIndex,
    this.onSelected,
  });

  @override
  State<CategoryChips> createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<CategoryChips> {
  int? _internalSelectedIndex;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labels = widget.categories ??
        mockCategories.map((category) => category.name).toList();
    final spacing = AppResponsive.itemSpacing(context);
    final selectedIndex = widget.selectedIndex ?? _internalSelectedIndex ?? 0;
    final chipWidgets = List.generate(
      labels.length,
      (index) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: ChoiceChip(
          label: Text(
            labels[index],
            style: AppTextStyles.withColor(
              selectedIndex == index
                  ? AppTextStyles.withWeight(
                      AppTextStyles.bodySmall,
                      FontWeight.w600,
                    )
                  : AppTextStyles.bodySmall,
              selectedIndex == index
                  ? Colors.white
                  : isDark
                  ? Colors.grey[300]!
                  : Colors.grey[600]!,
            ),
          ),
          selected: selectedIndex == index,
          onSelected: (bool selected) {
            setState(() {
              _internalSelectedIndex =
                  selected ? index : _internalSelectedIndex ?? index;
            });
            widget.onSelected?.call(index);
          },
          selectedColor: Theme.of(context).primaryColor,
          backgroundColor: isDark ? Colors.grey[800] : Colors.grey[100],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: selectedIndex == index ? 2 : 0,
          pressElevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          labelPadding: const EdgeInsets.symmetric(vertical: 1, horizontal: 4),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          side: BorderSide(
            color: selectedIndex == index
                ? Colors.transparent
                : isDark
                ? Colors.grey[700]!
                : Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
    );

    return Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: AppResponsive.isDesktop(context)
          ? Wrap(
              spacing: spacing,
              runSpacing: spacing / 2,
              children: chipWidgets,
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: chipWidgets
                    .map((chip) =>
                        Padding(padding: EdgeInsets.only(right: spacing), child: chip))
                    .toList(),
              ),
            ),
    );
  }
}
