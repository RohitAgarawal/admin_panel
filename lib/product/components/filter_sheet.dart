import 'package:flutter/material.dart';

class FilterSheet extends StatefulWidget {
  final String currentSort;
  final RangeValues currentPriceRange;
  final Function(String) onSortChanged;
  final Function(RangeValues) onPriceRangeChanged;
  final VoidCallback onApply;
  final VoidCallback onReset;

  const FilterSheet({
    super.key,
    required this.currentSort,
    required this.currentPriceRange,
    required this.onSortChanged,
    required this.onPriceRangeChanged,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Filters",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: widget.onReset,
                child: Text(
                  "Reset",
                  style: TextStyle(color: Colors.red.shade400),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            "Sort By",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: [
              _buildSortChip("Newest First", "newest"),
              _buildSortChip("Oldest First", "oldest"),
              _buildSortChip("Price: Low to High", "price_asc"),
              _buildSortChip("Price: High to Low", "price_desc"),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            "Price Range",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          RangeSlider(
            values: widget.currentPriceRange,
            min: 0,
            max: 1000000000, // Adjust max based on your data
            divisions: 100,
            activeColor: Colors.green.shade700,
            inactiveColor: Colors.green.shade100,
            labels: RangeLabels(
              "₹${widget.currentPriceRange.start.round()}",
              "₹${widget.currentPriceRange.end.round()}",
            ),
            onChanged: widget.onPriceRangeChanged,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "₹${widget.currentPriceRange.start.round()}",
                style: TextStyle(color: Colors.grey.shade600),
              ),
              Text(
                "₹${widget.currentPriceRange.end.round()}+",
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Apply Filters",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, String value) {
    final isSelected = widget.currentSort == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) {
          widget.onSortChanged(value);
        }
      },
      selectedColor: Colors.green.shade700,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      backgroundColor: Colors.grey.shade100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? Colors.green.shade700 : Colors.transparent,
        ),
      ),
    );
  }
}
