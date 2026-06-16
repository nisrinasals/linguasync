import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:linguasync/logic/bloc/auth/auth_bloc.dart';
import 'package:linguasync/logic/bloc/auth/auth_event.dart';
import '../../../../logic/bloc/language/language_bloc.dart';
import '../../../../logic/bloc/language/language_event.dart';
import '../../../../logic/bloc/language/language_state.dart';
import '../../widgets/language_card.dart';
import '../../widgets/shimmer_loading.dart';

class ExploreLanguagePage extends StatefulWidget {
  const ExploreLanguagePage({super.key});

  @override
  State<ExploreLanguagePage> createState() => _ExploreLanguagePageState();
}

class _ExploreLanguagePageState extends State<ExploreLanguagePage> {
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
        BlocProvider.of<LanguageBloc>(context).add(
          FetchLanguages(
            search: _searchController.text.trim(),
            isRefresh: false,
          ),
        );
      }
    }
  }

  void _onSearchChanged(String query) {
    BlocProvider.of<LanguageBloc>(
      context,
    ).add(FetchLanguages(search: query.trim(), isRefresh: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eksplorasi Bahasa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Konfirmasi Logout'),
                    content: const Text(
                      'Apakah Anda yakin ingin keluar dari aplikasi?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () =>
                            Navigator.of(context).pop(), 
                        child: const Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          context.read<AuthBloc>().add(LogoutRequested());
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/login',
                            (route) => false,
                          );
                        },
                        child: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Cari bahasa pembelajaran...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
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
                        child: Text('Tidak ada bahasa yang ditemukan.'),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        BlocProvider.of<LanguageBloc>(context).add(
                          FetchLanguages(
                            search: _searchController.text.trim(),
                            isRefresh: true,
                          ),
                        );
                      },
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: state.hasReachedMax
                            ? state.languages.length
                            : state.languages.length + 1,
                        itemBuilder: (context, index) {
                          if (index >= state.languages.length) {
                            return const ShimmerLoading();
                          }

                          final language = state.languages[index];
                          return LanguageCard(
                            language: language,
                            buttonText: 'Ikuti Kelas',
                            onButtonPressed: () {
                              BlocProvider.of<LanguageBloc>(context).add(
                                EnrollLanguageRequested(
                                  languageId: language.id,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  }

                  if (state is LanguageFailure) {
                    return Center(child: Text(state.error));
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
