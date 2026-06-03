import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  List<dynamic> _items = [];
  bool _isLoading = true;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    try {
      // PERBAIKAN: Pemanggilan fungsi static tanpa tanda kurung instansiasi
      final data = await ApiService.getItems();
      setState(() {
        _items = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _deleteItem(int id) async {
    bool success = await ApiService.deleteItem(id);
    if (success) {
      _loadItems();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item deleted successfully from database!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // DIALOG MULTIFUNGSI: BISA UNTUK TAMBAH (CREATE) & EDIT (UPDATE)
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
    XFile? selectedImage;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: const Color(0xFF2A2A38),
              title: Text(
                isEdit ? 'Update Item in MySQL' : 'Add New Item to MySQL',
                style: const TextStyle(color: Color(0xFFD4AF37)),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Item Name',
                        labelStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                    TextField(
                      controller: typeController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Type (ex: Sword/Flower)',
                        labelStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                    TextField(
                      controller: descController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        labelStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                    TextField(
                      controller: priceController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Price (Mora)',
                        labelStyle: TextStyle(color: Colors.grey),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: stockController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Stock',
                        labelStyle: TextStyle(color: Colors.grey),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      dropdownColor: const Color(0xFF2A2A38),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        labelStyle: TextStyle(color: Colors.grey),
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
                    const SizedBox(height: 20),
                    Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade600),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
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
                            : (isEdit && item['image_url'] != null
                                  ? Image.network(
                                      item['image_url'],
                                      fit: BoxFit.cover,
                                    )
                                  : const Center(
                                      child: Icon(
                                        Icons.add_a_photo,
                                        color: Colors.white54,
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
                        icon: const Icon(
                          Icons.photo_library,
                          color: Color(0xFFD4AF37),
                        ),
                        label: const Text(
                          'Select from Gallery',
                          style: TextStyle(color: Color(0xFFD4AF37)),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFD4AF37)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    setState(() => _isLoading = true);

                    bool success;
                    if (isEdit) {
                      // KONDISI EDIT / UPDATE
                      success = await ApiService.updateItem(
                        id: item['id'],
                        name: nameController.text,
                        type: typeController.text,
                        category: selectedCategory,
                        description: descController.text,
                        stock: int.tryParse(stockController.text) ?? 0,
                        price: int.tryParse(priceController.text) ?? 0,
                        stars: 5,
                        existingImageUrl: item['image_url'],
                        newImageFile: selectedImage,
                      );
                    } else {
                      // KONDISI TAMBAH BARU
                      success = await ApiService.addItem(
                        name: nameController.text,
                        type: typeController.text,
                        category: selectedCategory,
                        description: descController.text,
                        stock: int.tryParse(stockController.text) ?? 0,
                        price: int.tryParse(priceController.text) ?? 0,
                        stars: 5,
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
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      setState(() => _isLoading = false);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                  ),
                  child: Text(
                    isEdit ? 'Update' : 'Add Item',
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MANAGE ITEMS',
          style: TextStyle(
            color: Color(0xFFD4AF37),
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        backgroundColor: const Color(0xFF15151E),
        iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Add, Edit, and Delete catalog's items directly from device",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () => _showFormDialog(),
                icon: const Icon(Icons.add, color: Colors.black),
                label: const Text(
                  'ADD NEW ITEM',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFD4AF37),
                      ),
                    )
                  : _items.isEmpty
                  ? const Center(
                      child: Text(
                        "No items in catalog database.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        final hasImage =
                            item['image_url'] != null &&
                            item['image_url'].toString().isNotEmpty;

                        return Card(
                          color: const Color(0xFF2A2A38),
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade700,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: hasImage
                                        ? Image.network(
                                            item['image_url'],
                                            fit: BoxFit.cover,
                                            errorBuilder: (c, e, s) =>
                                                const Icon(
                                                  Icons.broken_image,
                                                  color: Colors.white54,
                                                ),
                                          )
                                        : const Icon(
                                            Icons.image,
                                            color: Colors.white54,
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item['name'],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text(
                                            '${item['price']} Mora',
                                            style: const TextStyle(
                                              color: Color(0xFFD4AF37),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        'Type: ${item['type']}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        '${item['stock']} in stock',
                                        style: const TextStyle(
                                          color: Colors.greenAccent,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          // TOMBOL EDIT BARU UNTUK SYARAT UPDATE CRUD
                                          OutlinedButton(
                                            onPressed: () =>
                                                _showFormDialog(item: item),
                                            style: OutlinedButton.styleFrom(
                                              side: const BorderSide(
                                                color: Color(0xFFD4AF37),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                  ),
                                            ),
                                            child: const Text(
                                              'Edit',
                                              style: TextStyle(
                                                color: Color(0xFFD4AF37),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton(
                                            onPressed: () =>
                                                _deleteItem(item['id']),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.red.shade800,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                  ),
                                            ),
                                            child: const Text(
                                              'Delete',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
