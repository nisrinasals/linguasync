import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../pages/materials/admin_manage_material_page.dart';
import '../../pages/quiz/admin_manage_quiz.dart';
import '../../../../logic/bloc/language/language_bloc.dart';
import '../../../../logic/bloc/language/language_event.dart';
import '../../../../logic/bloc/language/language_state.dart';
import '../../pages/languages/language_form_page.dart';
import '../../widgets/shimmer_loading.dart';

class AdminManageLanguagePage extends StatefulWidget {
  const AdminManageLanguagePage({super.key});

  @override
  State<AdminManageLanguagePage> createState() =>
      _AdminManageLanguagePageState();
}

class _AdminManageLanguagePageState extends State<AdminManageLanguagePage> {
  final _scrollController = ScrollController();

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
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = BlocProvider.of<LanguageBloc>(context).state;
      if (state is LanguageExploreLoaded && !state.hasReachedMax) {
        BlocProvider.of<LanguageBloc>(
          context,
        ).add(FetchLanguages(search: state.search, isRefresh: false));
      }
    }
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Bahasa'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus bahasa ini? Seluruh materi dan kuis di dalamnya akan ikut terhapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              BlocProvider.of<LanguageBloc>(
                context,
              ).add(DeleteLanguageRequested(id: id));
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
      appBar: AppBar(title: const Text('Kelola Bahasa (Admin)')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2C3E50),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LanguageFormPage()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: BlocListener<LanguageBloc, LanguageState>(
        listener: (context, state) {
          if (state is LanguageOperationSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            BlocProvider.of<LanguageBloc>(
              context,
            ).add(const FetchLanguages(isRefresh: true));
          } else if (state is LanguageFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
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
                  child: Text('Belum ada data bahasa tersedia.'),
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
                    margin: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      title: Text(
                        language.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(
                          language.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.book,
                              color: Colors.blue,
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
                              color: Colors.green,
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
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDelete(language.id),
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
