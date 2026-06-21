import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'admin_manage_material_page.dart';
import 'admin_manage_quiz_page.dart';
import '../../../logic/bloc/language/language_bloc.dart';
import '../../../logic/bloc/language/language_event.dart';
import '../../../logic/bloc/language/language_state.dart';
import '../../../logic/bloc/admin_language/admin_language_bloc.dart';
import '../../../logic/bloc/admin_language/admin_language_event.dart';
import '../../../logic/bloc/admin_language/admin_language_state.dart';
import 'language_form_page.dart';
import '../../widgets/shimmer_loading.dart';
import '../../theme/japandi_theme.dart';

class AdminManageLanguagePage extends StatefulWidget {
  const AdminManageLanguagePage({super.key});

  @override
  State<AdminManageLanguagePage> createState() =>
      _AdminManageLanguagePageState();
}

class _AdminManageLanguagePageState extends State<AdminManageLanguagePage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    BlocProvider.of<LanguageBloc>(
      context,
    ).add(const FetchLanguages(isRefresh: true));
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
      final state = BlocProvider.of<LanguageBloc>(context).state;
      if (state is LanguageExploreLoaded && !state.hasReachedMax) {
        BlocProvider.of<LanguageBloc>(
          context,
        ).add(FetchLanguages(search: _searchController.text.trim(), isRefresh: false));
      }
    }
  }

  void _onSearchChanged(String query) {
    BlocProvider.of<LanguageBloc>(context)
        .add(FetchLanguages(search: query.trim(), isRefresh: true));
  }

  void _confirmDelete(int id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Bahasa', style: JT.titleMd),
        content: Text(
          'Apakah Anda yakin ingin menghapus bahasa "$name"? Seluruh materi dan kuis di dalamnya akan ikut terhapus.',
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
              BlocProvider.of<AdminLanguageBloc>(
                context,
              ).add(DeleteLanguageRequested(id: id));
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
      appBar: AppBar(title: const Text('Kelola Bahasa (Admin)')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: JC.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LanguageFormPage()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<AdminLanguageBloc, AdminLanguageState>(
            listener: (context, state) {
              if (state is AdminLanguageOperationSuccess) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
                BlocProvider.of<LanguageBloc>(
                  context,
                ).add(FetchLanguages(search: _searchController.text.trim(), isRefresh: true));
              } else if (state is AdminLanguageFailure) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.error), backgroundColor: JC.error));
              }
            },
          ),
        ],
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: const TextStyle(color: JC.ink, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Cari bahasa...',
                  hintStyle: const TextStyle(color: JC.inkLt, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: JC.inkLt, size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  filled: true,
                  fillColor: JC.bgCard,
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<LanguageBloc, LanguageState>(
                builder: (context, state) {
                  if (state is LanguageLoading) {
                    return ListView.builder(
                      itemCount: 5,
                      itemBuilder: (context, index) => const ShimmerLoading(),
                    );
                  }

                  if (state is LanguageExploreLoaded) {
                    if (state.languages.isEmpty) {
                      return const Center(
                        child: Text('Tidak ada bahasa ditemukan.', style: JT.body),
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: state.hasReachedMax
                          ? state.languages.length
                          : state.languages.length + 1,
                      itemBuilder: (context, index) {
                        if (index >= state.languages.length) {
                          return const ShimmerLoading();
                        }

                        final language = state.languages[index];
                        return Card(
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            title: Text(
                              language.name,
                              style: JT.titleMd,
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Text(
                                language.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: JT.bodySm,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.book,
                                    color: JC.primary,
                                  ), // Akses ke Materi
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AdminManageMaterialPage(
                                          languageId: language.id,
                                          languageName: language.name,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.quiz,
                                    color: JC.clay,
                                  ), // Akses ke Kuis
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AdminManageQuizPage(
                                          languageId: language.id,
                                          languageName: language.name,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.orange),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            LanguageFormPage(language: language),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: JC.error),
                                  onPressed: () => _confirmDelete(language.id, language.name),
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
