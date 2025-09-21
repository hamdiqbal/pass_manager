import 'package:flutter/material.dart';
import '../models/master_branch.dart';
import '../models/subcategory.dart';

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
  final TextEditingController _additionalFieldController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool get isEditing => widget.subcategory != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nameController.text = widget.subcategory!.name;
      _additionalFieldController.text = widget.subcategory!.additionalField;
      _descriptionController.text = widget.subcategory!.description;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _additionalFieldController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F2E),
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
                      color: const Color(0xFF1A1F2E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey[800]!,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.folder,
                          color: Color(0xFF4A90E2),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Parent: ${widget.masterBranch.name}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[300],
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
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isEditing 
                      ? 'Update the details for this subcategory'
                      : 'Fill in the details to create a new subcategory',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[400],
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
                  
                  // Additional Field
                  _buildInputField(
                    label: 'Additional Field',
                    controller: _additionalFieldController,
                    icon: Icons.add_circle_outline,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter additional field';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Description Field
                  _buildInputField(
                    label: 'Description',
                    controller: _descriptionController,
                    icon: Icons.description,
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),
                  
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _saveSubcategory,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A90E2),
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
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF4A90E2)),
            filled: true,
            fillColor: const Color(0xFF1A1F2E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF4A90E2),
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
      final subcategory = isEditing
        ? widget.subcategory!.copyWith(
            name: _nameController.text.trim(),
            additionalField: _additionalFieldController.text.trim(),
            description: _descriptionController.text.trim(),
          )
        : Subcategory(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: _nameController.text.trim(),
            additionalField: _additionalFieldController.text.trim(),
            description: _descriptionController.text.trim(),
          );

      // Return the subcategory to the master branch detail page
      Navigator.pop(context, subcategory);
    }
  }
}
