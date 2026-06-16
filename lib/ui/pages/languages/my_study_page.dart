import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:linguasync/data/models/language_model.dart';
import '../../../../logic/bloc/language/language_bloc.dart';
import '../../../../logic/bloc/language/language_event.dart';
import '../../../../logic/bloc/language/language_state.dart';
import '../../pages/materials/detail_material_page.dart';
import '../../widgets/language_card.dart';
import '../../widgets/shimmer_loading.dart';
import '../../theme/japandi_theme.dart';

class MyStudyPage extends StatefulWidget {
  const MyStudyPage({super.key});

  @override
  State<MyStudyPage> createState() => _MyStudyPageState();
}

class _MyStudyPageState extends State<MyStudyPage> {
  final _scrollController = ScrollController();
  List<LanguageModel> _myLanguages = [];
  bool _hasReachedMax = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
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
      if (!_hasReachedMax &&
          BlocProvider.of<LanguageBloc>(context).state is! LanguageLoading) {
        BlocProvider.of<LanguageBloc>(context).add(const FetchMyLanguages(isRefresh: false));
      }
    }
  }

  void _confirmUnenroll(int enrollmentId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar Kelas', style: JT.titleMd),
        content: Text(
          'Apakah Anda yakin ingin menghapus bahasa ini dari daftar studi Anda?',
          style: JT.bodySm,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: JC.error),
            onPressed: () {
              BlocProvider.of<LanguageBloc>(context).add(
                UnenrollLanguageRequested(enrollmentId: enrollmentId),
              );
              Navigator.pop(ctx);
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Studi Saya')),
      body: BlocConsumer<LanguageBloc, LanguageState>(
        listener: (context, state) {
          if (state is LanguageOperationSuccess) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
            BlocProvider.of<LanguageBloc>(context).add(const FetchMyLanguages(isRefresh: true));
          } else if (state is LanguageFailure) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        builder: (context, state) {
          if (state is LanguageMyStudyLoaded) {
            _myLanguages = state.myLanguages;
            _hasReachedMax = state.hasReachedMax;
          }

          if (state is LanguageLoading && _myLanguages.isEmpty) {
            return ListView.builder(
              itemCount: 5,
              itemBuilder: (_, __) => const ShimmerLoading(),
            );
          }

          if (_myLanguages.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: JC.bgMuted,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.menu_book_outlined, size: 36, color: JC.inkLt),
                    ),
                    const SizedBox(height: 20),
                    const Text('Belum ada kelas diikuti', style: JT.titleMd),
                    const SizedBox(height: 8),
                    Text(
                      'Pilih bahasa di menu Eksplorasi untuk mulai belajar.',
                      textAlign: TextAlign.center,
                      style: JT.bodySm,
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            color: JC.primary,
            backgroundColor: JC.bgCard,
            onRefresh: () async {
              BlocProvider.of<LanguageBloc>(context).add(const FetchMyLanguages(isRefresh: true));
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(top: 8, bottom: 20),
              itemCount: _hasReachedMax
                  ? _myLanguages.length
                  : _myLanguages.length + 1,
              itemBuilder: (context, index) {
                if (index >= _myLanguages.length) return const ShimmerLoading();

                final language = _myLanguages[index];
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
                      top: 10,
                      right: 20,
                      child: Tooltip(
                        message: 'Hapus dari daftar',
                        child: InkWell(
                          onTap: () => _confirmUnenroll(language.id),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            child: const Icon(
                              Icons.remove_circle_outline,
                              color: JC.error,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
