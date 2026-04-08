import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/profile_state_provider.dart';
import '../../../../features/profile/presentation/providers/profile_provider.dart';
import '../../../../features/profile/domain/models/profile_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final _fnameController = TextEditingController();
  final _lnameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();

  File? _selectedImage;
  bool _isLoading = false;
  String? _currentAvatarUrl;

  @override
  void initState() {
    super.initState();
    // Load existing data from cache if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    final cachedUser = ref.read(currentUserProvider);
    if (cachedUser != null) {
      setState(() {
        _fnameController.text = cachedUser['fname'] ?? '';
        _lnameController.text = cachedUser['lname'] ?? '';
        _usernameController.text = cachedUser['username'] ?? '';
        _emailController.text = cachedUser['email'] ?? '';

        // Handle potentially different DOB formats
        if (cachedUser['date_of_birth'] != null) {
          _dobController.text = cachedUser['date_of_birth'].toString();
        }

        _currentAvatarUrl = AppUrls.getCustomerAvatarUrl(cachedUser);
      });
    }
  }

  @override
  void dispose() {
    _fnameController.dispose();
    _lnameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 76,
      maxWidth: 1200,
      maxHeight: 1200,
    );
    if (pickedFile != null) {
      final optimized = await _optimizeImage(File(pickedFile.path));
      setState(() {
        _selectedImage = optimized;
      });
    }
  }

  String _buildCompressedPath(String originalPath) {
    final lastSlash = originalPath.lastIndexOf('/');
    final dir = lastSlash == -1
        ? Directory.systemTemp.path
        : originalPath.substring(0, lastSlash);
    return '$dir/profile_${DateTime.now().microsecondsSinceEpoch}.jpg';
  }

  Future<File> _optimizeImage(File source) async {
    try {
      final compressed = await FlutterImageCompress.compressAndGetFile(
        source.absolute.path,
        _buildCompressedPath(source.path),
        quality: 76,
        minWidth: 1200,
        minHeight: 1200,
        format: CompressFormat.jpeg,
        keepExif: false,
        autoCorrectionAngle: true,
      );

      return compressed != null ? File(compressed.path) : source;
    } on MissingPluginException {
      return source;
    } catch (_) {
      return source;
    }
  }

  Future<void> _selectDateOfBirth() async {
    final currentDate = DateTime.now();
    // Maximum age 100, default selected age is 18 years ago.
    final lastDate = DateTime(
      currentDate.year - 1,
      currentDate.month,
      currentDate.day,
    );
    final initialDate = DateTime(
      currentDate.year - 18,
      currentDate.month,
      currentDate.day,
    );

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: kPrimaryColor,
              onPrimary: Colors.white,
              surface: Color(0xFF1E293B),
              onSurface: Colors.white,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: const Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _submitProfileUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final token = await ref.read(authTokenProvider.future);
      if (token == null) throw Exception('No authentication token found');

      // Create FormData properly
      final formData = FormData.fromMap({
        'fname': _fnameController.text.trim(),
        'lname': _lnameController.text.trim(),
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'date_of_birth': _dobController.text.trim(),
      });

      if (_selectedImage != null) {
        formData.files.add(
          MapEntry(
            'photo',
            await MultipartFile.fromFile(
              _selectedImage!.path,
              filename: 'profile_pic.jpg',
            ),
          ),
        );
      }

      final repo = ref.read(customerRepositoryProvider);

      // We manually add token since ApiClient uses singletons that might be lost on quick reloads
      final response = await repo.updateProfile(formData, token: token);

      // Persist updated user data to SharedPreferences for reactive updates
      final updatedUser =
          response['data']?['customer_info'] ??
          response['data']?['authUser'] ??
          response['customer'];
      if (updatedUser != null) {
        final existingUser = ref.read(currentUserProvider) ?? const {};
        final mergedUser = <String, dynamic>{
          ...existingUser,
          ...Map<String, dynamic>.from(updatedUser),
        };
        final prefs = ref.read(sharedPreferencesProvider);
        await prefs.setString(AppConstants.userKey, jsonEncode(mergedUser));
        ref.read(currentUserProvider.notifier).state = mergedUser;

        final personalAvatarUrl = AppUrls.getCustomerAvatarUrl(mergedUser);
        if (personalAvatarUrl != null) {
          final profiles = ref.read(userProfilesProvider);
          final syncedProfiles = profiles.map((profile) {
            if (profile.type != ProfileType.personal) {
              return profile;
            }
            return profile.copyWith(avatarUrl: personalAvatarUrl);
          }).toList();
          ref.read(userProfilesProvider.notifier).state = syncedProfiles;
          await prefs.setString(
            'user_identities_key',
            jsonEncode(
              syncedProfiles.map((profile) => profile.toJson()).toList(),
            ),
          );
        }
      }

      // Refresh data
      ref.invalidate(profileProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: kDangerColor,
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
      backgroundColor: kBackgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'EDIT PROFILE',
          style: GoogleFonts.splineSans(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Avatar Picker
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.1),
                            border: Border.all(
                              color: kPrimaryColor.withValues(alpha: 0.5),
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: _selectedImage != null
                                ? Image.file(_selectedImage!, fit: BoxFit.cover)
                                : (_currentAvatarUrl != null
                                      ? CachedNetworkImage(
                                          imageUrl: _currentAvatarUrl!,
                                          fit: BoxFit.cover,
                                          errorWidget: (_, __, ___) =>
                                              const Icon(
                                                Icons.person,
                                                size: 60,
                                                color: Colors.white54,
                                              ),
                                        )
                                      : const Icon(
                                          Icons.person,
                                          size: 60,
                                          color: Colors.white54,
                                        )),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: kPrimaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: kBackgroundDark,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Form Fields
                _buildTextField(
                  label: 'First Name',
                  controller: _fnameController,
                  icon: Icons.person_outline_rounded,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Last Name',
                  controller: _lnameController,
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Username',
                  controller: _usernameController,
                  icon: Icons.alternate_email_rounded,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Email',
                  controller: _emailController,
                  icon: Icons.email_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // DOB Picker built similar to a text field
                GestureDetector(
                  onTap: _selectDateOfBirth,
                  child: AbsorbPointer(
                    child: _buildTextField(
                      label: 'Date of Birth',
                      controller: _dobController,
                      icon: Icons.calendar_today_rounded,
                      readOnly: true,
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitProfileUpdate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                      shadowColor: kPrimaryColor.withValues(alpha: 0.5),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Save Changes',
                            style: GoogleFonts.splineSans(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      validator: validator,
      style: GoogleFonts.splineSans(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.splineSans(
          color: Colors.white.withValues(alpha: 0.5),
        ),
        prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.5)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: kPrimaryColor, width: 2),
        ),
      ),
    );
  }
}
