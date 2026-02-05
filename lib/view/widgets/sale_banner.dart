import 'package:flutter/material.dart';
import 'package:smart_shop/utils/app_responsive.dart';
import 'package:smart_shop/utils/app_textstyles.dart';

class SaleBanner extends StatelessWidget {
  final EdgeInsetsGeometry? margin;
  const SaleBanner({super.key, this.margin});

  @override
  Widget build(BuildContext context) {
    final spacing = AppResponsive.itemSpacing(context);
    return Container(
      margin: margin ?? EdgeInsets.zero,
      padding: EdgeInsets.all(spacing),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = AppResponsive.isMobile(context);
          final textBlock = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Profitez de votre",
                style: AppTextStyles.withColor(
                  AppTextStyles.h3,
                  Colors.white,
                ),
              ),
              Text(
                "Offre Spéciale",
                style: AppTextStyles.withColor(
                  AppTextStyles.withWeight(AppTextStyles.h2, FontWeight.bold),
                  Colors.white,
                ),
              ),
              Text(
                "Jusqu’à 40 %",
                style: AppTextStyles.withColor(
                  AppTextStyles.h3,
                  Colors.white,
                ),
              ),
            ],
          );

          final actionButton = ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: EdgeInsets.symmetric(horizontal: spacing, vertical: 12),
            ),
            child: Text("Acheter", style: AppTextStyles.buttonMedium),
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                textBlock,
                SizedBox(height: spacing),
                SizedBox(width: double.infinity, child: actionButton),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: textBlock),
              SizedBox(width: spacing),
              actionButton,
            ],
          );
        },
      ),
    );
  }
}
