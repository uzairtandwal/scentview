import 'package:flutter/material.dart';
import 'package:scentview/models/banner.dart' as app_banner; // Alias added
import '../services/api_service.dart';
import 'package:image_picker/image_picker.dart';

class AddEditBannerScreen extends StatefulWidget {
  final app_banner.Banner? banner; // Use alias

  const AddEditBannerScreen({super.key, this.banner});

  @override
  State<AddEditBannerScreen> createState() => _AddEditBannerScreenState();
}

class _AddEditBannerScreenState extends State<AddEditBannerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();
  late final TextEditingController _titleController;
  late final TextEditingController _targetScreenController;
  late final TextEditingController _targetIdController;
  bool _isLoading = false;
  XFile? _pickedImage;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.banner?.title ?? '');
    _targetScreenController = TextEditingController(
      text: widget.banner?.targetScreen ?? '',
    );
    _targetIdController = TextEditingController(
      text: widget.banner?.targetId ?? '',
    );
    _imageUrl = widget.banner?.imageUrl;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetScreenController.dispose();
    _targetIdController.dispose();
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

    const String authToken = "YOUR_AUTH_TOKEN_HERE";

    try {
      final isUpdating = widget.banner != null;

      if (isUpdating) {
        await _api.updateBanner(
          id: widget.banner!.id.toString(),
          title: _titleController.text,
          targetScreen: _targetScreenController.text.isEmpty
              ? null
              : _targetScreenController.text,
          targetId: _targetIdController.text.isEmpty
              ? null
              : _targetIdController.text,
          imageFile: _pickedImage,
          token: authToken,
        );
      } else {
        if (_pickedImage == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please pick a banner image before saving.'),
            ),
          );
          setState(() => _isLoading = false);
          return;
        }
        await _api.createBanner(
          title: _titleController.text,
          targetScreen: _targetScreenController.text.isEmpty
              ? null
              : _targetScreenController.text,
          targetId: _targetIdController.text.isEmpty
              ? null
              : _targetIdController.text,
          imageFile: _pickedImage!,
          token: authToken,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Banner ${isUpdating ? 'updated' : 'saved'} successfully!',
          ),
          backgroundColor: Colors.green,
        ),
      );

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
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
        title: Text(widget.banner == null ? 'Add Banner' : 'Edit Banner'),
        actions: [
          if (!_isLoading)
            IconButton(
              onPressed: _saveForm,
              tooltip: 'Save Banner',
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
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title.';
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
                          label: const Text('Pick Banner Image'),
                        ),
                        const SizedBox(width: 12),
                        if (_pickedImage != null)
                          Expanded(child: Text(_pickedImage!.name, overflow: TextOverflow.ellipsis,))
                        else if(_imageUrl?.isNotEmpty ?? false)
                          const Text('Image selected'),

                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _targetScreenController,
                      decoration: const InputDecoration(
                        labelText: 'Target Screen',
                        hintText: 'e.g., /products or /category',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _targetIdController,
                      decoration: const InputDecoration(
                        labelText: 'Target ID',
                        hintText: 'e.g., a specific product or category ID',
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _saveForm,
                      child: Text(
                        widget.banner == null
                            ? 'Save Banner'
                            : 'Update Banner',
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