import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/api_service.dart';
import 'package:image_picker/image_picker.dart';

class AddEditCategoryScreen extends StatefulWidget {
  final Category? category;

  const AddEditCategoryScreen({super.key, this.category});

  @override
  State<AddEditCategoryScreen> createState() => _AddEditCategoryScreenState();
}

class _AddEditCategoryScreenState extends State<AddEditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();
  late final TextEditingController _nameController;
  bool _isLoading = false;
  XFile? _pickedImage;
  String? _imageUrl; // existing or uploaded

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _imageUrl = widget.category?.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }
  _formKey.currentState!.save();

  setState(() {
    _isLoading = true;
  });

  // ✅ Sahi Token yahan se uthayein
  final authToken = ApiService.authToken;

  try {
    final isUpdating = widget.category != null;

    if (isUpdating) {
      await _api.updateCategory(
        id: widget.category!.id.toString(),
        name: _nameController.text,
        imageFile: _pickedImage,
        token: authToken, // ✅ Ab sahi token jayega
      );
    } else {
      await _api.createCategory(
        name: _nameController.text,
        imageFile: _pickedImage,
        token: authToken, // ✅ Ab sahi token jayega
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Category ${isUpdating ? 'updated' : 'saved'} successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category == null ? 'Add Category' : 'Edit Category'),
        actions: [
          if (!_isLoading)
            IconButton(
              onPressed: _saveForm,
              tooltip: 'Save Category',
              icon: const Icon(Icons.save),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Category Name',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a category name.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            final picker = ImagePicker();
                            final img = await picker.pickImage(
                              source: ImageSource.gallery,
                            );
                            if (img != null) {
                              setState(() {
                                _pickedImage = img;
                              });
                            }
                          },
                          icon: const Icon(Icons.image),
                          label: const Text('Pick Image (optional)'),
                        ),
                        const SizedBox(width: 12),
                         if (_pickedImage != null)
                          Expanded(child: Text(_pickedImage!.name, overflow: TextOverflow.ellipsis,))
                        else if(_imageUrl != null && _imageUrl!.isNotEmpty)
                          const Text('Image selected'),
                      ],
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _saveForm,
                      child: Text(
                        widget.category == null
                            ? 'Save Category'
                            : 'Update Category',
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}