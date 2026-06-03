import 'package:dcomic/providers/base_provider.dart';
import 'package:dcomic/providers/models/comic_source_model.dart';
import 'package:dcomic/providers/source_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ComicCategoryPageController extends BaseProvider {
  List<GridItemEntity> categories = [];
  String? errorMessage;

  Future<void> refresh(BuildContext context) async {
    var sourceProvider =
        Provider.of<ComicSourceProvider>(context, listen: false);
    var activeSource = sourceProvider.activeHomeModel;
    var sources = [
      activeSource,
      ...sourceProvider.hasHomepageSources
          .where((source) => source != activeSource),
    ];

    errorMessage = null;
    for (var source in sources) {
      try {
        var result = await source.homepage!.getCategoryList();
        if (result.isNotEmpty) {
          categories = result;
          notifyListeners();
          return;
        }
      } catch (e, s) {
        logger.e('$e', error: e, stackTrace: s);
      }
    }

    categories = [];
    errorMessage = '分类暂时无法加载，请检查网络后下拉刷新';
    notifyListeners();
  }
}
