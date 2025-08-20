import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The main search bar
          TextField(
            style: const TextStyle(color: Colors.black, fontSize: 18),
            decoration: InputDecoration(
              hintText: 'search_artisans'.tr(),
              hintStyle: TextStyle(color: Colors.grey.shade600),
              prefixIcon: Icon(Icons.search, color: Colors.grey.shade700),
              filled: true,
              fillColor: Colors.white,
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
              _buildChip('Wooden Toys'),
              _buildChip('Mosaic Art'),
              _buildChip('Priya Sharma'),
              _buildChip('Pottery'),
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
              _buildCategoryCard('Ceramics', 'assets/Ceramic.jpg'),
              _buildCategoryCard('Glasswork', 'assets/Glass.jpg'),
              _buildCategoryCard('Woodcraft', 'assets/Wooden_Toys.jpeg'),
              _buildCategoryCard('Mosaics', 'assets/Mosaic_Art.jpeg'),
            ],
          ),
        ],
      ),
    );
  }

  // Helper widget for section titles
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        fontFamily: 'Lora',
      ),
    );
  }

  // Helper widget for the recent search chips
  Widget _buildChip(String label) {
    return Chip(
      label: Text(label, style: const TextStyle(color: Colors.black)),
      backgroundColor: Colors.white,
      side: BorderSide(color: Colors.grey.shade300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  // Helper widget for the category cards
  Widget _buildCategoryCard(String title, String imagePath) {
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
              style: const TextStyle(
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
