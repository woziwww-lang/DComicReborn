import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:dcomic/generated/l10n.dart';
import 'package:dcomic/providers/models/comic_source_model.dart';
import 'package:dcomic/providers/page_controllers/comic_homepage_controller.dart';
import 'package:dcomic/view/components/carousel_item.dart';
import 'package:dcomic/view/components/grid_card.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ComicHomepageController(),
      builder: (context, child) => EasyRefresh(
          onRefresh: () async {
            await Provider.of<ComicHomepageController>(context, listen: false)
                .refresh(context);
          },
          refreshOnStart: true,
          child: Container(
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: ListView(
              shrinkWrap: true,
              children: _buildListView(context),
            ),
          )),
    );
  }

  Widget _buildCarousels(BuildContext context) {
    return HomepageCarousel(
      carousels:
          Provider.of<ComicHomepageController>(context).homepageCarousels,
    );
  }

  List<Widget> _buildListView(BuildContext context) {
    var controller = Provider.of<ComicHomepageController>(context);
    if (controller.errorMessage != null &&
        controller.homepageCards.isEmpty &&
        controller.homepageCarousels.isEmpty) {
      return [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                controller.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).disabledColor),
              ),
            ),
          ),
        ),
      ];
    }

    List<Widget> data = [_buildCarousels(context)];
    if (controller.homepageCards.isEmpty) {
      for (int i = 0; i < 5; i++) {
        data.add(const GridCardPlaceHolder());
      }
    }
    for (var entity in controller.homepageCards) {
      List<Widget> gridCards = [];
      for (var cards in entity.children) {
        gridCards.add(GridCardItem(
          image: cards.cover,
          onTap: cards.onTap == null
              ? null
              : () {
                  cards.onTap!(context);
                },
          title: cards.title,
          subtitle: cards.subtitle,
        ));
      }
      data.add(GridCard(
        entity.title,
        sideIcon: entity.icon,
        crossAxisCount: gridCards.length % 3 == 0 ? 3 : 2,
        onSideIconPressed: entity.onTap == null
            ? null
            : () {
                entity.onTap!(context);
              },
        children: gridCards,
      ));
    }
    return data;
  }
}

class HomepageCarousel extends StatelessWidget {
  final List<CarouselEntity> carousels;

  const HomepageCarousel({super.key, required this.carousels});

  @override
  Widget build(BuildContext context) {
    if (carousels.isEmpty) {
      return AspectRatio(
        aspectRatio: 2,
        child: Card(
          elevation: 0,
          child: Center(
            child: Text(
              S.of(context).Loading,
              style: TextStyle(color: Theme.of(context).disabledColor),
            ),
          ),
        ),
      );
    }

    return CarouselSlider.builder(
      options: CarouselOptions(
        viewportFraction: 0.95,
        enableInfiniteScroll: true,
        autoPlay: true,
        aspectRatio: 2,
        enlargeCenterPage: true,
        enlargeStrategy: CenterPageEnlargeStrategy.height,
      ),
      itemCount: carousels.length,
      itemBuilder: (context, index, realIndex) {
        var entity = carousels[index];
        return CarouselItem(
          title: entity.title,
          cover: entity.cover,
          onTap: entity.onTap,
        );
      },
    );
  }
}
