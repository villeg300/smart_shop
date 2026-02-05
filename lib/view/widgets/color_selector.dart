import 'package:flutter/material.dart';

class ColorSelector extends StatefulWidget {
  const ColorSelector({super.key});

  @override
  State<ColorSelector> createState() => _ColorSelectorState();
}

class _ColorSelectorState extends State<ColorSelector> {
  int selectedColor = 0;

  @override
  Widget build(BuildContext context) {
    final colors = ["Blanc", "Bleu", "Noire", "Rose"];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(
        colors.length,
        (index) => ChoiceChip(
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
    );
  }
}
