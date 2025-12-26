import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scentview/admin/admin_layout.dart';
import 'package:scentview/models/banner.dart' as app_banner;
import '../services/api_service.dart';

class AddEditBannerScreen extends StatefulWidget {
  final app_banner.Banner? banner;

  const AddEditBannerScreen({this.banner, Key? key}) : super(key: key);

  @override
  _AddEditBannerScreenState createState() => _AddEditBannerScreenState();
}

class _AddEditBannerScreenState extends State<AddEditBannerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  late TextEditingController _titleController;
  late TextEditingController _targetScreenController;
  late TextEditingController _targetIdController;
  late TextEditingController _sortOrderController;
  late TextEditingController _descriptionController;
  
  String? _currentImageUrl;
  XFile? _pickedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.banner?.title ?? '');
    _targetScreenController = TextEditingController(text: widget.banner?.targetScreen ?? '');
    _targetIdController = TextEditingController(text: widget.banner?.targetId ?? '');
    _sortOrderController = TextEditingController(
      text: (widget.banner?.sortOrder ?? 0).toString()
    );
    _descriptionController = TextEditingController(text: widget.banner?.description ?? '');
    _isActive = widget.banner?.isActive ?? true;
    _currentImageUrl = widget.banner?.imageUrl;
    
    print('Initialized with banner: ${widget.banner?.toJson()}');
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _pickedImage = image;
        });
        print('Image picked: ${image.path}');
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: ${e.toString()}')),
      );
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validation
    if (widget.banner == null && _pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image for the new banner'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String token = ApiService.authToken ?? "YOUR_TEST_TOKEN";
      final sortOrder = int.tryParse(_sortOrderController.text) ?? 0;
      
      if (widget.banner == null) {
        // Add new banner
        await _apiService.createBanner(
          title: _titleController.text,
          targetScreen: _targetScreenController.text,
          targetId: _targetIdController.text,
          imageFile: _pickedImage!,
          sortOrder: sortOrder,
          isActive: _isActive,
          description: _descriptionController.text,
          token: token,
        );
      } else {
        // Update existing banner
        await _apiService.updateBanner(
          id: widget.banner!.id,
          title: _titleController.text,
          targetScreen: _targetScreenController.text,
          targetId: _targetIdController.text,
          imageFile: _pickedImage,
          sortOrder: sortOrder,
          isActive: _isActive,
          description: _descriptionController.text,
          currentImageUrl: _currentImageUrl,
          token: token,
        );
      }
      
      if (mounted) {
        setState(() => _isLoading = false);

        // === SUCCESS MESSAGE DIALOG ===
        await showDialog(
          context: context,
          barrierDismissible: false, // User must press OK
          builder: (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 10),
                Text('Success'),
              ],
            ),
            content: const Text('Banner uploaded successfully!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop(); // Close dialog
                  Navigator.of(context).pop(true); // Return to previous screen
                },
                child: const Text('OK', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Error saving banner: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save banner: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: widget.banner == null ? 'Add Banner' : 'Edit Banner',
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Title
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title *',
                          border: OutlineInputBorder(),
                          hintText: 'Enter banner title',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Target Screen
                      TextFormField(
                        controller: _targetScreenController,
                        decoration: const InputDecoration(
                          labelText: 'Target Screen',
                          border: OutlineInputBorder(),
                          hintText: 'e.g., /products, /home',
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Target ID
                      TextFormField(
                        controller: _targetIdController,
                        decoration: const InputDecoration(
                          labelText: 'Target ID',
                          border: OutlineInputBorder(),
                          hintText: 'e.g., product ID or category ID',
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Sort Order
                      TextFormField(
                        controller: _sortOrderController,
                        decoration: const InputDecoration(
                          labelText: 'Sort Order',
                          border: OutlineInputBorder(),
                          hintText: '0',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      
                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                          hintText: 'Optional description',
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      
                      // Active Switch
                      Card(
                        child: SwitchListTile(
                          title: const Text('Active'),
                          subtitle: const Text('Show this banner to users'),
                          value: _isActive,
                          onChanged: (value) {
                            setState(() {
                              _isActive = value;
                            });
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Image Section
                      _buildImageSection(),
                      
                      const SizedBox(height: 30),
                      
                      // Submit Button
                      ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          widget.banner == null ? 'Create Banner' : 'Update Banner',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      
                      if (widget.banner != null) ...[
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete Banner'),
                                content: const Text('Are you sure you want to delete this banner?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                            
                            if (confirmed == true) {
                              await _deleteBanner();
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: Colors.red.withOpacity(0.5)),
                          ),
                          child: const Text('Delete Banner'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildImagePreview() {
    if (_pickedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: kIsWeb
            ? Image.network(_pickedImage!.path, fit: BoxFit.cover)
            : Image.file(File(_pickedImage!.path), fit: BoxFit.cover),
      );
    } 
    else if (widget.banner?.imageUrl != null && widget.banner!.imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          widget.banner!.imageUrl!,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    'Unable to load image',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          },
        ),
      );
    } 
    else {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'No image selected',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildImageSection() {
    final hasImage = _pickedImage != null || 
                    (widget.banner?.imageUrl != null && widget.banner!.imageUrl!.isNotEmpty);
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Banner Image',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.banner == null 
                ? 'Select an image for the banner (required)'
                : _pickedImage != null
                  ? 'New image selected'
                  : 'Current banner image',
              style: TextStyle(
                color: Theme.of(context).hintColor.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            
            // Image Preview
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade50,
              ),
              child: _buildImagePreview(),
            ),
            
            const SizedBox(height: 16),
            
            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image, size: 20),
                    label: const Text('Select Image'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                if (hasImage) const SizedBox(width: 12),
                if (hasImage)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _pickedImage = null;
                          _currentImageUrl = widget.banner?.imageUrl;
                        });
                      },
                      icon: const Icon(Icons.delete_outline, size: 20),
                      label: const Text('Remove'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: BorderSide(color: Colors.red.withOpacity(0.5)),
                      ),
                    ),
                  ),
              ],
            ),
            
            // Image URL info
            if (widget.banner?.imageUrl != null && _pickedImage == null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'Current image: ${_getShortUrl(widget.banner!.imageUrl!)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getShortUrl(String url) {
    if (url.length <= 40) return url;
    return '${url.substring(0, 20)}...${url.substring(url.length - 15)}';
  }

  Future<void> _deleteBanner() async {
    setState(() => _isLoading = true);
    try {
      await _apiService.deleteBanner(
        id: widget.banner!.id,
        token: ApiService.authToken ?? "YOUR_TEST_TOKEN",
      );
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete banner: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}