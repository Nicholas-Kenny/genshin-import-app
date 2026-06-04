import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../theme/app_colors.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({Key? key}) : super(key: key);

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  String _selectedFilter = 'All items';

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        final items = cart.inventoryItems;
        final filteredItems = items.where((item) {
          if (_selectedFilter == 'All items') {
            return true;
          }
          final searchTerm = _selectedFilter.replaceAll('s', '').toLowerCase();
          final matchesType = item.type.toLowerCase().contains(searchTerm);
          final matchesCategory = item.category.toLowerCase().contains(
            searchTerm,
          );
          return matchesType || matchesCategory;
        }).toList();

        return Scaffold(
          backgroundColor: AppColors.bgBlue,
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 40.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildHeader(context),
                const SizedBox(height: 32),
                _buildFilterRow(context),
                const SizedBox(height: 32),
                if (filteredItems.isEmpty)
                  _buildEmptyState(context)
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 20),
                    itemBuilder: (context, index) {
                      return _buildInventoryCard(context, filteredItems[index]);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Column(
        children: [
          Text(
            'Traveler’s Chest',
            style: textTheme.displayLarge?.copyWith(color: AppColors.highlight),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Your collected relics and arms across Teyvat.',
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 16,
              color: AppColors.primaryText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 50.0),
        child: Text(
          'No items found.',
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.greyText,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildFilterTab(context, 'All items'),
        const SizedBox(width: 12),
        _buildFilterTab(context, 'Weapons'),
        const SizedBox(width: 12),
        _buildFilterTab(context, 'Artifacts'),
      ],
    );
  }

  Widget _buildFilterTab(BuildContext context, String title) {
    final isActive = _selectedFilter == title;
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.highlight : AppColors.primaryBlue,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: textTheme.bodyMedium?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isActive ? AppColors.bgBlue : AppColors.greyText,
          ),
        ),
      ),
    );
  }

  Widget _buildInventoryCard(BuildContext context, dynamic item) {
    final textTheme = Theme.of(context).textTheme;
    final hasImage = item.imageUrl != null && item.imageUrl!.isNotEmpty;
    final isWeapon = item.type.toLowerCase().contains('weapon');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.highlight.withOpacity(0.25)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: hasImage
                  ? Image.network(
                      item.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.broken_image,
                        color: AppColors.primaryText.withOpacity(0.38),
                        size: 30,
                      ),
                    )
                  : Icon(
                      isWeapon ? Icons.colorize : Icons.diamond,
                      color: AppColors.highlight.withOpacity(0.5),
                      size: 36,
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: textTheme.headlineSmall?.copyWith(
                    fontSize: 16,
                    color: AppColors.primaryText,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  '${item.type} - ${item.category}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.highlight,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Purchased at ${_formatDate(item.purchasedAt)}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.greyText,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 4.0),
                child: Text(
                  'Owned',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.greenAccent,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  return Icon(
                    index < item.stars ? Icons.star : Icons.star_border,
                    color: AppColors.highlight,
                    size: 14,
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}
