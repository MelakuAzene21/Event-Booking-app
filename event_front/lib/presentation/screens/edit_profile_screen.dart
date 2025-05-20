import 'dart:convert';
import 'dart:io';
import 'package:event_booking_app/data/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:event_booking_app/core/config/api_config.dart';
import 'package:event_booking_app/core/utils/secure_storage.dart';
import 'package:event_booking_app/domain/providers/auth_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _organizationController;
  late TextEditingController _websiteController;
  late TextEditingController _aboutController;
  late TextEditingController _locationController;
  late TextEditingController _serviceProvidedController;
  late TextEditingController _priceController;
  late TextEditingController _eventCategoriesController;
  File? _avatarImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user!;
    _nameController = TextEditingController(text: user.name);
    _phoneController = TextEditingController(text: user.phoneNumber);
    _organizationController = TextEditingController(text: user.organizationName);
    _websiteController = TextEditingController(text: user.website);
    _aboutController = TextEditingController(text: user.about);
    _locationController = TextEditingController(text: user.location);
    _serviceProvidedController = TextEditingController(text: user.serviceProvided);
    _priceController = TextEditingController(text: user.price);
    _eventCategoriesController = TextEditingController(text: user.eventCategories?.join(', '));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _organizationController.dispose();
    _websiteController.dispose();
    _aboutController.dispose();
    _locationController.dispose();
    _serviceProvidedController.dispose();
    _priceController.dispose();
    _eventCategoriesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _avatarImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadAvatar() async {
    if (_avatarImage == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final token = await SecureStorage.getToken();
      if (token == null) throw Exception('No token found');

      print('Avatar file path: ${_avatarImage!.path}');
      print('Avatar file extension: ${_avatarImage!.path.split('.').last.toLowerCase()}');
      final extension = _avatarImage!.path.split('.').last.toLowerCase();
      final mimeType = {
        'jpg': 'image/jpeg',
        'jpeg': 'image/jpeg',
        'png': 'image/png',
        'webp': 'image/webp',
        'avif': 'image/avif',
        'heic': 'image/heic',
        'gif': 'image/gif',
      }[extension] ?? 'application/octet-stream';
      print('Inferred MIME type: $mimeType');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/auth/upload-avatar'),
      );

      request.headers['Cookie'] = 'token=$token';
      final multipartFile = await http.MultipartFile.fromPath(
        'avatar',
        _avatarImage!.path,
        contentType: MediaType('image', extension),
      );
      print('Multipart MIME type: ${multipartFile.contentType}');
      request.files.add(multipartFile);

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      print('Avatar upload response: $responseBody');

      final json = jsonDecode(responseBody);
      print('Parsed JSON: $json');

      if (response.statusCode == 200 && json['avatarUrl'] != null) {
        final user = ref.read(authProvider).user!;
        ref.read(authProvider.notifier).state = ref.read(authProvider).copyWith(
              user: UserModel(
                id: user.id,
                name: user.name,
                email: user.email,
                role: user.role,
                avatar: json['avatarUrl'],
                status: user.status,
                phoneNumber: user.phoneNumber,
                organizationName: user.organizationName,
                address: user.address,
                website: user.website,
                socialLinks: user.socialLinks,
                about: user.about,
                experience: user.experience,
                eventCategories: user.eventCategories,
                logo: user.logo,
                serviceProvided: user.serviceProvided,
                docs: user.docs,
                rating: user.rating,
                price: user.price,
                portfolio: user.portfolio,
                description: user.description,
                availability: user.availability,
                location: user.location,
              ),
            );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Avatar uploaded successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              json['error'] ?? json['message'] ?? 'Failed to upload avatar (Status: ${response.statusCode})',
            ),
          ),
        );
      }
    } catch (e) {
      print('Avatar upload error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading avatar: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_avatarImage != null) {
        await _uploadAvatar();
      }

      final token = await SecureStorage.getToken();
      if (token == null) throw Exception('No token found');

      final user = ref.read(authProvider).user!;
      final updatedData = {
        'name': _nameController.text,
        'phoneNumber': _phoneController.text,
        'organizationName': _organizationController.text,
        'website': _websiteController.text,
        'about': _aboutController.text,
        'location': _locationController.text,
        if (user.role == 'vendor')
          'serviceProvided': _serviceProvidedController.text,
        if (user.role == 'vendor') 'price': _priceController.text,
        if (user.role == 'organizer')
          'eventCategories': _eventCategoriesController.text
              .split(',')
              .map((e) => e.trim())
              .toList(),
        if (ref.read(authProvider).user!.avatar != null &&
            ref.read(authProvider).user!.avatar != 'default.jpg')
          'avatar': ref.read(authProvider).user!.avatar,
      };

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/auth/updateProfile/${user.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': 'token=$token',
        },
        body: jsonEncode(updatedData),
      );

      final json = jsonDecode(response.body);
      print('Profile update response: $json');

      if (response.statusCode == 200) {
        ref.read(authProvider.notifier).getProfile();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        context.go('/profile');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              json['message'] ??
                  'Failed to update profile (Status: ${response.statusCode})',
            ),
          ),
        );
      }
    } catch (e) {
      print('Profile update error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: _avatarImage != null
                                ? FileImage(_avatarImage!) as ImageProvider<Object>?
                                : user.avatar != null && user.avatar != 'default.jpg'
                                    ? CachedNetworkImageProvider(user.avatar!) as ImageProvider<Object>?
                                    : null,
                            child: _avatarImage == null &&
                                    (user.avatar == null || user.avatar == 'default.jpg')
                                ? const Icon(Icons.person, size: 60, color: Colors.grey)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt, color: Colors.white),
                              onPressed: _pickImage,
                              style: IconButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        onPressed: _avatarImage != null ? _uploadAvatar : null,
                        child: const Text('Upload Avatar'),
                      ),
                    ).animate().fadeIn(delay: const Duration(milliseconds: 100)),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value!.isEmpty ? 'Name is required' : null,
                    ).animate().fadeIn(delay: const Duration(milliseconds: 200)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                      ),
                    ).animate().fadeIn(delay: const Duration(milliseconds: 300)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _organizationController,
                      decoration: const InputDecoration(
                        labelText: 'Organization Name',
                        border: OutlineInputBorder(),
                      ),
                    ).animate().fadeIn(delay: const Duration(milliseconds: 400)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _websiteController,
                      decoration: const InputDecoration(
                        labelText: 'Website',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return null;
                        return RegExp(r'^https?://').hasMatch(value)
                            ? null
                            : 'Enter a valid URL';
                      },
                    ).animate().fadeIn(delay: const Duration(milliseconds: 500)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _aboutController,
                      decoration: const InputDecoration(
                        labelText: 'About',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ).animate().fadeIn(delay: const Duration(milliseconds: 600)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(),
                      ),
                    ).animate().fadeIn(delay: const Duration(milliseconds: 700)),
                    if (user.role == 'vendor') ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _serviceProvidedController,
                        decoration: const InputDecoration(
                          labelText: 'Service Provided',
                          border: OutlineInputBorder(),
                        ),
                      ).animate().fadeIn(delay: const Duration(milliseconds: 800)),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Price',
                          border: OutlineInputBorder(),
                        ),
                      ).animate().fadeIn(delay: const Duration(milliseconds: 900)),
                    ],
                    if (user.role == 'organizer') ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _eventCategoriesController,
                        decoration: const InputDecoration(
                          labelText: 'Event Categories (comma-separated)',
                          border: OutlineInputBorder(),
                        ),
                      ).animate().fadeIn(delay: const Duration(milliseconds: 1000)),
                    ],
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: _updateProfile,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: const Text('Save Changes'),
                      ),
                    ).animate().fadeIn(delay: const Duration(milliseconds: 1100)),
                  ],
                ),
              ),
            ),
    );
  }
}