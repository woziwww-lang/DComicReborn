import 'package:dcomic/providers/base_provider.dart';
import 'package:dcomic/providers/models/comic_source_model.dart';
import 'package:dcomic/providers/source_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class ComicLatestPageController extends BaseProvider {
  List<ListItemEntity> latestList = [];
  int _page = 0;
  bool _canLoad = true;
  BaseComicHomepageModel? _activeHomepageModel;
  String? errorMessage;

  bool get canLoad => _canLoad;

  Future<void> refresh(BuildContext context) async {
    _page = 0;
    var sourceProvider =
        Provider.of<ComicSourceProvider>(context, listen: false);
    var activeSource = sourceProvider.activeHomeModel;
    var sources = [
      activeSource,
      ...sourceProvider.hasHomepageSources
          .where((source) => source != activeSource),
    ];

    errorMessage = null;
    _activeHomepageModel = null;
    for (var source in sources) {
      try {
        var result = await source.homepage!.getLatestList(page: _page);
        if (result.isNotEmpty) {
          latestList = result;
          _activeHomepageModel = source.homepage;
          _canLoad = true;
          notifyListeners();
          return;
        }
      } catch (e, s) {
        logger.e('$e', error: e, stackTrace: s);
      }
    }

    latestList = [];
    _canLoad = false;
    errorMessage = '更新列表暂时无法加载，请检查网络后下拉刷新';
    notifyListeners();
  }

  Future<void> load(BuildContext context) async {
    if (_activeHomepageModel == null || !_canLoad) {
      return;
    }
    _page++;
    var result = await _activeHomepageModel!.getLatestList(page: _page);
    latestList += result;
    _canLoad = result.isNotEmpty;
    notifyListeners();
  }
}
