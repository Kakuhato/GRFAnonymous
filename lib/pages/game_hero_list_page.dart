import 'package:flutter/material.dart';
import '../models/userData.dart';
import '../pageRequest/myPageRequest.dart';
import '../ui/uiSizeUtil.dart';
import 'widgets/game_hero_card.dart';

class GameHeroListPage extends StatefulWidget {
  const GameHeroListPage({super.key});

  @override
  State<GameHeroListPage> createState() => _GameHeroListPageState();
}

class _GameHeroListPageState extends State<GameHeroListPage> {
  final _request = MyPageRequest();
  List<HeroList>? _heroes;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final heroes = await _request.fetchGameHeroes();
      if (!mounted) return;
      setState(() => _heroes = heroes);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = '人形列表加载失败，请重试');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          '人形列表',
          style: TextStyle(
            fontSize: UiSizeUtil.headerFontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: _loading && _heroes == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  if (_error != null)
                    Column(
                      children: [
                        Text(_error!, style: const TextStyle(color: Colors.red)),
                        TextButton(
                          onPressed: _loading ? null : _load,
                          child: const Text('重新加载'),
                        ),
                      ],
                    ),
                  if (_heroes != null)
                    if (_heroes!.isEmpty)
                      const Center(child: Text('暂无人形数据'))
                    else
                      LayoutBuilder(builder: (context, constraints) {
                        final columns = constraints.maxWidth < 300 ? 3 : 4;
                        final cardWidth = (constraints.maxWidth - (columns - 1) * 6) / columns;
                        return Wrap(
                          spacing: 6,
                          runSpacing: 10,
                          children: _heroes!.map((hero) => SizedBox(
                            width: cardWidth,
                            child: GameHeroCard(hero: hero),
                          )).toList(),
                        );
                      }),
                ],
              ),
            ),
    );
  }
}
