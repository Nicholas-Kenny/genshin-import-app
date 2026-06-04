import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  List<dynamic> _items = [];
  bool _isLoading = true;
  final ImagePicker _picker = ImagePicker();
  String _searchQuery = '';
  String _selectedFilter = 'All items';

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getItems();
      setState(() {
        _items = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteItem(int id) async {
    bool success = await ApiService.deleteItem(id);
    if (success) {
      _loadItems();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Item deleted successfully!',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
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

  void _showFormDialog({dynamic item}) {
    final isEdit = item != null;

    final nameController = TextEditingController(
      text: isEdit ? item['name'] : '',
    );
    final typeController = TextEditingController(
      text: isEdit ? item['type'] : '',
    );
    final priceController = TextEditingController(
      text: isEdit ? item['price'].toString() : '',
    );
    final stockController = TextEditingController(
      text: isEdit ? item['stock'].toString() : '',
    );
    final descController = TextEditingController(
      text: isEdit ? item['description'] : '',
    );

    String selectedCategory = isEdit ? item['category'] : 'Weapons';
    int selectedStars = isEdit ? (item['stars'] ?? 5) : 5;
    XFile? selectedImage;

    showDialog(
      context: context,
      builder: (context) {
        final textTheme = Theme.of(context).textTheme;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: AppColors.primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                isEdit ? 'Update Item' : 'Add New Item',
                style: textTheme.headlineSmall?.copyWith(
                  color: AppColors.highlight,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDialogTextField(nameController, 'Item Name'),
                    _buildDialogTextField(
                      typeController,
                      'Type (ex: Sword/Flower)',
                    ),
                    _buildDialogTextField(descController, 'Description'),
                    _buildDialogTextField(
                      priceController,
                      'Price (Mora)',
                      isNumber: true,
                    ),
                    _buildDialogTextField(
                      stockController,
                      'Stock',
                      isNumber: true,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      dropdownColor: AppColors.bgBlue,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.primaryText,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Category',
                        labelStyle: const TextStyle(color: Colors.grey),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.highlight),
                        ),
                      ),
                      items: ['Weapons', 'Artifacts'].map((String cat) {
                        return DropdownMenuItem<String>(
                          value: cat,
                          child: Text(cat),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setStateDialog(() => selectedCategory = value!),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: selectedStars,
                      dropdownColor: AppColors.bgBlue,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.primaryText,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Rarity (Stars)',
                        labelStyle: const TextStyle(color: Colors.grey),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.highlight),
                        ),
                      ),
                      items: [1, 2, 3, 4, 5].map((int star) {
                        return DropdownMenuItem<int>(
                          value: star,
                          child: Text('$star Stars'),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setStateDialog(() => selectedStars = value!),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.bgBlue,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.highlight.withOpacity(0.3),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: selectedImage != null
                            ? (kIsWeb
                                  ? Image.network(
                                      selectedImage!.path,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      File(selectedImage!.path),
                                      fit: BoxFit.cover,
                                    ))
                            : (isEdit &&
                                      item['image_url'] != null &&
                                      item['image_url'].toString().isNotEmpty
                                  ? Image.network(
                                      item['image_url'],
                                      fit: BoxFit.cover,
                                    )
                                  : Center(
                                      child: Icon(
                                        Icons.add_a_photo,
                                        color: AppColors.primaryText
                                            .withOpacity(0.54),
                                        size: 40,
                                      ),
                                    )),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final XFile? image = await _picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (image != null) {
                            setStateDialog(() => selectedImage = image);
                          }
                        },
                        icon: Icon(
                          Icons.photo_library,
                          color: AppColors.highlight,
                        ),
                        label: Text(
                          'Select from Gallery',
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.highlight,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.highlight),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    setState(() => _isLoading = true);

                    bool success;
                    if (isEdit) {
                      success = await ApiService.updateItem(
                        id: item['id'],
                        name: nameController.text,
                        type: typeController.text,
                        category: selectedCategory,
                        description: descController.text,
                        stock: int.tryParse(stockController.text) ?? 0,
                        price: int.tryParse(priceController.text) ?? 0,
                        stars: selectedStars,
                        existingImageUrl: item['image_url'],
                        newImageFile: selectedImage,
                      );
                    } else {
                      success = await ApiService.addItem(
                        name: nameController.text,
                        type: typeController.text,
                        category: selectedCategory,
                        description: descController.text,
                        stock: int.tryParse(stockController.text) ?? 0,
                        price: int.tryParse(priceController.text) ?? 0,
                        stars: selectedStars,
                        imageFile: selectedImage,
                      );
                    }

                    if (success) {
                      _loadItems();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isEdit
                                ? 'Item updated successfully!'
                                : 'Item successfully added!',
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      setState(() => _isLoading = false);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.highlight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    isEdit ? 'Update' : 'Save',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.bgBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDialogTextField(
    TextEditingController controller,
    String label, {
    bool isNumber = false,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return TextField(
      controller: controller,
      style: textTheme.bodyMedium?.copyWith(color: AppColors.primaryText),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.highlight),
        ),
      ),
    );
  }

  Widget _buildFilterTab(String title) {
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

  Widget _buildAdminItemCard(dynamic item) {
    final textTheme = Theme.of(context).textTheme;
    final hasImage =
        item['image_url'] != null && item['image_url'].toString().isNotEmpty;
    final isWeapon = item['type'].toString().toLowerCase().contains('weapon');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
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
                            item['stars'] ?? 5,
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
                      item['description'] ?? '-',
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
                          'Stock: ${item['stock']}',
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
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton.icon(
                    onPressed: () => _showFormDialog(item: item),
                    icon: Icon(
                      Icons.edit,
                      color: AppColors.highlight,
                      size: 18,
                    ),
                    label: Text(
                      'Edit',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.highlight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.highlight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: () => _deleteItem(item['id']),
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                      size: 18,
                    ),
                    label: Text(
                      'Delete',
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.bgBlue,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Text(
                'MANAGE ITEMS',
                style: textTheme.displayLarge?.copyWith(
                  fontSize: 26,
                  letterSpacing: 1.5,
                  color: AppColors.highlight,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: TextField(
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.primaryText,
                ),
                decoration: InputDecoration(
                  hintText: 'Search database...',
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
                  _buildFilterTab('All items'),
                  const SizedBox(width: 12),
                  _buildFilterTab('Weapons'),
                  const SizedBox(width: 12),
                  _buildFilterTab('Artifacts'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  height: 36,
                  child: ElevatedButton.icon(
                    onPressed: () => _showFormDialog(),
                    icon: Icon(Icons.add, color: AppColors.bgBlue, size: 16),
                    label: Text(
                      'Add Item',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.bgBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.highlight,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      elevation: 0,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
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
                        "No items found in database.",
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.greyText,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(24),
                      itemCount: filteredItems.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 20),
                      itemBuilder: (context, index) {
                        return _buildAdminItemCard(filteredItems[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
