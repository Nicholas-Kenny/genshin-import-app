import 'package:flutter/material.dart';
import 'catalog_page.dart';
import '../theme/app_colors.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  void _goToCatalog(BuildContext context, String filter) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CatalogPage(initialFilter: filter),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.bgBlue,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ad astra abyssosque,\nTraveler!',
              style: textTheme.headlineLarge?.copyWith(
                color: AppColors.highlight,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Welcome to your one-stop armory for weapons and artifacts. Equip the best, conquer the unknown.',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () => _goToCatalog(context, 'All'),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 24,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.highlight,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.highlight.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Browse Catalog',
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.bgBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildCategoryCard(
              context: context, // 👈 kirim context
              title: 'Every legend needs the right weapon.',
              subtitle: 'Find yours.',
              buttonText: 'Browse Weapons',
              imagePath: 'assets/images/browse_weapon.png',
              onTap: () => _goToCatalog(context, 'Weapons'),
            ),
            const SizedBox(height: 16),
            _buildCategoryCard(
              context: context, // 👈 kirim context
              title: 'The right set can change everything.',
              subtitle: 'Browse yours.',
              buttonText: 'Browse Artifacts',
              imagePath: 'assets/images/browse_artifact.png',
              onTap: () => _goToCatalog(context, 'Artifacts'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required BuildContext context, // 👈 tambahkan parameter ini
    required String title,
    required String subtitle,
    required String buttonText,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.headlineSmall?.copyWith(
                    fontSize: 16,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.highlight,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      buttonText,
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.highlight,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: Image.asset(
                imagePath,
                width: 150,
                height: 150,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
