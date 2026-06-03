import 'package:dcomic/utils/image_utils.dart';
import 'package:dcomic/view/components/dcomic_image.dart';
import 'package:flutter/material.dart';

class CardListItem extends StatelessWidget {
  final String title;
  final Map<IconData, String> details;
  final void Function(BuildContext context)? onTap;
  final ImageEntity cover;

  const CardListItem(
      {super.key,
      required this.title,
      required this.details,
      this.onTap,
      required this.cover});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap == null
              ? null
              : () {
                  onTap!(context);
                },
          child: SizedBox(
            height: 118,
            child: Row(
              children: [
                SizedBox(
                  width: 86,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: DComicImage(
                        cover,
                        fit: BoxFit.cover,
                        showErrorMessage: false,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 10, 10, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _buildDetails(context),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDetails(BuildContext context) {
    List<Widget> data = [
      Expanded(
          flex: 3,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          )),
      const SizedBox(height: 4),
    ];
    for (var tuple in details.entries) {
      if (tuple.value.isEmpty) {
        continue;
      }
      data.add(Expanded(
          flex: 2,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 5),
                child: Icon(
                  tuple.key,
                  size: 16,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              Expanded(
                  child: Text(tuple.value,
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis))
            ],
          )));
    }
    return data;
  }
}
