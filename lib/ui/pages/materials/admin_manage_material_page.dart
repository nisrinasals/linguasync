import 'package:flutter/material.dart' hide MaterialState;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../logic/bloc/material/material_bloc.dart';
import '../../../../logic/bloc/material/material_event.dart';
import '../../../../logic/bloc/material/material_state.dart';
import '../../pages/materials/material_form_page.dart';
import '../../widgets/shimmer_loading.dart';

class AdminManageMaterialPage extends StatefulWidget {
  final int languageId;
  final String languageName;

  const AdminManageMaterialPage({
    super.key,
    required this.languageId,
    required this.languageName,
  });

  @override
  State<AdminManageMaterialPage> createState() =>
      _AdminManageMaterialPageState();
}

class _AdminManageMaterialPageState extends State<AdminManageMaterialPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    BlocProvider.of<MaterialBloc>(
      context,
    ).add(FetchMaterials(languageId: widget.languageId, isRefresh: true));
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = BlocProvider.of<MaterialBloc>(context).state;
      if (state is MaterialListLoaded && !state.hasReachedMax) {
        BlocProvider.of<MaterialBloc>(
          context,
        ).add(FetchMaterials(languageId: widget.languageId, isRefresh: false));
      }
    }
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Materi'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus bab materi pembelajaran ini secara permanen?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              BlocProvider.of<MaterialBloc>(
                context,
              ).add(DeleteMaterialRequested(id: id));
              Navigator.pop(context);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kelola Materi: ${widget.languageName}')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2C3E50),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  MaterialFormPage(languageId: widget.languageId),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: BlocListener<MaterialBloc, MaterialState>(
        listener: (context, state) {
          if (state is MaterialOperationSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            BlocProvider.of<MaterialBloc>(context).add(
              FetchMaterials(languageId: widget.languageId, isRefresh: true),
            );
          } else if (state is MaterialFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        child: BlocBuilder<MaterialBloc, MaterialState>(
          builder: (context, state) {
            if (state is MaterialLoading) {
              return ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) => const ShimmerLoading(),
              );
            }

            if (state is MaterialListLoaded) {
              if (state.materials.isEmpty) {
                return const Center(
                  child: Text('Belum ada materi terdaftar untuk bahasa ini.'),
                );
              }

              return ListView.builder(
                controller: _scrollController,
                itemCount: state.hasReachedMax
                    ? state.materials.length
                    : state.materials.length + 1,
                itemBuilder: (context, index) {
                  if (index >= state.materials.length) {
                    return const ShimmerLoading();
                  }

                  final material = state.materials[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey[200],
                        child: Text(
                          material.order.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      title: Text(
                        material.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: const Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text('Konten Pembelajaran Teks', maxLines: 1),
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
                                  builder: (context) => MaterialFormPage(
                                    languageId: widget.languageId,
                                    material: material,
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDelete(material.id),
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
    );
  }
}
