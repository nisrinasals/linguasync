import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/auth_model.dart';
import '../../../logic/bloc/admin_user/admin_user_bloc.dart';
import '../../../logic/bloc/admin_user/admin_user_event.dart';
import '../../../logic/bloc/admin_user/admin_user_state.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../theme/japandi_theme.dart';

class UserFormPage extends StatefulWidget {
  final UserModel? user;

  const UserFormPage({super.key, this.user});

  @override
  State<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late String _selectedRole;

  bool get isEdit => widget.user != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _nameController.text = widget.user!.name;
      _emailController.text = widget.user!.email;
      _selectedRole = widget.user!.role;
    } else {
      _selectedRole = 'user';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _saveUser() {
    if (_formKey.currentState!.validate()) {
      if (isEdit) {
        context.read<AdminUserBloc>().add(
              UpdateAdminUser(
                id: widget.user!.id,
                name: _nameController.text.trim(),
                email: _emailController.text.trim(),
                password: _passwordController.text.isNotEmpty
                    ? _passwordController.text
                    : null,
                role: _selectedRole,
              ),
            );
      } else {
        context.read<AdminUserBloc>().add(
              CreateAdminUser(
                name: _nameController.text.trim(),
                email: _emailController.text.trim(),
                password: _passwordController.text,
                role: _selectedRole,
              ),
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Pengguna' : 'Tambah Pengguna'),
      ),
      body: BlocConsumer<AdminUserBloc, AdminUserState>(
        listener: (context, state) {
          if (state is AdminUserOperationSuccess) {
            Navigator.pop(context);
          } else if (state is AdminUserFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: JC.error),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AdminUserLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEdit ? 'Ubah Informasi Pengguna' : 'Detail Pengguna Baru',
                            style: JT.titleMd,
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            controller: _nameController,
                            label: 'Nama Lengkap',
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
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _passwordController,
                            label: isEdit ? 'Password Baru (Opsional)' : 'Password',
                            isPassword: true,
                            hintText: isEdit ? 'Biarkan kosong jika tidak diubah' : null,
                            validator: (value) {
                              if (!isEdit && (value == null || value.isEmpty)) {
                                return 'Password wajib diisi.';
                              }
                              if (value != null && value.isNotEmpty && value.length < 6) {
                                return 'Password minimal 6 karakter.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Dropdown Role
                          DropdownButtonFormField<String>(
                            value: _selectedRole,
                            decoration: const InputDecoration(
                              labelText: 'Peran (Role)',
                            ),
                            items: const [
                              DropdownMenuItem(value: 'user', child: Text('User')),
                              DropdownMenuItem(value: 'admin', child: Text('Admin')),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedRole = value;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: isEdit ? 'Simpan Perubahan' : 'Tambah Pengguna',
                    isLoading: isLoading,
                    onPressed: _saveUser,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
