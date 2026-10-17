import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/userData.dart';
import '../pageRequest/myPageRequest.dart';
import '../ui/uiSizeUtil.dart';

class GameDataPage extends StatefulWidget {
  const GameDataPage({super.key});

  @override
  State<GameDataPage> createState() => _GameDataPageState();
}

class _GameDataPageState extends State<GameDataPage> {
  final _request = MyPageRequest();
  GameData? _data;
  bool _loading = true;
  String? _error;
  bool _showAllHeroes = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await _request.fetchGameData();
      if (!mounted) return;
      setState(() {
        _data = data;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = '游戏数据加载失败，请重试');
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
        title: Text(
          '游戏数据',
          style: TextStyle(
            fontSize: UiSizeUtil.headerFontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _data == null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error ?? '暂无游戏数据'),
                      TextButton(
                        onPressed: () {
                          setState(() => _loading = true);
                          _load();
                        },
                        child: const Text('重新加载'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      _header(_data!.userInfo),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(_error!, style: const TextStyle(color: Colors.red)),
                        ),
                      _section('基础资料', _baseInfo(_data!.baseInfo)),
                      _section(
                        '人形展示',
                        _heroes(_data!.heroList),
                        action: _data!.heroList.length > 4
                            ? TextButton(
                                onPressed: () => setState(() => _showAllHeroes = !_showAllHeroes),
                                child: Text(_showAllHeroes ? '收起' : '查看更多'),
                              )
                            : null,
                      ),
                      _section('游戏战绩', _stages(_data!.stageInfo)),
                      _section('主题活动', _themes(_data!.themeInfo)),
                    ],
                  ),
                ),
    );
  }

  Widget _header(UserInfo user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/gameDataBG.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: 72, height: 72, child: _image(user.avatar, BoxFit.cover)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${user.nickName}  Lv.${user.level}',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text('UID: ${user.gameUid}', style: const TextStyle(color: Colors.white70)),
                    IconButton(
                      tooltip: '复制 UID',
                      icon: const Icon(Icons.copy, size: 18, color: Colors.white70),
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: '${user.gameUid}'));
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('UID 已复制')));
                      },
                    ),
                  ],
                ),
                Text('班组：${user.guildName.isEmpty ? '暂无' : user.guildName}',
                    style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, Widget child, {Widget? action}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            if (action != null) action,
          ]),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _baseInfo(BaseInfo base) {
    final items = <String, String>{
      '人形收集数': '${base.heroCount}',
      '活跃天数': '${base.activeDays}',
      '主线进度': base.mainStage,
      '衣装收集数': '${base.skinCount}',
      '武器收集数': '${base.weaponCount}',
      '里程碑': '${base.achievementCount}',
    };
    return LayoutBuilder(builder: (context, constraints) {
      return Wrap(
        spacing: 6,
        runSpacing: 6,
        children: items.entries.map((item) => Container(
          width: (constraints.maxWidth - 12) / 3,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/baseDataBG.png'),
              // 完整保留图片自带的圆角和阴影，不添加外框或裁剪。
              fit: BoxFit.fill,
            ),
          ),
          child: Column(children: [
            Text(item.value == '-1' ? '—' : item.value,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Text(item.key, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
          ]),
        )).toList(),
      );
    });
  }

  Widget _heroes(List<HeroList> heroes) {
    if (heroes.isEmpty) return const Text('暂无人形展示');
    final visible = _showAllHeroes ? heroes : heroes.take(4).toList();
    return LayoutBuilder(builder: (context, constraints) {
      final columns = constraints.maxWidth < 300 ? 3 : 4;
      return Wrap(
        spacing: 6,
        runSpacing: 10,
        children: visible.map((hero) => SizedBox(
          width: (constraints.maxWidth - (columns - 1) * 6) / columns,
          child: _heroCard(hero),
        )).toList(),
      );
    });
  }

  Widget _heroCard(HeroList hero) {
    final imageUrl = hero.skin.trim().isNotEmpty ? hero.skin : hero.showPic;
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final badgeSize = width * 0.2;
      // 原图四周包含边框和阴影，叠加内容需放在卡片内部。
      final contentInset = width * 0.06;
      final fallback = AspectRatio(
        aspectRatio: 0.625,
        child: Center(child: Text(hero.name, textAlign: TextAlign.center)),
      );
      return Semantics(
        label: '${hero.name}，等级 ${hero.lv}，grade ${hero.grade}',
        child: Stack(
          children: [
            // 卡面已包含角色名和底部等级栏，优先使用皮肤卡面。
            if (imageUrl.isEmpty)
              fallback
            else
              CachedNetworkImage(
                imageUrl: imageUrl,
                width: width,
                fit: BoxFit.fitWidth,
                placeholder: (_, __) => fallback,
                errorWidget: (_, __, ___) => fallback,
              ),
            Positioned(
              top: contentInset,
              right: contentInset,
              width: badgeSize,
              height: badgeSize,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset('assets/grade.png'),
                  Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${hero.grade}',
                        textScaler: TextScaler.noScaling,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: badgeSize * 0.72,
                          height: 1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: contentInset,
              right: contentInset,
              bottom: width * 0.065,
              child: Text(
                'lv.${hero.lv}',
                textAlign: TextAlign.center,
                textScaler: TextScaler.noScaling,
                style: TextStyle(
                  color: Colors.deepOrange,
                  fontSize: width * 0.15,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _stages(StageInfo stages) {
    final entries = stages.entries;
    if (entries.isEmpty) return const Text('暂无游戏战绩');
    return Column(
      children: entries.map((stage) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            AspectRatio(aspectRatio: 3.7, child: _image(stage.image, BoxFit.cover)),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              // color: Colors.black54,
              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(stage.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                if (stage.detail.isNotEmpty)
                  Text(stage.detail, textAlign: TextAlign.right, style: const TextStyle(color: Colors.white)),
              ]),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _themes(List<ThemeInfo> themes) {
    if (themes.isEmpty) return const Text('暂无主题活动数据');
    return LayoutBuilder(builder: (context, constraints) {
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: themes.map((theme) => SizedBox(
          width: (constraints.maxWidth - 10) / 2,
          child: _themeCard(theme),
        )).toList(),
      );
    });
  }

  Widget _themeCard(ThemeInfo theme) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      const fallback = AspectRatio(
        aspectRatio: 1.7,
        child: Center(child: Icon(Icons.image_outlined, color: Colors.grey)),
      );
      return Stack(
        children: [
          // 图片自带边框、阴影及底部灰色信息栏，不再额外添加外部文字行。
          if (theme.showPic.isEmpty)
            fallback
          else
            CachedNetworkImage(
              imageUrl: theme.showPic,
              width: width,
              fit: BoxFit.fitWidth,
              placeholder: (_, __) => fallback,
              errorWidget: (_, __, ___) => fallback,
            ),
          Positioned(
            left: width * 0.05,
            right: width * 0.05,
            bottom: width * 0.035,
            child: Text(
              '已完成：${theme.completePercent}%',
              textAlign: TextAlign.center,
              textScaler: TextScaler.noScaling,
              style: TextStyle(
                color: const Color(0xFF263238),
                fontSize: width * 0.085,
                height: 1,
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _image(String url, BoxFit fit) {
    if (url.isEmpty) return const Center(child: Icon(Icons.image_not_supported_outlined, color: Colors.grey));
    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      placeholder: (_, __) => const Center(child: Icon(Icons.image_outlined, color: Colors.grey)),
      errorWidget: (_, __, ___) => const Center(child: Icon(Icons.broken_image_outlined, color: Colors.grey)),
    );
  }
}
