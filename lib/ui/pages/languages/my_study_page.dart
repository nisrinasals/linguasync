import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../logic/bloc/language/language_bloc.dart';
import '../../../../logic/bloc/language/language_event.dart';
import '../../../../logic/bloc/language/language_state.dart';
import '../../pages/materials/detail_material_page.dart';
import '../../widgets/language_card.dart';
import '../../widgets/shimmer_loading.dart';

class MyStudyPage extends StatefulWidget {
  const MyStudyPage({super.key});

  @override
  State<MyStudyPage> createState() => _MyStudyPageState();
}

class _MyStudyPageState extends State<MyStudyPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    BlocProvider.of<LanguageBloc>(
      context,
    ).add(const FetchMyLanguages(isRefresh: true));
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
      if (state is LanguageMyStudyLoaded && !state.hasReachedMax) {
        BlocProvider.of<LanguageBloc>(
          context,
        ).add(const FetchMyLanguages(isRefresh: false));
      }
    }
  }

  void _confirmUnenroll(int enrollmentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar Kelas'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus bahasa ini dari daftar studi Anda?',
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
              ).add(UnenrollLanguageRequested(enrollmentId: enrollmentId));
              Navigator.pop(context);
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Studi Saya (MyStudy)')),
      body: BlocListener<LanguageBloc, LanguageState>(
        listener: (context, state) {
          if (state is LanguageOperationSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            BlocProvider.of<LanguageBloc>(
              context,
            ).add(const FetchMyLanguages(isRefresh: true));
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

            if (state is LanguageMyStudyLoaded) {
              if (state.myLanguages.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.menu_book,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada kelas yang diikuti.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Silakan pilih dan ikuti bahasa pembelajaran di menu Eksplorasi.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  BlocProvider.of<LanguageBloc>(
                    context,
                  ).add(const FetchMyLanguages(isRefresh: true));
                },
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: state.hasReachedMax
                      ? state.myLanguages.length
                      : state.myLanguages.length + 1,
                  itemBuilder: (context, index) {
                    if (index >= state.myLanguages.length) {
                      return const ShimmerLoading();
                    }

                    final language = state.myLanguages[index];
                    return Stack(
                      children: [
                        LanguageCard(
                          language: language,
                          buttonText: 'Mulai Belajar',
                          onButtonPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailMaterialPage(
                                  languageId: language.id,
                                  languageName: language.name,
                                ),
                              ),
                            );
                          },
                        ),
                        Positioned(
                          top: 12,
                          right: 20,
                          child: IconButton(
                            icon: Icon(
                              Icons.remove_circle_outline,
                              color: Colors.red[400],
                              size: 22,
                            ),
                            onPressed: () => _confirmUnenroll(language.id),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            }

            if (state is LanguageFailure) {
              return Center(
                child: Text(
                  state.error,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}
