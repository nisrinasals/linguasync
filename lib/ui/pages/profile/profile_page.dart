import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../../data/models/auth_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../logic/bloc/auth/auth_bloc.dart';
import '../../../logic/bloc/auth/auth_event.dart';
import '../../../logic/bloc/profile/profile_bloc.dart';
import '../../../logic/bloc/profile/profile_event.dart';
import '../../../logic/bloc/profile/profile_state.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../theme/japandi_theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  
  String? _pickedFilePath;
  bool _isInit = false;
  UserModel? _currentUser;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(FetchProfile());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          _pickedFilePath = result.files.single.path;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih gambar: ${e.toString()}')),
      );
    }
  }

  void _submitUpdate() {
    if (_formKey.currentState!.validate()) {
      context.read<ProfileBloc>().add(
        UpdateProfileRequested(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          filePath: _pickedFilePath,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Profil'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
                if (!_isEditing && _currentUser != null) {
                  _nameController.text = _currentUser!.name;
                  _emailController.text = _currentUser!.email;
                  _pickedFilePath = null;
                }
              });
            },
          ),
        ],
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded) {
            _currentUser = state.user;
            if (!_isInit) {
              _nameController.text = state.user.name;
              _emailController.text = state.user.email;
              _isInit = true;
            }
          }
          if (state is ProfileUpdateSuccess) {
            _currentUser = state.user;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            // Sinkronkan ke auth bloc global
            context.read<AuthBloc>().add(UserUpdated(user: state.user));
            setState(() {
              _pickedFilePath = null;
              _isEditing = false;
            });
          } else if (state is ProfileFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: JC.error),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading && _currentUser == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_currentUser != null) {
            final user = _currentUser!;
            final storageProvider = context.read<AuthRepository>().storageProvider;
            final isSaving = state is ProfileLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Profile Photo Widget
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: JC.primary, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 64,
                              backgroundColor: JC.bgMuted,
                              backgroundImage: _pickedFilePath != null
                                  ? FileImage(File(_pickedFilePath!))
                                  : (user.fotoProfile != null && user.fotoProfile!.isNotEmpty)
                                      ? NetworkImage(storageProvider.getProfileImageUrl(user.fotoProfile))
                                      : null,
                              child: (_pickedFilePath == null &&
                                      (user.fotoProfile == null || user.fotoProfile!.isEmpty))
                                  ? const Icon(
                                      Icons.person,
                                      size: 64,
                                      color: JC.inkLt,
                                    )
                                  : null,
                            ),
                          ),
                          if (_isEditing)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: InkWell(
                                onTap: _pickImage,
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: JC.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user.name,
                      style: JT.titleLg,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: user.role == 'admin' ? JC.clayLt : JC.primarySfc,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        user.role.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: user.role == 'admin' ? JC.clay : JC.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Inputs Card
                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Informasi Akun',
                              style: JT.titleMd,
                            ),
                            const SizedBox(height: 20),
                            CustomTextField(
                              controller: _nameController,
                              label: 'Nama Lengkap',
                              enabled: _isEditing,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Nama lengkap wajib diisi.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _emailController,
                              label: 'Alamat Email',
                              enabled: _isEditing,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Email wajib diisi.';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                  return 'Format email tidak valid.';
                                }
                                return null;
                              },
                            ),

                          ],
                        ),
                      ),
                    ),

                    if (_isEditing) ...[
                      const SizedBox(height: 32),
                      CustomButton(
                        text: 'Simpan Perubahan',
                        isLoading: isSaving,
                        onPressed: _submitUpdate,
                      ),
                    ],
                  ],
                ),
              ),
            );
          }

          return const Center(child: Text('Gagal memuat profil.', style: JT.body));
        },
      ),
    );
  }
}
