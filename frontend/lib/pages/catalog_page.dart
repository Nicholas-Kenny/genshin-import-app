import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

class CatalogPage extends StatefulWidget {
  final String initialFilter;
  const CatalogPage({Key? key, required this.initialFilter}) : super(key: key);

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  String _searchQuery = '';
  late String _selectedFilter;

  List<dynamic> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter == 'All'
        ? 'All items'
        : widget.initialFilter;
    _fetchCatalogData();
  }

  Future<void> _fetchCatalogData() async {
    try {
      final data = await ApiService.getItems();
      if (mounted) {
        setState(() {
          _items = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal terhubung ke server.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<dynamic> get filteredItems {
    return _items.where((item) {
      bool matchesFilter = true;
      if (_selectedFilter != 'All items') {
        final searchTerm = _selectedFilter.replaceAll('s', '').toLowerCase();
        final itemType = item['type'].toString().toLowerCase();
        final itemCategory = item['category'].toString().toLowerCase();
        matchesFilter =
            itemType.contains(searchTerm) || itemCategory.contains(searchTerm);
      }

      final matchesSearch = item['name'].toString().toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );

      return matchesFilter && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bool canPop = Navigator.canPop(context);
    return Scaffold(
      backgroundColor: AppColors.bgBlue,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Stack(
              alignment: Alignment.center,
              children: [
                if (canPop)
                  Positioned(
                    left: 16,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new),
                      color: AppColors.highlight,
                      iconSize: 22,
                      onPressed: () => Navigator.pop(context),
                      splashRadius: 24,
                    ),
                  ),
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Teyvat Market',
                        style: textTheme.displayLarge?.copyWith(
                          color: AppColors.highlight,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Equip your journey with the finest gears.',
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: 16,
                          color: AppColors.primaryText,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: TextField(
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.primaryText,
                ),
                decoration: InputDecoration(
                  hintText: 'Search for items',
                  hintStyle: textTheme.bodyMedium?.copyWith(
                    color: AppColors.greyText,
                  ),
                  prefixIcon: Icon(Icons.search, color: AppColors.greyText),
                  filled: true,
                  fillColor: AppColors.primaryBlue,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildFilterTab(context, 'All items'),
                  const SizedBox(width: 12),
                  _buildFilterTab(context, 'Weapons'),
                  const SizedBox(width: 12),
                  _buildFilterTab(context, 'Artifacts'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.white10, height: 1, thickness: 1),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: AppColors.highlight,
                      ),
                    )
                  : filteredItems.isEmpty
                  ? Center(
                      child: Text(
                        'No items found in the market.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.greyText,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(24),
                      itemCount: filteredItems.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return _buildItemCard(context, filteredItems[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
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
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isActive ? AppColors.bgBlue : AppColors.greyText,
          ),
        ),
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, dynamic item) {
    final textTheme = Theme.of(context).textTheme;
    final int stock = item['stock'] ?? 0;
    final bool isOutOfStock = stock <= 0;
    final hasImage =
        item['image_url'] != null && item['image_url'].toString().isNotEmpty;
    final isWeapon = item['type'].toString().toLowerCase().contains('weapon');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.highlight.withOpacity(0.5),
                width: 1.0,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: hasImage
                  ? Image.network(
                      item['image_url'],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.broken_image,
                        color: AppColors.primaryText.withOpacity(0.24),
                        size: 28,
                      ),
                    )
                  : Icon(
                      isWeapon ? Icons.colorize : Icons.diamond,
                      color: AppColors.highlight.withOpacity(0.5),
                      size: 32,
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item['name'],
                        style: textTheme.headlineSmall?.copyWith(
                          fontSize: 18,
                          color: AppColors.primaryText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: List.generate(
                        item['stars'] ?? 4,
                        (i) => Icon(
                          Icons.star,
                          color: AppColors.highlight,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${item['type']} - ${item['category']}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.highlight,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item['description'] ??
                      'A fine piece of equipment from Teyvat.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.primaryText,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${item['stock']} in stock',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.highlight,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${item['price']} Mora',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.highlight,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Consumer<CartProvider>(
                  builder: (context, cart, _) {
                    final inCart = cart.isInCart(item['id'] as int);
                    return SizedBox(
                      width: double.infinity,
                      height: 36,
                      child: ElevatedButton(
                        onPressed: isOutOfStock || inCart
                            ? null
                            : () {
                                cart.addToCart(item);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${item['name']} added to cart!',
                                      style: textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    duration: const Duration(seconds: 1),
                                    backgroundColor: AppColors.highlight,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.highlight,
                          disabledBackgroundColor: AppColors.highlight
                              .withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          isOutOfStock
                              ? 'Out of Stock'
                              : (inCart ? 'In Cart ✓' : 'Add to Cart'),
                          style: textTheme.bodyMedium?.copyWith(
                            color: isOutOfStock || inCart
                                ? Colors.black54
                                : AppColors.bgBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
