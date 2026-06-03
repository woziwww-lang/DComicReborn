import 'package:dcomic/requests/base_request.dart';
import 'package:dio/dio.dart';

class MangaDexRequestHandler extends RequestHandler {
  MangaDexRequestHandler()
      : super('https://api.mangadex.org', useCookie: false);

  static const List<String> contentLanguages = ['zh', 'zh-hk', 'en'];

  Future<Response> search(String keyword, {int page = 0, int limit = 20}) {
    return dio.get('/manga', queryParameters: {
      'title': keyword,
      'limit': limit,
      'offset': page * limit,
      'includes[]': ['cover_art', 'author', 'artist'],
      'availableTranslatedLanguage[]': contentLanguages,
      'contentRating[]': ['safe', 'suggestive'],
      'order[relevance]': 'desc',
    });
  }

  Future<Response> getMangaList({
    int page = 0,
    int limit = 20,
    String orderKey = 'latestUploadedChapter',
    String orderValue = 'desc',
    List<String>? includedTags,
  }) {
    return dio.get('/manga', queryParameters: {
      'limit': limit,
      'offset': page * limit,
      'includes[]': ['cover_art', 'author', 'artist'],
      'availableTranslatedLanguage[]': contentLanguages,
      'contentRating[]': ['safe', 'suggestive'],
      if (includedTags != null && includedTags.isNotEmpty)
        'includedTags[]': includedTags,
      'order[$orderKey]': orderValue,
    });
  }

  Future<Response> getMangaDetail(String mangaId) {
    return dio.get('/manga/$mangaId', queryParameters: {
      'includes[]': ['cover_art', 'author', 'artist'],
    });
  }

  Future<Response> getMangaAggregate(String mangaId) {
    return dio.get('/manga/$mangaId/aggregate', queryParameters: {
      'translatedLanguage[]': contentLanguages,
    });
  }

  Future<Response> getChapter(String chapterId) {
    return dio.get('/chapter/$chapterId');
  }

  Future<Response> getAtHomeServer(String chapterId) {
    return dio.get('/at-home/server/$chapterId');
  }

  Future<Response> getTags() {
    return dio.get('/manga/tag');
  }
}
