import 'package:dcomic/providers/base_provider.dart';
import 'package:dcomic/providers/models/comic_source_model.dart';
import 'package:dcomic/providers/source_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ComicHomepageController extends BaseProvider {
  List<HomepageCardEntity> homepageCards = [];
  List<CarouselEntity> homepageCarousels = [];
  bool isLoading = false;
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
    await refreshHomepageModels(
      sources
          .map((source) => source.homepage)
          .whereType<BaseComicHomepageModel>()
          .toList(),
    );
  }

  Future<void> refreshHomepageModels(
      List<BaseComicHomepageModel> homepageModels) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    for (var homepageModel in homepageModels) {
      List<CarouselEntity> carousels = [];
      List<HomepageCardEntity> cards = [];

      try {
        carousels = await homepageModel.getHomepageCarousel();
      } catch (e, s) {
        logger.e('$e', error: e, stackTrace: s);
      }

      try {
        cards = await homepageModel.getHomepageCard();
      } catch (e, s) {
        logger.e('$e', error: e, stackTrace: s);
      }

      if (carousels.isNotEmpty || cards.isNotEmpty) {
        homepageCarousels = carousels;
        homepageCards = cards;
        isLoading = false;
        errorMessage = null;
        notifyListeners();
        return;
      }
    }

    homepageCarousels = [];
    homepageCards = [];
    isLoading = false;
    errorMessage = '所有漫画源暂时无法加载，请检查网络后下拉刷新';
    notifyListeners();
  }
}
