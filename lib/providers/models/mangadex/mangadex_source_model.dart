import 'package:date_format/date_format.dart' as date_format;
import 'package:dcomic/providers/models/comic_source_model.dart';
import 'package:dcomic/providers/navigator_provider.dart';
import 'package:dcomic/requests/base_request.dart';
import 'package:dcomic/utils/image_utils.dart';
import 'package:dcomic/view/category_pages/comic_category_detail_page.dart';
import 'package:dcomic/view/comic_pages/comic_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MangaDexSourceModel extends BaseComicSourceModel {
  @override
  ComicSourceEntity get type => ComicSourceEntity('MangaDex', 'mangadex',
      hasHomepage: true, hasAccountSupport: false, hasComment: false);

  @override
  BaseComicHomepageModel? get homepage => MangaDexHomepageModel(this);

  @override
  Future<BaseComicDetailModel?> getComicDetail(
      String comicId, String title) async {
    try {
      var detailResponse =
          await RequestHandlers.mangaDexRequestHandler.getMangaDetail(comicId);
      var aggregateResponse = await RequestHandlers.mangaDexRequestHandler
          .getMangaAggregate(comicId);
      if (detailResponse.statusCode == 200 &&
          detailResponse.data['result'] == 'ok') {
        return MangaDexComicDetailModel(
          detailResponse.data['data'],
          aggregateResponse.data['volumes'] ?? {},
          this,
        );
      }
    } catch (e, s) {
      logger.e('$e', error: e, stackTrace: s);
    }
    return null;
  }

  @override
  Future<List<ComicListItemEntity>> searchComicDetail(String keyword,
      {int page = 0}) async {
    try {
      var response = await RequestHandlers.mangaDexRequestHandler
          .search(keyword, page: page);
      if (response.statusCode == 200 && response.data['result'] == 'ok') {
        return (response.data['data'] as List)
            .map<ComicListItemEntity>((item) => _toComicListItem(item, this))
            .toList();
      }
    } catch (e, s) {
      logger.e('$e', error: e, stackTrace: s);
    }
    return [];
  }
}

class MangaDexHomepageModel extends BaseComicHomepageModel {
  final MangaDexSourceModel parent;

  MangaDexHomepageModel(this.parent);

  @override
  Future<List<HomepageCardEntity>> getHomepageCard() async {
    var latest = await _getMangaCard(
      title: '最近更新',
      icon: Icons.update,
      orderKey: 'latestUploadedChapter',
    );
    var followed = await _getMangaCard(
      title: '热门收藏',
      icon: Icons.local_fire_department,
      orderKey: 'followedCount',
    );
    return [latest, followed]
        .where((card) => card.children.isNotEmpty)
        .toList();
  }

  Future<HomepageCardEntity> _getMangaCard({
    required String title,
    required IconData icon,
    required String orderKey,
  }) async {
    var children = <GridItemEntity>[];
    try {
      var response = await RequestHandlers.mangaDexRequestHandler
          .getMangaList(limit: 12, orderKey: orderKey);
      if (response.statusCode == 200 && response.data['result'] == 'ok') {
        children = (response.data['data'] as List)
            .map<GridItemEntity>((item) => _toGridItem(item, parent))
            .toList();
      }
    } catch (e, s) {
      logger.e('$e', error: e, stackTrace: s);
    }
    return HomepageCardEntity(title, icon, null, children);
  }

  @override
  Future<List<CarouselEntity>> getHomepageCarousel() async {
    try {
      var response = await RequestHandlers.mangaDexRequestHandler
          .getMangaList(limit: 8, orderKey: 'followedCount');
      if (response.statusCode == 200 && response.data['result'] == 'ok') {
        return (response.data['data'] as List)
            .map<CarouselEntity>((item) => CarouselEntity(
                  _coverFor(item),
                  _titleFor(item),
                  (context) => _openDetail(context, item, parent),
                ))
            .toList();
      }
    } catch (e, s) {
      logger.e('$e', error: e, stackTrace: s);
    }
    return [];
  }

  @override
  Future<List<GridItemEntity>> getCategoryList() async {
    try {
      var response = await RequestHandlers.mangaDexRequestHandler.getTags();
      if (response.statusCode == 200 && response.data['result'] == 'ok') {
        return (response.data['data'] as List)
            .take(36)
            .map<GridItemEntity>((tag) {
          var title = _localizedText(tag['attributes']['name']) ?? 'Tag';
          return GridItemEntity(
            title,
            null,
            ImageEntity(ImageType.unknown, ''),
            (context) => Provider.of<NavigatorProvider>(context, listen: false)
                .getNavigator(context, NavigatorType.defaultNavigator)
                ?.push(MaterialPageRoute(
                    builder: (context) => ComicCategoryDetailPage(
                          categoryId: tag['id'],
                          sourceModel: parent,
                          categoryTitle: title,
                        ),
                    settings:
                        const RouteSettings(name: 'ComicCategoryDetailPage'))),
          );
        }).toList();
      }
    } catch (e, s) {
      logger.e('$e', error: e, stackTrace: s);
    }
    return [];
  }

  @override
  Future<List<ListItemEntity>> getRankingList({int page = 0}) async {
    return _getList(page: page, orderKey: 'followedCount');
  }

  @override
  Future<List<ListItemEntity>> getLatestList({int page = 0}) async {
    return _getList(page: page, orderKey: 'latestUploadedChapter');
  }

  Future<List<ListItemEntity>> _getList({
    required int page,
    required String orderKey,
    List<String>? tags,
  }) async {
    try {
      var response = await RequestHandlers.mangaDexRequestHandler.getMangaList(
        page: page,
        limit: 20,
        orderKey: orderKey,
        includedTags: tags,
      );
      if (response.statusCode == 200 && response.data['result'] == 'ok') {
        return (response.data['data'] as List)
            .map<ListItemEntity>((item) => _toListItem(item, parent))
            .toList();
      }
    } catch (e, s) {
      logger.e('$e', error: e, stackTrace: s);
    }
    return [];
  }

  @override
  List<FilterEntity> get categoryFilter => [TimeOrRankFilterEntity()];

  @override
  Future<List<ListItemEntity>> getCategoryDetailList(
      {required String categoryId,
      required Map<String, dynamic> categoryFilter,
      int page = 0,
      int categoryType = 0}) {
    var isRanking = categoryFilter['TimeOrRank'] == TimeOrRankEnum.ranking;
    return _getList(
      page: page,
      orderKey: isRanking ? 'followedCount' : 'latestUploadedChapter',
      tags: [categoryId],
    );
  }
}

class MangaDexComicDetailModel extends BaseComicDetailModel {
  final Map rawData;
  final Map aggregate;
  final MangaDexSourceModel sourceModel;

  MangaDexComicDetailModel(this.rawData, this.aggregate, this.sourceModel);

  @override
  ImageEntity get cover => _coverFor(rawData);

  @override
  String get title => _titleFor(rawData);

  @override
  DateTime get lastUpdate =>
      DateTime.tryParse(rawData['attributes']['updatedAt'] ?? '') ??
      DateTime.fromMillisecondsSinceEpoch(0);

  @override
  Map<String, List<BaseComicChapterEntityModel>> get chapters {
    var result = <String, List<BaseComicChapterEntityModel>>{};
    aggregate.forEach((volumeKey, volumeData) {
      var chapterMap = volumeData['chapters'] as Map? ?? {};
      var entries = chapterMap.entries.map((entry) {
        var attrs = entry.value as Map;
        return DefaultComicChapterEntityModel(
          attrs['title']?.toString().isNotEmpty == true
              ? attrs['title']
              : 'Chapter ${attrs['chapter'] ?? ''}',
          attrs['id'],
          DateTime.fromMillisecondsSinceEpoch(0),
        );
      }).toList();
      if (entries.isNotEmpty) {
        result['Volume $volumeKey'] = entries;
      }
    });
    return result;
  }

  @override
  String get description =>
      _localizedText(rawData['attributes']['description']) ?? '';

  @override
  String get status => rawData['attributes']['status'] ?? '';

  @override
  String get comicId => rawData['id'];

  @override
  List<CategoryEntity> get authors => _relationshipNames(['author', 'artist']);

  @override
  List<CategoryEntity> get categories =>
      (rawData['attributes']['tags'] as List? ?? [])
          .map<CategoryEntity>((tag) => CategoryEntity(
                _localizedText(tag['attributes']['name']) ?? 'Tag',
                tag['id'],
                null,
              ))
          .toList();

  @override
  BaseComicSourceModel get parent => sourceModel;

  @override
  Future<BaseComicChapterDetailModel?> getChapter(String chapterId) async {
    try {
      var chapterResponse =
          await RequestHandlers.mangaDexRequestHandler.getChapter(chapterId);
      var atHomeResponse = await RequestHandlers.mangaDexRequestHandler
          .getAtHomeServer(chapterId);
      if (chapterResponse.statusCode == 200 &&
          chapterResponse.data['result'] == 'ok' &&
          atHomeResponse.statusCode == 200 &&
          atHomeResponse.data['result'] == 'ok') {
        return MangaDexChapterDetailModel(
          chapterResponse.data['data'],
          atHomeResponse.data,
        );
      }
    } catch (e, s) {
      logger.e('$e', error: e, stackTrace: s);
    }
    return null;
  }

  @override
  Future<List<ComicCommentEntity>> getComments({int page = 0}) async => [];

  List<CategoryEntity> _relationshipNames(List<String> types) {
    return (rawData['relationships'] as List? ?? [])
        .where((rel) => types.contains(rel['type']))
        .map<CategoryEntity>((rel) => CategoryEntity(
            rel['attributes']?['name'] ?? rel['type'], rel['id'], null))
        .toList();
  }
}

class MangaDexChapterDetailModel extends BaseComicChapterDetailModel {
  final Map chapterData;
  final Map atHomeData;

  MangaDexChapterDetailModel(this.chapterData, this.atHomeData);

  @override
  String get title {
    var attrs = chapterData['attributes'];
    var rawTitle = attrs['title']?.toString() ?? '';
    if (rawTitle.isNotEmpty) {
      return rawTitle;
    }
    return 'Chapter ${attrs['chapter'] ?? ''}';
  }

  @override
  List<ImageEntity> get pages {
    var baseUrl = atHomeData['baseUrl'];
    var chapter = atHomeData['chapter'];
    var hash = chapter['hash'];
    return (chapter['data'] as List? ?? [])
        .map<ImageEntity>((file) =>
            ImageEntity(ImageType.network, '$baseUrl/data/$hash/$file'))
        .toList();
  }

  @override
  String get chapterId => chapterData['id'];

  @override
  Future<List<ChapterCommentEntity>> getChapterComments() async => [];
}

ComicListItemEntity _toComicListItem(Map item, MangaDexSourceModel source) {
  return ComicListItemEntity(
    _titleFor(item),
    _coverFor(item),
    _detailsFor(item),
    (context) => _openDetail(context, item, source),
    item['id'],
  );
}

GridItemEntity _toGridItem(Map item, MangaDexSourceModel source) {
  return GridItemEntity(
    _titleFor(item),
    _subtitleFor(item),
    _coverFor(item),
    (context) => _openDetail(context, item, source),
  );
}

ListItemEntity _toListItem(Map item, MangaDexSourceModel source) {
  return ListItemEntity(
    _titleFor(item),
    _coverFor(item),
    _detailsFor(item),
    (context) => _openDetail(context, item, source),
  );
}

void _openDetail(
    BuildContext context, Map item, MangaDexSourceModel sourceModel) {
  Provider.of<NavigatorProvider>(context, listen: false)
      .getNavigator(context, NavigatorType.defaultNavigator)
      ?.push(MaterialPageRoute(
          builder: (context) => ComicDetailPage(
                title: _titleFor(item),
                comicId: item['id'],
                comicSourceModel: sourceModel,
              ),
          settings: const RouteSettings(name: 'ComicDetailPage')));
}

ImageEntity _coverFor(Map item) {
  var coverFile = _coverFileName(item);
  if (coverFile == null) {
    return ImageEntity(ImageType.unknown, '');
  }
  return ImageEntity(ImageType.network,
      'https://uploads.mangadex.org/covers/${item['id']}/$coverFile.512.jpg');
}

String? _coverFileName(Map item) {
  for (var rel in item['relationships'] as List? ?? []) {
    if (rel['type'] == 'cover_art') {
      return rel['attributes']?['fileName'];
    }
  }
  return null;
}

String _titleFor(Map item) {
  var attrs = item['attributes'];
  return _localizedText(attrs['title']) ??
      _firstString((attrs['altTitles'] as List? ?? [])
          .map((title) => _localizedText(title))
          .whereType<String>()) ??
      'Untitled';
}

String? _subtitleFor(Map item) {
  var tags = (item['attributes']['tags'] as List? ?? [])
      .map((tag) => _localizedText(tag['attributes']['name']))
      .whereType<String>()
      .take(3)
      .join('/');
  return tags.isEmpty ? null : tags;
}

Map<IconData, String> _detailsFor(Map item) {
  var attrs = item['attributes'];
  return {
    Icons.language: (attrs['originalLanguage'] ?? '').toString(),
    Icons.apps: _subtitleFor(item) ?? '',
    Icons.history_edu: _formatDate(attrs['updatedAt']),
  };
}

String _formatDate(String? value) {
  var parsed = DateTime.tryParse(value ?? '');
  if (parsed == null) {
    return '';
  }
  return date_format.formatDate(
      parsed, [date_format.yyyy, '-', date_format.mm, '-', date_format.dd]);
}

String? _localizedText(Map? values) {
  if (values == null || values.isEmpty) {
    return null;
  }
  for (var key in ['zh', 'zh-hk', 'en', 'ja-ro', 'ja']) {
    var value = values[key];
    if (value is String && value.isNotEmpty) {
      return value;
    }
  }
  return _firstString(values.values.whereType<String>());
}

String? _firstString(Iterable<String> values) {
  for (var value in values) {
    if (value.isNotEmpty) {
      return value;
    }
  }
  return null;
}
