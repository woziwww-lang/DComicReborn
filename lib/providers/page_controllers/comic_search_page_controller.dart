import 'package:dcomic/providers/base_provider.dart';
import 'package:dcomic/providers/models/comic_source_model.dart';

class ComicSearchPageData extends Object {
  List<ListItemEntity> data = [];
  int page = 0;
  bool isLoading = false;
  String? errorMessage;
}

class ComicSearchPageController extends BaseProvider {
  String _pendingKeyword = "";
  String keyword = "";
  List<BaseComicSourceModel> sourceModels;
  Map<BaseComicSourceModel, ComicSearchPageData> data = {};

  ComicSearchPageController(this.sourceModels) {
    for (var sourceModel in sourceModels) {
      data[sourceModel] = ComicSearchPageData();
    }
  }

  Future<void> refreshAll() async {
    for (var source in sourceModels) {
      await refresh(source);
    }
  }

  Future<void> refresh(BaseComicSourceModel sourceModel) async {
    var sourceData = data[sourceModel];
    if (sourceData == null) {
      return;
    }
    sourceData.page = 0;
    sourceData.errorMessage = null;
    if (keyword.isNotEmpty) {
      sourceData.isLoading = true;
      notifyListeners();
      try {
        sourceData.data = await sourceModel.searchComicDetail(keyword);
      } catch (e, s) {
        logger.e('$e', error: e, stackTrace: s);
        sourceData.data = [];
        sourceData.errorMessage = '搜索失败';
      } finally {
        sourceData.isLoading = false;
      }
    }
    notifyListeners();
  }

  Future<void> load(BaseComicSourceModel sourceModel) async {
    data[sourceModel]?.page++;
    if (keyword.isNotEmpty) {
      try {
        data[sourceModel]?.data += await sourceModel.searchComicDetail(keyword,
            page: data[sourceModel]!.page);
      } catch (e, s) {
        logger.e('$e', error: e, stackTrace: s);
      }
    }
    notifyListeners();
  }

  set pendingKeyword(String value) {
    _pendingKeyword = value;
  }

  Future<void> search() async {
    keyword = _pendingKeyword;
    await refreshAll();
    notifyListeners();
  }
}
