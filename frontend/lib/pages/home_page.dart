import 'package:flutter/material.dart';
import 'catalog_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  // Fungsi untuk pindah ke halaman catalog dengan membawa filter
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Genshin Import',
          style: TextStyle(
            color: Color(0xFFD4AF37),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ad astra abyssosque,\nTraveler!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Welcome to your one-stop armory for weapons and artifacts. Equip the best, conquer the unknown.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // Card 1: All Items
            _buildPromoCard(
              title: 'Browse Catalog',
              subtitle: 'See everything Teyvat has to offer.',
              icon: Icons.auto_awesome,
              onTap: () => _goToCatalog(context, 'All'),
            ),
            const SizedBox(height: 16),

            // Card 2: Weapons
            _buildPromoCard(
              title: 'Browse Weapons',
              subtitle: 'Every legend needs the right weapon. Find yours.',
              icon: Icons.colorize, // Icon pedang (mendekati)
              onTap: () => _goToCatalog(context, 'Weapons'),
            ),
            const SizedBox(height: 16),

            // Card 3: Artifacts
            _buildPromoCard(
              title: 'Browse Artifacts',
              subtitle: 'The right set can change everything.',
              icon: Icons.diamond,
              onTap: () => _goToCatalog(context, 'Artifacts'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A38),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: const Color(0xFFD4AF37)),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }
}
