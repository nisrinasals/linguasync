import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/bloc/admin_user/admin_user_bloc.dart';
import '../../../logic/bloc/admin_user/admin_user_event.dart';
import '../../../logic/bloc/admin_user/admin_user_state.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../widgets/shimmer_loading.dart';
import '../../theme/japandi_theme.dart';
import 'user_form_page.dart';

class AdminManageUserPage extends StatefulWidget {
  const AdminManageUserPage({super.key});

  @override
  State<AdminManageUserPage> createState() => _AdminManageUserPageState();
}

class _AdminManageUserPageState extends State<AdminManageUserPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  String _selectedRole = ''; // empty means all roles

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    BlocProvider.of<AdminUserBloc>(context).add(
      const FetchAdminUsers(isRefresh: true),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = BlocProvider.of<AdminUserBloc>(context).state;
      if (state is AdminUserLoaded && !state.hasReachedMax) {
        BlocProvider.of<AdminUserBloc>(context).add(
          FetchAdminUsers(
            search: _searchController.text.trim(),
            role: _selectedRole,
            isRefresh: false,
          ),
        );
      }
    }
  }

  void _onSearchChanged(String query) {
    BlocProvider.of<AdminUserBloc>(context).add(
      FetchAdminUsers(
        search: query.trim(),
        role: _selectedRole,
        isRefresh: true,
      ),
    );
  }

  void _onRoleFilterChanged(String? role) {
    if (role != null) {
      setState(() {
        _selectedRole = role;
      });
      BlocProvider.of<AdminUserBloc>(context).add(
        FetchAdminUsers(
          search: _searchController.text.trim(),
          role: role,
          isRefresh: true,
        ),
      );
    }
  }

  void _confirmDelete(int id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Pengguna', style: JT.titleMd),
        content: Text(
          'Apakah Anda yakin ingin menghapus pengguna "$name"? Seluruh riwayat belajar kuis akan ikut terhapus.',
          style: JT.bodySm,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: JC.error),
            onPressed: () {
              BlocProvider.of<AdminUserBloc>(context).add(
                DeleteAdminUser(id: id),
              );
              Navigator.pop(context);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final storageProvider = context.read<AuthRepository>().storageProvider;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Pengguna (Admin)'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: JC.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UserFormPage()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: BlocListener<AdminUserBloc, AdminUserState>(
        listener: (context, state) {
          if (state is AdminUserOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            BlocProvider.of<AdminUserBloc>(context).add(
              FetchAdminUsers(
                search: _searchController.text.trim(),
                role: _selectedRole,
                isRefresh: true,
              ),
            );
          } else if (state is AdminUserFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: JC.error),
            );
          }
        },
        child: Column(
          children: [
            // Search and Filter Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      style: const TextStyle(color: JC.ink, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Cari nama/email...',
                        hintStyle: const TextStyle(color: JC.inkLt, fontSize: 14),
                        prefixIcon: const Icon(Icons.search, color: JC.inkLt, size: 20),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        filled: true,
                        fillColor: JC.bgCard,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Dropdown Filter Role
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: JC.bgCard,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: JC.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedRole,
                        icon: const Icon(Icons.filter_list, color: JC.primary),
                        style: const TextStyle(color: JC.ink, fontSize: 14),
                        onChanged: _onRoleFilterChanged,
                        items: const [
                          DropdownMenuItem(value: '', child: Text('Semua Role')),
                          DropdownMenuItem(value: 'user', child: Text('User')),
                          DropdownMenuItem(value: 'admin', child: Text('Admin')),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Users List
            Expanded(
              child: BlocBuilder<AdminUserBloc, AdminUserState>(
                builder: (context, state) {
                  if (state is AdminUserLoading) {
                    return ListView.builder(
                      itemCount: 5,
                      itemBuilder: (context, index) => const ShimmerLoading(),
                    );
                  }

                  if (state is AdminUserLoaded) {
                    if (state.users.isEmpty) {
                      return const Center(
                        child: Text(
                          'Tidak ada pengguna ditemukan.',
                          style: JT.body,
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: state.hasReachedMax
                          ? state.users.length
                          : state.users.length + 1,
                      itemBuilder: (context, index) {
                        if (index >= state.users.length) {
                          return const ShimmerLoading();
                        }

                        final user = state.users[index];
                        final hasPhoto = user.fotoProfile != null && user.fotoProfile!.isNotEmpty;

                        return Card(
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: CircleAvatar(
                              radius: 24,
                              backgroundColor: JC.primary.withOpacity(0.1),
                              backgroundImage: hasPhoto
                                  ? NetworkImage(storageProvider.getProfileImageUrl(user.fotoProfile))
                                  : null,
                              child: !hasPhoto
                                  ? const Icon(Icons.person, color: JC.primary)
                                  : null,
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    user.name,
                                    style: JT.titleMd,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: user.role == 'admin' ? JC.clayLt : JC.primarySfc,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    user.role.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: user.role == 'admin' ? JC.clay : JC.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                user.email,
                                style: JT.bodySm,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.orange),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => UserFormPage(user: user),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: JC.error),
                                  onPressed: () => _confirmDelete(user.id, user.name),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
