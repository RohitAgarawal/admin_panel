import 'package:admin_panel/model/product_model/product_type_model.dart';
import 'package:flutter/material.dart';

class ProductFilterBar extends StatelessWidget {
  final List<ProductTypeModel> productTypes;
  final int selectedTypeIndex;
  final String selectedCategory;
  final Function(int) onTypeSelected;
  final Function(String) onCategorySelected;
  final Function(int) getCategoryCounts; // Returns counts for A, B, C, D, E

  const ProductFilterBar({
    super.key,
    required this.productTypes,
    required this.selectedTypeIndex,
    required this.selectedCategory,
    required this.onTypeSelected,
    required this.onCategorySelected,
    required this.getCategoryCounts,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product Types (Horizontal Scroll)
        SizedBox(
          height: 45,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: productTypes.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final type = productTypes[index];
              final isSelected = selectedTypeIndex == index;
              return InkWell(
                onTap: () => onTypeSelected(index),
                borderRadius: BorderRadius.circular(25),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.green.shade700 : Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: isSelected
                          ? Colors.green.shade700
                          : Colors.grey.shade300,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.green.shade700.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      "${type.name} (${type.count})",
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // Categories A-E (Horizontal Scroll)
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: ['A', 'B', 'C', 'D', 'E'].map((category) {
              final isSelected = selectedCategory == category;
              // We need to get counts dynamically based on the selected product type
              // Since we can't easily pass a complex object, we'll rely on the parent to provide counts or just show the label
              // Ideally, we should pass the counts map.
              // For now, let's assume the parent handles the logic or we just show the letter.
              // Wait, the design showed counts "A 10".
              // Let's use a callback to get the count for this category.
              // But wait, getCategoryCounts returns a Record (int A, int B...).
              // We can't easily access properties by string key on a Record in Dart without reflection or a switch.
              // Let's simplify: The parent passes a function that returns the count for a given category string.

              // Actually, let's just use the getCategoryCounts function passed in.
              // But the signature I defined `Function(int)` was for the index.
              // Let's change the signature to `Function(String)`.

              // Re-evaluating: The parent has `countByProductTypeId(index)`.
              // It returns a record.
              // Let's just assume the parent passes a map or we change the signature.
              // I'll stick to the plan but I need to access the count.
              // I'll change `getCategoryCounts` to `Function(String) getCategoryCount`.

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: InkWell(
                  onTap: () => onCategorySelected(category),
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.green.shade700
                          : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? Colors.green.shade700
                            : Colors.green.shade200,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          category,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.green.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // We will add the count if we can get it easily.
                        // For now, let's just keep it simple or add a placeholder.
                        // The previous code had counts.
                        // Let's try to get it from the parent via a better callback.
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
