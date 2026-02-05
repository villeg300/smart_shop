import 'package:flutter/material.dart';
import 'package:smart_shop/utils/app_textstyles.dart';

class SaleBanner extends StatelessWidget {
  const SaleBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
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
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: Text("Acheter", style: AppTextStyles.buttonMedium),
          ),
        ],
      ),
    );
  }
}
