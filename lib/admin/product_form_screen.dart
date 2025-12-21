import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scentview/models/product_model.dart';
import 'package:scentview/services/api_service.dart';
import 'package:flutter/foundation.dart';
import '../models/category.dart' as app_category;

class ProductFormScreen extends StatefulWidget {
  static const String routeName = '/admin/add-edit-product';
  final Product? product;
  final VoidCallback? onSave;

  const ProductFormScreen({this.product, this.onSave, Key? key}) : super(key: key);

  @override
  _ProductFormScreenState createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _originalPriceController;
  late TextEditingController _salePriceController;
  late TextEditingController _badgeController;
  String? _selectedCategoryId;

  XFile? _pickedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  bool _isFeatured = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descriptionController = TextEditingController(text: widget.product?.description ?? '');
    _originalPriceController = TextEditingController(text: widget.product?.originalPrice.toString() ?? '');
    _salePriceController = TextEditingController(
      text: (widget.product?.salePrice != null && widget.product!.salePrice! > 0)
          ? widget.product!.salePrice.toString()
          : ''
    );
    _badgeController = TextEditingController(text: widget.product?.badgeText ?? '');
    _selectedCategoryId = widget.product?.categoryId?.toString();
    _isFeatured = widget.product?.isFeatured ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _originalPriceController.dispose();
    _salePriceController.dispose();
    _badgeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() { _pickedImage = image; });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a Category!'), backgroundColor: Colors.orange),
      );
      return;
    }

    if (widget.product == null && _pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload an image!'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String token = ApiService.authToken ?? "YOUR_TEST_TOKEN"; 

      if (widget.product == null) {
        await _apiService.addProduct(
          name: _nameController.text,
          description: _descriptionController.text,
          price: _originalPriceController.text,
          salePrice: _salePriceController.text,
          categoryId: _selectedCategoryId!,
          isFeatured: _isFeatured,
          badgeText: _badgeController.text, // ✅ Added Badge Text Here
          imageFile: _pickedImage, 
          token: token,
        );
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Product Added!')));
      } else {
        await _apiService.updateProduct(
          id: widget.product!.id.toString(),
          name: _nameController.text,
          description: _descriptionController.text,
          price: _originalPriceController.text,
          salePrice: _salePriceController.text,
          categoryId: _selectedCategoryId!,
          isFeatured: _isFeatured,
          badgeText: _badgeController.text, // ✅ Added Badge Text Here
          imageFile: _pickedImage,
          token: token,
        );
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Product Updated!')));
      }

      if (widget.onSave != null) widget.onSave!();
      Navigator.pop(context);
    } catch (e) {
      debugPrint("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.product != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? "Edit Product" : "Add Product")),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
                  child: _pickedImage != null
                      ? (kIsWeb 
                          ? Image.network(_pickedImage!.path, fit: BoxFit.cover) 
                          : Image.file(File(_pickedImage!.path), fit: BoxFit.cover))
                      : (isEdit && widget.product!.imageUrl.isNotEmpty)
                          ? Image.network(ApiService.toAbsoluteUrl(widget.product!.imageUrl)!, fit: BoxFit.cover)
                          : const Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 20),
              
              _buildField(_nameController, "Product Name"),
              const SizedBox(height: 10),
              _buildField(_descriptionController, "Description", maxLines: 3),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _buildField(_originalPriceController, "Price", type: TextInputType.number)),
                const SizedBox(width: 10),
                Expanded(child: _buildField(_salePriceController, "Sale Price", type: TextInputType.number)),
              ]),
              const SizedBox(height: 10),
              
              // ✅ Badge Text Field
              _buildField(_badgeController, "Badge Text (e.g. Sale, New, Hot)"),
              
              const SizedBox(height: 10),

              FutureBuilder<List<app_category.Category>>(
                future: _apiService.fetchCategories(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text("No categories found.", style: TextStyle(color: Colors.orange));
                  }
                  
                  if (_selectedCategoryId != null) {
                    final exists = snapshot.data!.any((c) => c.id.toString() == _selectedCategoryId);
                    if (!exists) _selectedCategoryId = null;
                  }

                  return DropdownButtonFormField<String>(
                    value: _selectedCategoryId,
                    decoration: const InputDecoration(labelText: "Category", border: OutlineInputBorder()),
                    items: snapshot.data!.map((c) => DropdownMenuItem(value: c.id.toString(), child: Text(c.name))).toList(),
                    onChanged: (v) => setState(() => _selectedCategoryId = v),
                    validator: (v) => v == null ? "Select a category" : null,
                  );
                },
              ),

              SwitchListTile(
                title: const Text("Featured Product"),
                value: _isFeatured,
                onChanged: (v) => setState(() => _isFeatured = v),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity, 
                height: 50, 
                child: ElevatedButton(onPressed: _submitForm, child: Text(isEdit ? "Update" : "Add"))
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController c, String label, {int maxLines = 1, TextInputType? type}) {
    return TextFormField(
      controller: c,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      maxLines: maxLines,
      keyboardType: type,
      validator: (v) => v!.isEmpty && label != "Sale Price" && label != "Badge Text (e.g. Sale, New, Hot)" ? "Required" : null,
    );
  }
}