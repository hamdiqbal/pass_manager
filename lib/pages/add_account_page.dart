import 'package:flutter/material.dart';
import '../models/account.dart';
import '../models/custom_field.dart';

class AddAccountPage extends StatefulWidget {
  final Account? account; // For editing existing account
  
  const AddAccountPage({
    super.key,
    this.account,
  });

  @override
  State<AddAccountPage> createState() => _AddAccountPageState();
}

class _AddAccountPageState extends State<AddAccountPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _authKeyController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;
  bool get _isEditing => widget.account != null;
  
  List<CustomField> customFields = [];
  Map<String, TextEditingController> fieldControllers = {};
  Map<String, bool> hiddenFieldVisibility = {}; // Track visibility of hidden fields

  @override
  void initState() {
    super.initState();
    
    // If editing, populate fields with existing data
    if (_isEditing) {
      _nameController.text = widget.account!.name;
      _usernameController.text = widget.account!.username;
      _passwordController.text = widget.account!.password;
      _urlController.text = widget.account!.url;
      _authKeyController.text = widget.account!.authenticationKey;
      _descriptionController.text = widget.account!.description;
      customFields = List.from(widget.account!.customFields);
      
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
    _usernameController.dispose();
    _passwordController.dispose();
    _urlController.dispose();
    _authKeyController.dispose();
    _descriptionController.dispose();
    
    // Dispose custom field controllers
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
          _isEditing ? 'Edit Account' : 'Add Account',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: null, // Removed delete button
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
                  Text(
                    _isEditing ? 'Edit Account' : 'Create New Account',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isEditing 
                        ? 'Update your account details below'
                        : 'Fill in all the details to create a new account',
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
                    icon: Icons.account_circle,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter account name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Username Field
                  _buildInputField(
                    label: 'Username',
                    controller: _usernameController,
                    icon: Icons.person,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter username';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Password Field
                  _buildPasswordField(),
                  const SizedBox(height: 24),
                  
                  // URL Field
                  _buildInputField(
                    label: 'URL',
                    controller: _urlController,
                    icon: Icons.link,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter URL';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Authentication Key Field
                  _buildInputField(
                    label: 'Authentication Key',
                    controller: _authKeyController,
                    icon: Icons.key,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter authentication key';
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
                    maxLines: 3,
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
                  ...customFields.map((field) => _buildCustomField(field)),
                  const SizedBox(height: 40),
                  
                  // Save Account Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _saveAccount,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3E2411),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _isEditing ? 'Update Account' : 'Save Account',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
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

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: !_passwordVisible,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter password';
            }
            return null;
          },
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock, color: Color(0xFF3E2411)),
            suffixIcon: IconButton(
              icon: Icon(
                _passwordVisible ? Icons.visibility : Icons.visibility_off,
                color: const Color(0xFF3E2411),
              ),
              onPressed: () {
                setState(() {
                  _passwordVisible = !_passwordVisible;
                });
              },
            ),
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
            hintText: 'Enter Password',
            hintStyle: TextStyle(color: Colors.grey[500]),
          ),
        ),
      ],
    );
  }

  void _saveAccount() {
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

      final account = Account(
        id: _isEditing ? widget.account!.id : DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
        url: _urlController.text.trim(),
        authenticationKey: _authKeyController.text.trim(),
        description: _descriptionController.text.trim(),
        customFields: updatedCustomFields,
        createdAt: _isEditing ? widget.account!.createdAt : null,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Account updated successfully!' : 'Account saved successfully!'),
          backgroundColor: const Color(0xFF3E2411),
        ),
      );

      // Return the account to the previous page
      Navigator.pop(context, account);
    }
  }

  void _showAddCustomFieldDialog() {
    final TextEditingController nameController = TextEditingController();
    String selectedType = 'text';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFFF5F5F5),
          title: const Text(
            'Add Custom Field',
            style: TextStyle(color: Colors.black),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  labelText: 'Field Name',
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                dropdownColor: const Color(0xFFF5F5F5),
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  labelText: 'Field Type',
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'text', child: Text('Text')),
                  DropdownMenuItem(value: 'boolean', child: Text('Boolean')),
                  DropdownMenuItem(value: 'hidden', child: Text('Hidden')),
                  DropdownMenuItem(value: 'linked', child: Text('Linked')),
                ],
                onChanged: (value) {
                  setDialogState(() {
                    selectedType = value!;
                  });
                },
              ),
            ],
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
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  final newField = CustomField(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text.trim(),
                    type: selectedType,
                  );
                  
                  setState(() {
                    customFields.add(newField);
                    fieldControllers[newField.id] = TextEditingController();
                    if (newField.type == 'hidden') {
                      hiddenFieldVisibility[newField.id] = false;
                    }
                  });
                  
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3E2411),
                foregroundColor: Colors.white,
              ),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
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
          color: Colors.grey.shade300,
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
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeCustomField(field.id),
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
        return DropdownButtonFormField<String>(
          value: controller.text.isEmpty ? 'false' : controller.text,
          dropdownColor: Colors.white,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: const [
            DropdownMenuItem(value: 'true', child: Text('True')),
            DropdownMenuItem(value: 'false', child: Text('False')),
          ],
          onChanged: (value) {
            controller.text = value!;
          },
        );
      
      case 'hidden':
        return Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                obscureText: !(hiddenFieldVisibility[field.id] ?? false),
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  hintText: 'Enter hidden value',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                (hiddenFieldVisibility[field.id] ?? false) ? Icons.visibility : Icons.visibility_off,
                color: const Color(0xFF3E2411),
              ),
              onPressed: () {
                setState(() {
                  hiddenFieldVisibility[field.id] = !(hiddenFieldVisibility[field.id] ?? false);
                });
              },
            ),
          ],
        );
      
      default: // text, linked
        return TextFormField(
          controller: controller,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            hintText: field.type == 'linked' ? 'Enter URL or link' : 'Enter text value',
            hintStyle: TextStyle(color: Colors.grey[500]),
          ),
        );
    }
  }

  Color _getFieldTypeColor(String type) {
    switch (type) {
      case 'text':
        return Colors.blue;
      case 'boolean':
        return Colors.green;
      case 'hidden':
        return Colors.orange;
      case 'linked':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _removeCustomField(String fieldId) {
    setState(() {
      customFields.removeWhere((field) => field.id == fieldId);
      fieldControllers[fieldId]?.dispose();
      fieldControllers.remove(fieldId);
      hiddenFieldVisibility.remove(fieldId);
    });
  }

  Future<bool> _showDeleteConfirmation(BuildContext context, String title, String content) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            title,
            style: const TextStyle(color: Colors.black),
          ),
          content: Text(
            content,
            style: const TextStyle(color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3E2411),
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Delete',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    ) ?? false;
  }

  Future<void> _deleteAccount() async {
    if (!_isEditing || widget.account == null) return;

    // First confirmation popup
    final firstConfirmed = await _showDeleteConfirmation(
      context,
      'Delete Account',
      'Are you sure you want to delete "${widget.account!.name}"?',
    );

    if (!firstConfirmed) return;

    // Second confirmation popup
    final secondConfirmed = await _showDeleteConfirmation(
      context,
      'Warning: Delete Account',
      'This action cannot be undone. The account will be permanently deleted.',
    );

    if (!secondConfirmed) return;

    // Return a special deletion signal to the calling page
    if (mounted) {
      Navigator.of(context).pop('DELETE_ACCOUNT');
    }
  }
}
