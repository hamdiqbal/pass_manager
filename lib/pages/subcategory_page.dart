import 'package:flutter/material.dart';
import '../models/master_branch.dart';
import '../models/subcategory.dart';
import '../models/custom_field.dart';
import '../services/firebase_service.dart';

class SubcategoryPage extends StatefulWidget {
  final MasterBranch masterBranch;
  final Subcategory? subcategory; // Optional parameter for editing

  const SubcategoryPage({
    super.key,
    required this.masterBranch,
    this.subcategory,
  });

  @override
  State<SubcategoryPage> createState() => _SubcategoryPageState();
}

class _SubcategoryPageState extends State<SubcategoryPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool get isEditing => widget.subcategory != null;
  List<CustomField> customFields = [];
  Map<String, TextEditingController> fieldControllers = {};
  Map<String, bool> hiddenFieldVisibility = {}; // Track visibility of hidden fields

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nameController.text = widget.subcategory!.name;
      _descriptionController.text = widget.subcategory!.description;
      customFields = List.from(widget.subcategory!.customFields);
      
      // Initialize controllers for existing custom fields
      for (var field in customFields) {
        fieldControllers[field.id] = TextEditingController(
          text: field.value?.toString() ?? '',
        );
        // Initialize hidden field visibility to false (hidden by default)
        if (field.type == 'hidden') {
          hiddenFieldVisibility[field.id] = false;
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    for (var controller in fieldControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF3E2411),
        elevation: 0,
        title: Text(
          isEditing ? 'Edit Subcategory' : 'Add Subcategory',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: isEditing ? [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: _deleteSubcategory,
          ),
        ] : null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Parent Master Branch Info
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.folder,
                          color: Color(0xFF3E2411),
                        ),
                        const SizedBox(width: 12),
                          Text(
                          'Parent: ${widget.masterBranch.name}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  Text(
                    isEditing ? 'Edit Subcategory' : 'Create New Subcategory',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isEditing 
                      ? 'Update the details for this subcategory'
                      : 'Fill in the details to create a new subcategory',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Name Field
                  _buildInputField(
                    label: 'Name',
                    controller: _nameController,
                    icon: Icons.category,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Custom Fields Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Custom Fields',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _showAddCustomFieldDialog,
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Custom Field'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3E2411),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Dynamic Custom Fields
                  ...customFields.map((field) => _buildCustomField(field)).toList(),
                  
                  const SizedBox(height: 24),
                  
                  // Description Field
                  _buildInputField(
                    label: 'Description (Optional)',
                    controller: _descriptionController,
                    icon: Icons.description,
                    maxLines: 4,
                    validator: null, // Make description optional
                  ),
                  const SizedBox(height: 40),
                  
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _saveSubcategory,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3E2411),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        isEditing ? 'Update Subcategory' : 'Save Subcategory',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF3E2411)),
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF3E2411),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
            hintText: 'Enter $label',
            hintStyle: TextStyle(color: Colors.grey[500]),
          ),
        ),
      ],
    );
  }

  void _saveSubcategory() {
    if (_formKey.currentState!.validate()) {
      // Update custom field values from controllers
      final updatedCustomFields = customFields.map((field) {
        final controller = fieldControllers[field.id];
        if (controller != null) {
          dynamic value;
          switch (field.type) {
            case 'boolean':
              value = controller.text.toLowerCase() == 'true';
              break;
            case 'hidden':
            case 'linked':
            case 'text':
            default:
              value = controller.text.trim();
              break;
          }
          return field.copyWith(value: value);
        }
        return field;
      }).toList();

      final subcategory = isEditing
        ? widget.subcategory!.copyWith(
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            customFields: updatedCustomFields,
          )
        : Subcategory(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            customFields: updatedCustomFields,
          );

      // Return the subcategory to the master branch detail page
      Navigator.pop(context, subcategory);
    }
  }

  Widget _buildCustomField(CustomField field) {
    final controller = fieldControllers[field.id]!;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                field.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getFieldTypeColor(field.type),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      field.type.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 16),
                    onPressed: () => _removeCustomField(field.id),
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildFieldInput(field, controller),
        ],
      ),
    );
  }

  Widget _buildFieldInput(CustomField field, TextEditingController controller) {
    switch (field.type) {
      case 'boolean':
        return Row(
          children: [
            Radio<String>(
              value: 'true',
              groupValue: controller.text.isEmpty ? null : controller.text,
              onChanged: (value) => setState(() => controller.text = value!),
              activeColor: const Color(0xFF3E2411),
            ),
            const Text('True', style: TextStyle(color: Colors.black)),
            const SizedBox(width: 16),
            Radio<String>(
              value: 'false',
              groupValue: controller.text.isEmpty ? null : controller.text,
              onChanged: (value) => setState(() => controller.text = value!),
              activeColor: const Color(0xFF3E2411),
            ),
            const Text('False', style: TextStyle(color: Colors.black)),
          ],
        );
      case 'hidden':
        return TextFormField(
          controller: controller,
          obscureText: !(hiddenFieldVisibility[field.id] ?? false),
          style: const TextStyle(color: Colors.black),
          decoration: _getFieldDecoration('Enter ${field.name}').copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                (hiddenFieldVisibility[field.id] ?? false) 
                    ? Icons.visibility 
                    : Icons.visibility_off,
                color: Colors.grey[400],
              ),
              onPressed: () {
                setState(() {
                  hiddenFieldVisibility[field.id] = !(hiddenFieldVisibility[field.id] ?? false);
                });
              },
            ),
          ),
        );
      case 'linked':
      case 'text':
      default:
        return TextFormField(
          controller: controller,
          style: const TextStyle(color: Colors.black),
          decoration: _getFieldDecoration('Enter ${field.name}'),
        );
    }
  }

  InputDecoration _getFieldDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF8F8F8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Color(0xFF3E2411),
          width: 2,
        ),
      ),
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[500]),
    );
  }

  Color _getFieldTypeColor(String type) {
    switch (type) {
      case 'text': return Colors.blue;
      case 'boolean': return Colors.green;
      case 'hidden': return Colors.red;
      case 'linked': return Colors.orange;
      default: return Colors.grey;
    }
  }

  void _removeCustomField(String fieldId) {
    setState(() {
      customFields.removeWhere((field) => field.id == fieldId);
      fieldControllers[fieldId]?.dispose();
      fieldControllers.remove(fieldId);
      hiddenFieldVisibility.remove(fieldId); // Clean up visibility state
    });
  }

  void _showAddCustomFieldDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF5F5F5),
        title: const Text(
          'Add Custom Field',
          style: TextStyle(color: Colors.black),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose field type:',
              style: TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 16),
            _buildFieldTypeButton('text', 'Text', Icons.text_fields),
            const SizedBox(height: 8),
            _buildFieldTypeButton('boolean', 'Boolean', Icons.toggle_on),
            const SizedBox(height: 8),
            _buildFieldTypeButton('hidden', 'Hidden', Icons.visibility_off),
            const SizedBox(height: 8),
            _buildFieldTypeButton('linked', 'Linked', Icons.link),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldTypeButton(String type, String label, IconData icon) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pop(context);
          _showFieldNameDialog(type);
        },
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: _getFieldTypeColor(type),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  void _showFieldNameDialog(String type) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF5F5F5),
        title: const Text(
          'Enter Field Name',
          style: TextStyle(color: Colors.black),
        ),
        content: TextFormField(
          controller: nameController,
          style: const TextStyle(color: Colors.black),
          decoration: _getFieldDecoration('Field name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                _addCustomField(type, nameController.text.trim());
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3E2411),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addCustomField(String type, String name) {
    final field = CustomField(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      type: type,
      value: type == 'boolean' ? false : '',
    );
    
    setState(() {
      customFields.add(field);
      fieldControllers[field.id] = TextEditingController(
        text: field.value?.toString() ?? '',
      );
      // Initialize hidden field visibility to false (hidden by default)
      if (type == 'hidden') {
        hiddenFieldVisibility[field.id] = false;
      }
    });
  }

  Future<bool> _showDeleteConfirmation(BuildContext context, String title, String content) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            title,
            style: const TextStyle(color: Colors.white),
          ),
          content: Text(
            content,
            style: TextStyle(color: Colors.grey[300]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF3E2411)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    ) ?? false;
  }

  Future<void> _deleteSubcategory() async {
    if (!isEditing || widget.subcategory == null) return;

    // First confirmation popup
    final firstConfirmed = await _showDeleteConfirmation(
      context,
      'Delete Subcategory',
      'Are you sure you want to delete "${widget.subcategory!.name}"?',
    );

    if (!firstConfirmed) return;

    // Count accounts for second confirmation
    int accountCount = widget.subcategory!.accounts.length;
    
    // Second confirmation popup with account count
    final secondConfirmed = await _showDeleteConfirmation(
      context,
      'Warning: Delete All Data',
      'You have $accountCount ${accountCount == 1 ? 'account' : 'accounts'} in this subcategory. All accounts will also be deleted. This action cannot be undone.',
    );

    if (!secondConfirmed) return;

    try {
      // Delete from Firebase
      await FirebaseService().deleteSubcategoryFromMasterBranch(
        widget.masterBranch.id,
        widget.subcategory!.id,
      );

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Subcategory deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to master branch detail page
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting subcategory: $e'),
            backgroundColor: Colors.red[600],
          ),
        );
      }
    }
  }
}
