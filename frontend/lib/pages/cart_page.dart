import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../theme/app_colors.dart';

class CartPage extends StatelessWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        final items = cart.cartItems;
        final textTheme = Theme.of(context).textTheme;
        return Scaffold(
          backgroundColor: AppColors.bgBlue,
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    'Shopping Cart',
                    style: textTheme.displayLarge?.copyWith(
                      color: AppColors.highlight,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                if (items.isEmpty)
                  _buildEmptyCart(context)
                else
                  Column(
                    children: [
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          return _buildCartItem(context, items[index], cart);
                        },
                      ),
                      const SizedBox(height: 32),
                      _buildCheckoutCard(context, cart),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: AppColors.greyText.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Your cart is empty.',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.greyText,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add items from the Catalog.',
              style: textTheme.bodyMedium?.copyWith(color: AppColors.greyText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, dynamic item, CartProvider cart) {
    final hasImage = item.imageUrl != null && item.imageUrl!.isNotEmpty;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

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
            width: 80,
            height: 80,
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
                      item.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.broken_image,
                        color: Colors.white24,
                        size: 28,
                      ),
                    )
                  : Icon(
                      item.type.toLowerCase().contains('weapon')
                          ? Icons.colorize
                          : Icons.diamond,
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
                Text(
                  item.name,
                  style: textTheme.headlineSmall?.copyWith(
                    fontSize: 16,
                    color: AppColors.primaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.type} - ${item.category}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.highlight,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(
                    item.stars ?? 4,
                    (i) =>
                        Icon(Icons.star, color: AppColors.highlight, size: 14),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${item.price} Mora',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.highlight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        if (item.qty >= item.stock)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              'MAX',
                              style: textTheme.bodyMedium?.copyWith(
                                color: Colors.redAccent,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        Container(
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.bgBlue,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              _QtyButton(
                                icon: Icons.remove,
                                onTap: () => cart.decrementQty(item.id),
                              ),
                              Container(
                                constraints: const BoxConstraints(minWidth: 32),
                                alignment: Alignment.center,
                                child: Text(
                                  '${item.qty}',
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              _QtyButton(
                                icon: Icons.add,
                                onTap: item.qty >= item.stock
                                    ? null
                                    : () => cart.incrementQty(item.id),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutCard(BuildContext context, CartProvider cart) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.highlight.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total Price',
                style: textTheme.headlineSmall?.copyWith(
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${cart.cartTotal} Mora',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.highlight,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: cart.cartItems.isEmpty
                ? null
                : () => _onBuy(context, cart),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.highlight,
              disabledBackgroundColor: AppColors.highlight.withOpacity(0.3),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              'BUY',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.bgBlue,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onBuy(BuildContext context, CartProvider cart) async {
    bool success = await cart.checkout();
    if (!context.mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Purchase successful!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Checkout failed! Stock insufficient.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _QtyButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: disabled
              ? AppColors.highlight.withOpacity(0.3)
              : AppColors.highlight,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 16,
          color: disabled ? Colors.black38 : AppColors.bgBlue,
        ),
      ),
    );
  }
}
