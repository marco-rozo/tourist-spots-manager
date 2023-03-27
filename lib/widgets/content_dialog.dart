import 'package:attractions_app/model/AttractionModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class ContentDialog extends StatelessWidget {
  final AttractionModel currentAttraction;

  const ContentDialog({
    super.key,
    required this.currentAttraction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.35,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${currentAttraction.title}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${currentAttraction.dateFormatted}',
                  style: TextStyle(
                      fontWeight: FontWeight.w300, color: Colors.grey),
                ),
              ],
            ),
            Divider(),
            Text('Description: ${currentAttraction.description}'),
            Text('Differentials: ${currentAttraction.differential}'),
          ],
        ),
      ),
    );
  }
}
