import 'package:flutter/material.dart' hide MaterialState;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../logic/bloc/material/material_bloc.dart';
import '../../../../logic/bloc/material/material_event.dart';
import '../../../../logic/bloc/material/material_state.dart';
import '../../pages/materials/material_form_page.dart';
import '../../widgets/shimmer_loading.dart';
import '../../theme/japandi_theme.dart';

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
  final _searchController = TextEditingController();

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
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = BlocProvider.of<MaterialBloc>(context).state;
      if (state is MaterialListLoaded && !state.hasReachedMax) {
        BlocProvider.of<MaterialBloc>(
          context,
        ).add(FetchMaterials(
          languageId: widget.languageId,
          search: _searchController.text.trim(),
          isRefresh: false,
        ));
      }
    }
  }

  void _onSearchChanged(String query) {
    BlocProvider.of<MaterialBloc>(context).add(
      FetchMaterials(
        languageId: widget.languageId,
        search: query.trim(),
        isRefresh: true,
      ),
    );
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Materi', style: JT.titleMd),
        content: Text(
          'Apakah Anda yakin ingin menghapus bab materi pembelajaran ini secara permanen?',
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
              BlocProvider.of<MaterialBloc>(
                context,
              ).add(DeleteMaterialRequested(id: id));
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
    return Scaffold(
      appBar: AppBar(title: Text('Kelola Materi: ${widget.languageName}')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: JC.primary,
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
              FetchMaterials(
                languageId: widget.languageId,
                search: _searchController.text.trim(),
                isRefresh: true,
              ),
            );
          } else if (state is MaterialFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: const TextStyle(color: JC.ink, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Cari materi...',
                  hintStyle: const TextStyle(color: JC.inkLt, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: JC.inkLt, size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  filled: true,
                  fillColor: JC.bgCard,
                ),
              ),
            ),
            Expanded(
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
                        child: Text('Tidak ada materi ditemukan.', style: JT.body),
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
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: JC.primarySfc,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                material.order.toString(),
                                style: const TextStyle(
                                  color: JC.primary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            title: Text(
                              material.title,
                              style: JT.titleMd,
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
                                  icon: const Icon(Icons.delete, color: JC.error),
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
          ],
        ),
      ),
    );
  }
}
