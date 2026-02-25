import 'dart:convert';
import 'dart:math';

import 'package:dcomic/database/database_instance.dart';
import 'package:dcomic/requests/base_request.dart';
import 'package:dio/dio.dart';


class CopyMangaRequestHandler extends RequestHandler {
  CopyMangaRequestHandler()
      : super('https://mapi.hotmangasd.com/', useCookie: false);

  Future<Options> setHeader({Map<String, dynamic>? headers, bool login=true}) async {
    headers ??= {};
    var databaseInstance = await DatabaseInstance.instance;
    var isLoginEntity = await databaseInstance.modelConfigDao
        .getConfigByKeyAndModel('isLogin', 'copymanga');
    if (isLoginEntity != null && isLoginEntity.get<bool>() && login) {
      String token = (await (await DatabaseInstance.instance)
                  .modelConfigDao
                  .getConfigByKeyAndModel('token', 'copymanga'))
              ?.value ??
          '';
      headers['authorization'] = 'Token $token';
    }
    headers['user-agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36';
    headers['accept'] = 'application/json';
    headers['accept-language'] = 'en-US,en;q=0.9,zh-CN;q=0.8,zh;q=0.7';
    headers['origin'] = 'https://m.relamanhua.org';
    headers['version'] = '2025.11.21';
    headers['webp'] = '1';
    headers['platform'] = '1';
    headers['host'] = 'mapi.hotmangasd.com';
    return Options(headers: headers);
  }

  Future<Response> getComicDetail(String comicId) async{
    return dio.get('/api/v3/comic2/$comicId',
        options: await setHeader());
  }

  Future<Response> getChapters(String comicId, String groupName,
      {int limit = 100, int page = 0}) async {
    return dio.get(
        '/api/v3/comic/$comicId/group/$groupName/chapters?limit=$limit&offset=$page',
        options: await setHeader());
  }

  Future<Response> getComic(String comicId, String chapterId) async {
    return dio.get(
        '/api/v3/comic/$comicId/chapter/$chapterId?format=json',
        options: await setHeader());
  }

  Future<Response> search(String keyword,
      {int page = 0, int limit = 18}) async {
    return dio.get(
        '/api/v3/search/comic?limit=$limit&offset=${page * limit}&q_type=&q=$keyword&platform=2',
        options: await setHeader());
  }

  Future<Response> login(String username, String password) async {
    int salt = Random().nextInt(9000) + 1000;
    var data = FormData.fromMap({
      'username': username,
      'password': base64Encode(utf8.encode('$password-$salt')),
      'salt': salt,
      'source': 'freeSite',
      'version': '2021.04.01',
      'platform': 1
    });
    return dio.post('/api/v3/login', data: data, options: await setHeader());
  }

  Future<Response> logout() async {
    return dio.post('/api/v3/logout', options: await setHeader());
  }

  Future<Response> getSubscribe({int page = 0, int limit = 21}) async {
    return dio.get(
        '/api/v3/member/collect/comics?free_type=1&limit=$limit&offset=${page * limit}&_update=true&ordering=-datetime_updated',
        options: await setHeader());
  }

  Future<Response> getCategoryDetailList(
      {required String theme,
      int page = 0,
      int limit = 21,
      String order = '-datetime_modifier'}) async {
    return dio.get(
        '/api/v3/comics?free_type=1&theme=$theme&limit=$limit&offset=${page * limit}&_update=true&ordering=$order',
        options: await setHeader());
  }

  Future<Response> getAuthorDetailList(
      {required String author,
      int page = 0,
      int limit = 21,
      String order = '-datetime_modifier'}) async {
    return dio.get(
        '/api/v3/comics?free_type=1&author=$author&limit=$limit&offset=${page * limit}&ordering=$order',
        options: await setHeader());
  }

  Future<Response> getRankList(
      {String dateType = 'day', int limit = 21, int page = 0}) async{
    return dio.get(
        '/api/v3/ranks?type=1&date_type=$dateType&limit=$limit&offset=${limit * page}',
        options: await setHeader());
  }

  Future<Response> getLatestList({int limit = 21, int page = 0}) async{
    return dio.get('/api/v3/update/newest?limit=$limit&offset=${limit * page}',
        options: await setHeader());
  }

  Future<Response> getUserInfo() async {
    return dio.get('/api/v3/member/info', options: await setHeader());
  }

  Future<Response> getIfSubscribe(String comicId) async {
    return dio.get('/api/v3/comic2/query/$comicId?platform=1',
        options: await setHeader());
  }

  Future<Response> addSubscribe(String comicId, bool subscribe) async {
    var data = FormData.fromMap(
        {'comic_id': comicId, 'is_collect': subscribe ? 1 : 0});
    return dio.post('/api/v3/member/collect/comic',
        data: data, options: await setHeader());
  }

  Future<Response> getHomepage() async{
    return dio.get('/api/v3/h5/homeIndex', options: await setHeader());
  }

  Future<Response> getTagList(
      {bool popular = true,
      int page = 0,
      int limit = 21,
      String? categoryId,
      String? authorId}) async{
    return dio.get(
        '/api/v3/comics?free_type=1&limit=$limit&offset=$page${categoryId == null ? '' : '&theme=$categoryId'}${authorId == null ? '' : '&author=$authorId'}&ordering=${popular ? '-popular' : '-datetime_updated'}&_update=true',
        options: await setHeader());
  }

  Future<Response> getSubjectList({int page = 0, int limit = 20}) async{
    return dio
        .get('/api/v3/topics?type=1&limit=$limit&offset=$page&_update=true', options: await setHeader());
  }

  Future<Response> getSubjectDetail(String subjectId) async{
    return dio.get('/api/v3/topic/$subjectId?limit=&offset=', options: await setHeader());
  }

  Future<Response> getSubjectDetailContent(String subjectId,
      {int page = 0, limit = 30}) async{
    return dio.get(
        '/api/v3/topic/$subjectId/contents?limit=$limit&offset=${page * limit}', options: await setHeader());
  }

  Future<Response> getCategory() async{
    return dio.get(
        '/api/v3/theme/comic/count?free_type=1&limit=500&offset=0&_update=true', options: await setHeader());
  }

  Future<Response> getChapterComments(String chapterId,
      {int limit = 50, int page = 0}) async{
    return dio.get(
        '/api/v3/roasts?chapter_id=$chapterId&limit=$limit&offset=${page * limit}',
        options: await setHeader());
  }

  Future<Response> getComments(String comicId,
      {int limit = 20, int page = 0}) async {
    return dio.get(
        '/api/v3/comments?comic_id=$comicId&limit=$limit&offset=${limit * page}',
        options: await setHeader());
  }

  Future<Response> getHistory({int limit = 12, int page = 0}) async {
    return dio.get('/api/v3/member/browse/comics?limit=$limit&offset=${limit * page}&platform=1',
        options: await setHeader());
  }
}
