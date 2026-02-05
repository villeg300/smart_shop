import 'package:flutter/material.dart';

class ColorSelector extends StatefulWidget {
  const ColorSelector({super.key});

  @override
  State<ColorSelector> createState() => _ColorSelectorState();
}

class _ColorSelectorState extends State<ColorSelector> {
  @override
  Widget build(BuildContext context) {
    int selectedColor = 0;
    final colors = ["Blanc", "Bleu", "Noire", "Rose"];
    return Row(
      children: List.generate(
        colors.length,
        (index) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(colors[index]),
            selected: selectedColor == index,
            onSelected: (bool selected) {
              setState(() {
                selectedColor = selected ? index : selectedColor;
              });
            },
            selectedColor: Theme.of(context).primaryColor,
            labelStyle: TextStyle(
              color: selectedColor == index ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
