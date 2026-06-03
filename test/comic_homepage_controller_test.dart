import 'package:dcomic/providers/models/comic_source_model.dart';
import 'package:dcomic/providers/page_controllers/comic_homepage_controller.dart';
import 'package:dcomic/utils/image_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('refreshHomepageModels falls back to the next source when one fails',
      () async {
    final controller = ComicHomepageController();
    final workingCard = HomepageCardEntity('可用数据源', null, null, []);
    final workingCarousel = CarouselEntity(
      ImageEntity(ImageType.unknown, ''),
      '可用轮播',
      null,
    );

    await controller.refreshHomepageModels([
      _FailingHomepageModel(),
      _SuccessfulHomepageModel(
        cards: [workingCard],
        carousels: [workingCarousel],
      ),
    ]);

    expect(controller.homepageCards, [workingCard]);
    expect(controller.homepageCarousels, [workingCarousel]);
    expect(controller.errorMessage, isNull);
    expect(controller.isLoading, isFalse);
  });

  test('refreshHomepageModels exposes an error when every source fails',
      () async {
    final controller = ComicHomepageController();

    await controller.refreshHomepageModels([
      _FailingHomepageModel(),
      _FailingHomepageModel(),
    ]);

    expect(controller.homepageCards, isEmpty);
    expect(controller.homepageCarousels, isEmpty);
    expect(controller.errorMessage, isNotNull);
    expect(controller.isLoading, isFalse);
  });
}

class _FailingHomepageModel extends _FakeHomepageModel {
  @override
  Future<List<CarouselEntity>> getHomepageCarousel() {
    throw Exception('network failed');
  }
}

class _SuccessfulHomepageModel extends _FakeHomepageModel {
  final List<HomepageCardEntity> cards;
  final List<CarouselEntity> carousels;

  _SuccessfulHomepageModel({required this.cards, required this.carousels});

  @override
  Future<List<CarouselEntity>> getHomepageCarousel() async => carousels;

  @override
  Future<List<HomepageCardEntity>> getHomepageCard() async => cards;
}

abstract class _FakeHomepageModel extends BaseComicHomepageModel {
  @override
  List<FilterEntity> get categoryFilter => [];

  @override
  Future<List<GridItemEntity>> getCategoryList() async => [];

  @override
  Future<List<ListItemEntity>> getCategoryDetailList({
    required String categoryId,
    required Map<String, dynamic> categoryFilter,
    int page = 0,
    int categoryType = 0,
  }) async =>
      [];

  @override
  Future<List<HomepageCardEntity>> getHomepageCard() async => [];

  @override
  Future<List<CarouselEntity>> getHomepageCarousel() async => [];

  @override
  Future<List<ListItemEntity>> getLatestList({int page = 0}) async => [];

  @override
  Future<List<ListItemEntity>> getRankingList({int page = 0}) async => [];
}
