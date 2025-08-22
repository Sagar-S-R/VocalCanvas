import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The main search bar
          TextField(
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: 18,
              color: theme.colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: 'search_artisans'.tr(),
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              prefixIcon: Icon(Icons.search, color: theme.iconTheme.color),
              filled: true,
              fillColor: theme.cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 20.0,
                horizontal: 24.0,
              ),
            ),
          ),
          const SizedBox(height: 40),

          // "Recent Searches" section
          _buildSectionHeader(context, 'recent_searches'.tr()),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12.0,
            runSpacing: 12.0,
            children: [
              _buildChip(context, 'Wooden Toys'),
              _buildChip(context, 'Mosaic Art'),
              _buildChip(context, 'Priya Sharma'),
              _buildChip(context, 'Pottery'),
            ],
          ),
          const SizedBox(height: 40),

          // "Browse by Category" section
          _buildSectionHeader(context, 'browse_by_category'.tr()),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 4, // Responsive: could use LayoutBuilder here too
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildCategoryCard(context, 'Ceramics', 'assets/Ceramic.jpg'),
              _buildCategoryCard(context, 'Glasswork', 'assets/Glass.jpg'),
              _buildCategoryCard(
                context,
                'Woodcraft',
                'assets/Wooden_Toys.jpeg',
              ),
              _buildCategoryCard(context, 'Mosaics', 'assets/Mosaic_Art.jpeg'),
            ],
          ),
        ],
      ),
    );
  }

  // Helper widget for section titles
  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Text(
      title,
      style:
          theme.textTheme.titleLarge?.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Lora',
          ) ??
          const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Lora',
          ),
    );
  }

  // Helper widget for the recent search chips
  Widget _buildChip(BuildContext context, String label) {
    final theme = Theme.of(context);
    return Chip(
      label: Text(
        label,
        style:
            theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ) ??
            const TextStyle(color: Colors.black),
      ),
      backgroundColor: theme.cardColor,
      side: BorderSide(color: theme.dividerColor),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  // Helper widget for the category cards
  Widget _buildCategoryCard(
    BuildContext context,
    String title,
    String imagePath,
  ) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(imagePath, fit: BoxFit.cover),
          Container(
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.4)),
          ),
          Center(
            child: Text(
              title,
              style:
                  theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Lora',
                  ) ??
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Lora',
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
