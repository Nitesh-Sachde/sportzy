import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sportzy/core/theme/app_colors.dart';
import 'package:sportzy/core/utils/screen_size.dart';
import 'package:sportzy/core/utils/validators.dart';
import 'package:sportzy/widgets/custom_text_field.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  String _userName = '';
  // Form controllers
  final _fullNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();

  String? selectedGender = 'Male';
  List<String> genders = ['Male', 'Female', 'Other', 'Prefer not to say'];

  bool _isLoading = true;
  String _userEmail = '';

  // Section edit states
  final Map<String, bool> _editableSections = {
    'basic': false,
    'location': false,
    'bio': false,
  };

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _ageController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Store email for display
        _userEmail = user.email ?? '';

        // Load additional user data from Firestore
        final userData =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        if (userData.exists) {
          final data = userData.data();
          if (data != null) {
            setState(() {
              _userName = data['name'] ?? '';
              _fullNameController.text = data['fullname'] ?? '';
              _phoneController.text = data['phone'] ?? '';
              _ageController.text = data['age']?.toString() ?? '';
              // Make sure we have a valid gender from the list
              final loadedGender = data['gender'] as String?;
              selectedGender =
                  genders.contains(loadedGender) ? loadedGender : 'Male';
              _cityController.text = data['city'] ?? '';
              _stateController.text = data['state'] ?? '';
              _countryController.text = data['country'] ?? '';
              _pincodeController.text = data['pincode'] ?? '';
              _bioController.text = data['bio'] ?? '';
            });
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _toggleSectionEdit(String section) async {
    // If already in edit mode, save changes when toggling off
    if (_editableSections[section]!) {
      _saveSection(section);
    }

    setState(() {
      _editableSections[section] = !_editableSections[section]!;
    });
  }

  Future<void> _saveSection(String section) async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        final uid = user?.uid;

        if (uid == null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('User not found.')));
          return;
        }

        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => const Center(child: CircularProgressIndicator()),
        );

        // Create data maps based on which section is being saved
        Map<String, dynamic> updatedData = {};

        if (section == 'basic') {
          updatedData = {
            'fullname': _fullNameController.text.trim(),
            'phone': _phoneController.text.trim(),
            'age':
                _ageController.text.trim().isNotEmpty
                    ? int.tryParse(_ageController.text.trim())
                    : null,
            'gender': selectedGender,
          };
        } else if (section == 'location') {
          updatedData = {
            'city': _cityController.text.trim(),
            'state': _stateController.text.trim(),
            'country': _countryController.text.trim(),
            'pincode': _pincodeController.text.trim(),
          };
        } else if (section == 'bio') {
          updatedData = {'bio': _bioController.text.trim()};
        }

        // Remove empty values
        updatedData.removeWhere(
          (key, value) => value == null || (value is String && value.isEmpty),
        );

        // Update Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .update(updatedData);

        // Close loading indicator
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_getSectionName(section)} updated successfully!'),
          ),
        );
      } catch (e) {
        // Close loading indicator if open
        Navigator.of(context).pop();

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  String _getSectionName(String section) {
    switch (section) {
      case 'basic':
        return 'Basic Information';
      case 'location':
        return 'Location Information';
      case 'bio':
        return 'About You';
      default:
        return 'Section';
    }
  }

  void _saveAllChanges() async {
    if (_formKey.currentState!.validate()) {
      // Save all sections that are currently in edit mode
      if (_editableSections['basic']!) await _saveSection('basic');
      if (_editableSections['location']!) await _saveSection('location');
      if (_editableSections['bio']!) await _saveSection('bio');

      // Reset all edit states
      setState(() {
        _editableSections.updateAll((key, value) => false);
      });

      Navigator.pop(context);
    } else {
      // Show validation error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the validation errors before saving.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = ScreenSize.screenHeight(context);
    final screenWidth = ScreenSize.screenWidth(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          "Edit Profile",
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: AppColors.white),
            onPressed: _saveAllChanges,
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.01,
          vertical: screenHeight * 0.01,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(screenWidth * 0.06),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Avatar
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: screenWidth * 0.15,
                        backgroundColor: AppColors.primary.withAlpha(
                          51,
                        ), // Fixed withOpacity
                        child: Text(
                          getInitials(_userName),
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: screenWidth * 0.17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),

                // Email Display
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Email: $_userEmail",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),

                // Basic Information Section
                buildSectionHeader(
                  title: "Basic Information",
                  sectionKey: 'basic',
                  canEdit: true,
                ),

                // Full Name Field with Validation
                buildTextField(
                  controller: _fullNameController,
                  labelText: "Full Name",
                  hintText: "Enter your full name",
                  prefixIcon: Icons.person,
                  keyboardType: TextInputType.name,
                  readOnly: !_editableSections['basic']!,
                  validator: Validators.validateFullName,
                ),
                SizedBox(height: screenHeight * 0.02),

                // Phone Field with Validation
                buildTextField(
                  controller: _phoneController,
                  labelText: "Phone Number",
                  hintText: "Enter your 10-digit phone number",
                  prefixIcon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  readOnly: !_editableSections['basic']!,
                  validator: Validators.validatePhone,
                ),
                SizedBox(height: screenHeight * 0.02),

                // Age Field with Validation
                buildTextField(
                  controller: _ageController,
                  labelText: "Age",
                  hintText: "Enter your age (5-120)",
                  prefixIcon: Icons.cake,
                  keyboardType: TextInputType.number,
                  readOnly: !_editableSections['basic']!,
                  validator: Validators.validateAge,
                ),
                SizedBox(height: screenHeight * 0.02),

                // Gender Dropdown
                buildGenderDropdown(readOnly: !_editableSections['basic']!),
                SizedBox(height: screenHeight * 0.03),

                // Location Information Section
                buildSectionHeader(
                  title: "Location Information",
                  sectionKey: 'location',
                  canEdit: true,
                ),

                // City Field with Validation
                buildTextField(
                  controller: _cityController,
                  labelText: "City",
                  hintText: "Enter your city",
                  prefixIcon: Icons.location_city,
                  readOnly: !_editableSections['location']!,
                  validator: Validators.validateCity,
                ),
                SizedBox(height: screenHeight * 0.02),

                // State Field with Validation
                buildTextField(
                  controller: _stateController,
                  labelText: "State",
                  hintText: "Enter your state",
                  prefixIcon: Icons.map,
                  readOnly: !_editableSections['location']!,
                  validator: Validators.validateState,
                ),
                SizedBox(height: screenHeight * 0.02),

                // Country and Pincode in one row
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Country Field with Validation
                      SizedBox(
                        width: screenWidth * 0.41,
                        child: buildTextField(
                          controller: _countryController,
                          labelText: "Country",
                          hintText: "Enter country",
                          prefixIcon: Icons.public,
                          readOnly: !_editableSections['location']!,
                          validator: Validators.validateCountry,
                        ),
                      ),

                      // Pincode Field with Validation
                      SizedBox(
                        width: screenWidth * 0.41,
                        child: buildTextField(
                          controller: _pincodeController,
                          labelText: "Pincode",
                          hintText: "6-digit code",
                          prefixIcon: Icons.pin_drop,
                          keyboardType: TextInputType.number,
                          readOnly: !_editableSections['location']!,
                          validator: Validators.validatePincode,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),

                // Bio Section
                buildSectionHeader(
                  title: "About You",
                  sectionKey: 'bio',
                  canEdit: true,
                ),

                // Bio TextField with Validation
                buildTextField(
                  controller: _bioController,
                  labelText: "Bio",
                  hintText: "Tell us about yourself...",
                  prefixIcon: Icons.description,
                  readOnly: !_editableSections['bio']!,
                  validator: Validators.validateBio,
                  maxLines: 5,
                ),
                SizedBox(height: screenHeight * 0.04),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: screenHeight * 0.065,
                  child: ElevatedButton.icon(
                    onPressed: _saveAllChanges,
                    icon: Icon(
                      Icons.save,
                      color: AppColors.white,
                      size: screenWidth * 0.06,
                    ),
                    label: Text(
                      "Save All Changes",
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        color: AppColors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSectionHeader({
    required String title,
    required String sectionKey,
    required bool canEdit,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: ScreenSize.screenHeight(context) * 0.022,
              color: AppColors.primary,
            ),
          ),
          if (canEdit)
            IconButton(
              icon: Icon(
                _editableSections[sectionKey]! ? Icons.check : Icons.edit,
                color: AppColors.primary,
              ),
              onPressed: () => _toggleSectionEdit(sectionKey),
              tooltip:
                  _editableSections[sectionKey]!
                      ? "Save changes"
                      : "Edit section",
            ),
        ],
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool readOnly = true,
    int? maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      maxLines: maxLines,
      validator: readOnly ? null : validator, // Only validate when editable
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(prefixIcon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: EdgeInsets.symmetric(
          vertical: ScreenSize.screenHeight(context) * 0.018,
          horizontal: ScreenSize.screenWidth(context) * 0.04,
        ),
        // Add different background color for read-only fields
        fillColor: readOnly ? Colors.grey[100] : Colors.white,
        filled: true,
        errorStyle: TextStyle(
          color: Colors.red[700],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget buildGenderDropdown({bool readOnly = true}) {
    // First ensure selectedGender has a valid value
    if (selectedGender == null || !genders.contains(selectedGender)) {
      selectedGender = 'Male'; // Default to Male if invalid value
    }

    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: "Gender",
        prefixIcon: Icon(Icons.person_outline),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: EdgeInsets.symmetric(
          vertical: ScreenSize.screenHeight(context) * 0.018,
          horizontal: ScreenSize.screenWidth(context) * 0.01,
        ),
        fillColor: readOnly ? Colors.grey[100] : Colors.white,
        filled: true,
      ),
      value: selectedGender,
      onChanged:
          readOnly
              ? null
              : (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedGender = newValue;
                  });
                }
              },
      items:
          genders.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
    );
  }
}

String getInitials(String? name) {
  if (name == null || name.trim().isEmpty) return "";
  final names = name.trim().split(RegExp(r'\s+'));
  if (names.length > 1) {
    return "${names[0][0]}${names[1][0]}".toUpperCase();
  }
  return names[0][0].toUpperCase();
}
