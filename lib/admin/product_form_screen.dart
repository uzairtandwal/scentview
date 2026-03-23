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
  final _scrollController = ScrollController();

  Future<List<app_category.Category>>? _categoriesFuture;

  late TextEditingController _nameController;
  // ... rest of controllers

  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _salePriceController;
  late TextEditingController _badgeController;
  late TextEditingController _quantityController;
  late TextEditingController _brandController;
  late TextEditingController _scentFamilyController;
  late TextEditingController _sizeController;
  late TextEditingController _notesTopController;
  late TextEditingController _notesMiddleController;
  late TextEditingController _notesBaseController;
  late TextEditingController _skuController;
  
  String? _selectedCategoryName;
  XFile? _pickedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  bool _isFeatured = false;
  bool _isSlider = false;
  bool _isActive = true;
  bool _hasFreeShipping = false;
  bool _isTaxable = true;
  
  List<XFile> _additionalImages = [];
  List<String> _tags = [];
  final TextEditingController _tagController = TextEditingController();

  // ================ RESPONSIVE UTILITIES ================
  bool get _isMobile => MediaQuery.of(context).size.width < 600;
  bool get _isTablet => MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1024;
  bool get _isDesktop => MediaQuery.of(context).size.width >= 1024;
  
  double get _screenPadding => _isMobile ? 16 : 24;
  double get _fieldSpacing => _isMobile ? 12 : 16;
  double get _sectionSpacing => _isMobile ? 20 : 28;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _categoriesFuture = _apiService.fetchCategories(); // Cache the future
    if (widget.product?.tags != null) {
      _tags = List.from(widget.product!.tags!);
    }
  }

  void _reloadCategories() {
    setState(() {
      _categoriesFuture = _apiService.fetchCategories();
    });
  }

  // ... rest of controllers

  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _badgeController.dispose();
    _quantityController.dispose();
    _brandController.dispose();
    _scentFamilyController.dispose();
    _sizeController.dispose();
    _notesTopController.dispose();
    _notesMiddleController.dispose();
    _notesBaseController.dispose();
    _skuController.dispose();
    _tagController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeControllers() {
    final product = widget.product;
    
    _nameController = TextEditingController(text: product?.name ?? '');
    _descriptionController = TextEditingController(text: product?.description ?? '');
    _priceController = TextEditingController(text: product?.price.toString() ?? '');
    _salePriceController = TextEditingController(text: product?.salePrice?.toString() ?? '');
    _badgeController = TextEditingController(text: product?.badgeText ?? '');
    _quantityController = TextEditingController(text: product?.quantity.toString() ?? '100');
    _brandController = TextEditingController(text: product?.brand ?? '');
    _scentFamilyController = TextEditingController(text: product?.scentFamily ?? '');
    _sizeController = TextEditingController(text: product?.size ?? '');
    _notesTopController = TextEditingController(text: product?.notesTop ?? '');
    _notesMiddleController = TextEditingController(text: product?.notesMiddle ?? '');
    _notesBaseController = TextEditingController(text: product?.notesBase ?? '');
    _skuController = TextEditingController(text: product?.sku ?? '');
    
    _selectedCategoryName = product?.category;
    _isFeatured = product?.isFeatured ?? false;
    _isSlider = product?.isSlider ?? false;
    _isActive = product?.isActive ?? true;
  }

  Future<void> _pickImage({bool isMainImage = true}) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );
    
    if (image != null) {
      setState(() {
        if (isMainImage) {
          _pickedImage = image;
        } else {
          _additionalImages.add(image);
        }
      });
    }
  }

  Future<void> _takePhoto({bool isMainImage = true}) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1200,
    );
    
    if (image != null) {
      setState(() {
        if (isMainImage) {
          _pickedImage = image;
        } else {
          _additionalImages.add(image);
        }
      });
    }
  }

  void _removeAdditionalImage(int index) {
    setState(() {
      _additionalImages.removeAt(index);
    });
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      await Future.delayed(const Duration(milliseconds: 100));
      final context = _formKey.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
      return;
    }

    if (_selectedCategoryName == null) {
      _showErrorSnackbar('Please select a category');
      return;
    }

    if (widget.product == null && _pickedImage == null) {
      _showErrorSnackbar('Please upload a main product image');
      return;
    }

    setState(() => _isLoading = true);

    try {
      String token = ApiService.authToken ?? "YOUR_TEST_TOKEN";

      if (widget.product == null) {
        await _apiService.addProduct(
          name: _nameController.text,
          description: _descriptionController.text,
          price: _priceController.text,
          salePrice: _salePriceController.text,
          category: _selectedCategoryName!,
          isFeatured: _isFeatured,
          isSlider: _isSlider,
          scentFamily: _scentFamilyController.text,
          brand: _brandController.text,
          size: _sizeController.text,
          quantity: _quantityController.text,
          notesTop: _notesTopController.text,
          notesMiddle: _notesMiddleController.text,
          notesBase: _notesBaseController.text,
          badgeText: _badgeController.text,
          imageFile: _pickedImage,
          token: token,
        );
        
        if (mounted) {
          await _showSuccessDialog('Product Created!', 'New fragrance has been added to your inventory.');
        }
      } else {
        await _apiService.updateProduct(
          id: widget.product!.id.toString(),
          name: _nameController.text,
          description: _descriptionController.text,
          price: _priceController.text,
          category: _selectedCategoryName!,
          isFeatured: _isFeatured,
          isSlider: _isSlider,
          scentFamily: _scentFamilyController.text,
          brand: _brandController.text,
          size: _sizeController.text,
          quantity: _quantityController.text,
          notesTop: _notesTopController.text,
          notesMiddle: _notesMiddleController.text,
          notesBase: _notesBaseController.text,
          badgeText: _badgeController.text,
          imageFile: _pickedImage,
          token: token,
        );
        
        if (mounted) {
          await _showSuccessDialog('Product Updated!', 'Changes have been saved successfully.');
        }
      }

      if (widget.onSave != null) widget.onSave!();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint("Error: $e");
      _showErrorSnackbar('Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showSuccessDialog(String title, String message) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.red.shade800),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.product != null;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Product' : 'Add New Product',
          style: TextStyle(
            fontSize: _isMobile ? 18 : 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Saving product...'),
                ],
              ),
            )
          : GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Form(
                key: _formKey,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.all(_screenPadding),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // ================ PRODUCT IMAGES SECTION ================
                          _buildSectionTitle('Product Images'),
                          SizedBox(height: _fieldSpacing),
                          _buildImageSection(isEdit),
                          
                          SizedBox(height: _sectionSpacing),
                          
                          // ================ BASIC INFORMATION SECTION ================
                          _buildSectionTitle('Basic Information'),
                          SizedBox(height: _fieldSpacing),
                          _buildTextField(
                            controller: _nameController,
                            label: 'Product Name *',
                            hintText: 'Enter product name',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Product name is required';
                              }
                              return null;
                            },
                          ),
                          
                          SizedBox(height: _fieldSpacing),
                          
                          _buildTextField(
                            controller: _descriptionController,
                            label: 'Description *',
                            hintText: 'Enter product description',
                            maxLines: 4,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Description is required';
                              }
                              return null;
                            },
                          ),
                          
                          SizedBox(height: _fieldSpacing),
                          
                          // ================ CATEGORY SELECTION ================
                          _buildCategoryDropdown(),
                          
                          SizedBox(height: _sectionSpacing),
                          
                          // ================ PRICING SECTION ================
                          _buildSectionTitle('Pricing'),
                          SizedBox(height: _fieldSpacing),
                          _buildPricingSection(),
                          
                          SizedBox(height: _sectionSpacing),
                          
                          // ================ INVENTORY SECTION ================
                          _buildSectionTitle('Inventory'),
                          SizedBox(height: _fieldSpacing),
                          _buildInventorySection(),
                          
                          SizedBox(height: _sectionSpacing),
                          
                          // ================ ADDITIONAL INFORMATION ================
                          _buildSectionTitle('Additional Information'),
                          SizedBox(height: _fieldSpacing),
                          
                          _buildTextField(
                            controller: _brandController,
                            label: 'Brand',
                            hintText: 'Enter brand name',
                          ),
                          
                          SizedBox(height: _fieldSpacing),

                          _buildTextField(
                            controller: _scentFamilyController,
                            label: 'Scent Family',
                            hintText: 'e.g., Floral, Woody, Oriental',
                          ),
                          
                          SizedBox(height: _fieldSpacing),

                          _buildTextField(
                            controller: _sizeController,
                            label: 'Size',
                            hintText: 'e.g., 50ml, 100ml',
                          ),
                          
                          SizedBox(height: _sectionSpacing),

                          _buildSectionTitle('Fragrance Notes'),
                          SizedBox(height: _fieldSpacing),

                          _buildTextField(
                            controller: _notesTopController,
                            label: 'Top Notes',
                            hintText: 'e.g., Bergamot, Lemon',
                          ),
                          
                          SizedBox(height: _fieldSpacing),

                          _buildTextField(
                            controller: _notesMiddleController,
                            label: 'Middle Notes',
                            hintText: 'e.g., Rose, Jasmine',
                          ),
                          
                          SizedBox(height: _fieldSpacing),

                          _buildTextField(
                            controller: _notesBaseController,
                            label: 'Base Notes',
                            hintText: 'e.g., Vanilla, Musk',
                          ),
                          
                          SizedBox(height: _fieldSpacing),
                          
                          _buildTextField(
                            controller: _skuController,
                            label: 'SKU (quantity Keeping Unit)',
                            hintText: 'Enter product SKU',
                          ),
                          
                          SizedBox(height: _fieldSpacing),
                          
                          _buildTextField(
                            controller: _badgeController,
                            label: 'Badge Text',
                            hintText: 'e.g., New, Sale, Featured',
                          ),
                          
                          SizedBox(height: _sectionSpacing),
                          
                          // ================ TAGS SECTION ================
                          _buildSectionTitle('Product Tags'),
                          SizedBox(height: _fieldSpacing),
                          _buildTagsSection(),
                          
                          SizedBox(height: _sectionSpacing),
                          
                          // ================ SETTINGS SECTION ================
                          _buildSectionTitle('Settings'),
                          SizedBox(height: _fieldSpacing),
                          _buildSettingsSection(),
                          
                          SizedBox(height: _sectionSpacing * 2),
                          
                          // ================ SUBMIT BUTTON ================
                          _buildSubmitButton(isEdit),
                          
                          SizedBox(height: _isMobile ? 40 : 60),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // ================ SECTION TITLE ================
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: _isMobile ? 18 : 20,
      ),
    );
  }

  // ================ IMAGE SECTION ================
  Widget _buildImageSection(bool isEdit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Image
        Text(
          'Main Image *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        SizedBox(height: _isMobile ? 8 : 12),
        
        GestureDetector(
          onTap: () => _showImageSourceDialog(isMainImage: true),
          child: Container(
            height: _isMobile ? 160 : 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: _pickedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: kIsWeb
                        ? Image.network(_pickedImage!.path, fit: BoxFit.cover)
                        : Image.file(File(_pickedImage!.path), fit: BoxFit.cover),
                  )
                : (isEdit && widget.product!.imageUrl.isNotEmpty)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          ApiService.toAbsoluteUrl(widget.product!.imageUrl)!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildImagePlaceholder('Main Image');
                          },
                        ),
                      )
                    : _buildImagePlaceholder('Tap to add main image'),
          ),
        ),
        
        SizedBox(height: _fieldSpacing),
        
        // Additional Images
        Text(
          'Additional Images (Optional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        SizedBox(height: _isMobile ? 8 : 12),
        
        if (_additionalImages.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _additionalImages.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Theme.of(context).colorScheme.surfaceVariant,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: kIsWeb
                            ? Image.network(_additionalImages[index].path, fit: BoxFit.cover)
                            : Image.file(File(_additionalImages[index].path), fit: BoxFit.cover),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removeAdditionalImage(index),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.red.shade600,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        
        if (_additionalImages.isEmpty || _additionalImages.length < 5)
          Padding(
            padding: EdgeInsets.only(top: _additionalImages.isNotEmpty ? 12 : 0),
            child: OutlinedButton.icon(
              onPressed: () => _showImageSourceDialog(isMainImage: false),
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: const Text('Add More Images'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImagePlaceholder(String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_a_photo_outlined,
            size: _isMobile ? 36 : 48,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          SizedBox(height: _isMobile ? 8 : 12),
          Text(
            text,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  void _showImageSourceDialog({required bool isMainImage}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          isMainImage ? 'Select Main Image' : 'Add Image',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(isMainImage: isMainImage);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto(isMainImage: isMainImage);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ================ TEXT FIELD BUILDER ================
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        fontSize: _isMobile ? 15 : 16,
      ),
    );
  }

  // ================ CATEGORY DROPDOWN ================
  Widget _buildCategoryDropdown() {
    return FutureBuilder<List<app_category.Category>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Loading categories...',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade100),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: Colors.orange.shade700, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    snapshot.hasError
                        ? 'Failed to load categories'
                        : 'No categories found',
                    style: TextStyle(color: Colors.orange.shade800),
                  ),
                ),
                TextButton.icon(
                  onPressed: _reloadCategories,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Retry'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.orange.shade900,
                  ),
                ),
              ],
            ),
          );
        }

        final categories = snapshot.data!;

        // Ensure selected category exists
        if (_selectedCategoryName != null) {
          final exists = categories.any((c) => c.name == _selectedCategoryName);
          if (!exists) _selectedCategoryName = null;
        }

        return Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedCategoryName,
                decoration: InputDecoration(
                  labelText: 'Category *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor:
                      Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                ),
                items: categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category.name,
                    child: Text(
                      category.name,
                      style: TextStyle(fontSize: _isMobile ? 15 : 16),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryName = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
                icon: Icon(
                  Icons.arrow_drop_down_rounded,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _reloadCategories,
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh Categories',
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        );
      },
    );
  }

  // ================ PRICING SECTION ================
  Widget _buildPricingSection() {
    return Column(
      children: [
        _buildTextField(
          controller: _priceController,
          label: 'Regular Price *',
          hintText: '0.00',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Price is required';
            }
            final price = double.tryParse(value);
            if (price == null || price <= 0) {
              return 'Enter a valid price';
            }
            return null;
          },
        ),
        SizedBox(height: _fieldSpacing),
        _buildTextField(
          controller: _salePriceController,
          label: 'Sale Price (Optional)',
          hintText: '0.00',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final price = double.tryParse(value);
              if (price == null || price <= 0) {
                return 'Enter a valid sale price';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  // ================ INVENTORY SECTION ================
  Widget _buildInventorySection() {
    return _buildTextField(
      controller: _quantityController,
      label: 'Quantity',
      hintText: '100',
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final q = int.tryParse(value);
          if (q == null || q < 0) {
            return 'Enter valid quantity';
          }
        }
        return null;
      },
    );
  }

  // ================ TAGS SECTION ================
  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tagController,
                decoration: InputDecoration(
                  labelText: 'Add Tags',
                  hintText: 'Press Enter to add tag',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add_rounded),
                    onPressed: _addTag,
                  ),
                ),
                onSubmitted: (_) => _addTag(),
              ),
            ),
          ],
        ),
        
        SizedBox(height: _fieldSpacing),
        
        if (_tags.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tags.map((tag) {
              return Chip(
                label: Text(tag),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => _removeTag(tag),
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              );
            }).toList(),
          ),
        
        if (_tags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Tags help customers find your product easily',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ),
      ],
    );
  }

  // ================ SETTINGS SECTION ================
  Widget _buildSettingsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Featured Product',
              style: TextStyle(
                fontSize: _isMobile ? 15 : 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              'Show this product in featured section',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            value: _isFeatured,
            onChanged: (value) => setState(() => _isFeatured = value),
            activeColor: Theme.of(context).colorScheme.primary,
          ),
          
          Divider(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            height: 20,
          ),

          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Show in Sale Popup',
              style: TextStyle(
                fontSize: _isMobile ? 15 : 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              'Display this product in the hot sale popup',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            value: _isSlider,
            onChanged: (value) => setState(() => _isSlider = value),
            activeColor: Theme.of(context).colorScheme.primary,
          ),
          
          Divider(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            height: 20,
          ),
          
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Active Product',
              style: TextStyle(
                fontSize: _isMobile ? 15 : 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              'Make this product visible to customers',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            value: _isActive,
            onChanged: (value) => setState(() => _isActive = value),
            activeColor: Theme.of(context).colorScheme.primary,
          ),
          
          Divider(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            height: 20,
          ),
          
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Free Shipping',
              style: TextStyle(
                fontSize: _isMobile ? 15 : 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              'Offer free shipping for this product',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            value: _hasFreeShipping,
            onChanged: (value) => setState(() => _hasFreeShipping = value),
            activeColor: Theme.of(context).colorScheme.primary,
          ),
          
          Divider(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            height: 20,
          ),
          
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Taxable',
              style: TextStyle(
                fontSize: _isMobile ? 15 : 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              'Apply taxes to this product',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            value: _isTaxable,
            onChanged: (value) => setState(() => _isTaxable = value),
            activeColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  // ================ SUBMIT BUTTON ================
  Widget _buildSubmitButton(bool isEdit) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isEdit ? 'Updating...' : 'Creating...',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Text(
                isEdit ? 'Update Product' : 'Create Product',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
} 
