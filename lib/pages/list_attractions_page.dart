import 'package:attractions_app/model/AttractionModel.dart';
import 'package:attractions_app/widgets/content_dialog.dart';
import 'package:attractions_app/widgets/content_form_dialog.dart';
import 'package:flutter/material.dart';

class ListAttractionsPage extends StatefulWidget {
  const ListAttractionsPage({Key? key}) : super(key: key);

  @override
  State<ListAttractionsPage> createState() => _ListAttractionsPageState();
}

class _ListAttractionsPageState extends State<ListAttractionsPage> {
  final List<AttractionModel> attractionsList = [];

  final List<AttractionModel> attractionsListGenerate =
      List<AttractionModel>.generate(
    5,
    (int index) => AttractionModel(
      id: index + 1,
      title: 'title',
      description: 'description',
      differential: 'differential',
      date: DateTime.now(),
    ),
  );

  int _lastId = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attractions'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        tooltip: "New task",
        child: const Icon(Icons.add),
      ),
      body: attractionsList.isEmpty
          ? const Center(child: Text('No tourist attractions registered :('))
          : Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              child: ListView.separated(
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(),
                itemCount: attractionsList.length,
                itemBuilder: (context, index) {
                  final attraction = attractionsList[index];
                  return Dismissible(
                    background: slideRightBackground(),
                    secondaryBackground: slideLeftBackground(),
                    key: ValueKey<AttractionModel>(attractionsList[index]),
                    onDismissed: (DismissDirection direction) {
                      print(direction == DismissDirection.startToEnd);
                      if (direction == DismissDirection.endToStart) {
                        setState(() {
                          attractionsList.removeAt(index);
                        });
                      } else {
                        _openForm(
                          currentAttraction: attraction,
                          currentIndex: index,
                        );
                      }
                    },
                    child: InkWell(
                      onTap: () => _showContent(attraction),
                      child: ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("${attraction.id} - ${attraction.title}"),
                            Text(
                              "${attraction.dateFormatted}",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text("${attraction.description}"),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  void _showContent(AttractionModel currentAttraction) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Attraction ${currentAttraction.id}'),
          content: ContentDialog(currentAttraction: currentAttraction),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Ok'),
            )
          ],
        );
      },
    );
  }

  void _openForm({AttractionModel? currentAttraction, int? currentIndex}) {
    final key = GlobalKey<ContentFormDialogState>();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            currentAttraction == null
                ? 'New Attraction'
                : ' Change the Attraction ${currentAttraction.id}',
          ),
          content:
              ContentFormDialog(key: key, currentAttraction: currentAttraction),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (key.currentState != null &&
                    key.currentState!.validatedData()) {
                  setState(() {
                    final newAttraction = key.currentState!.newAttraction;
                    if (currentIndex == null) {
                      newAttraction.id = (attractionsList.length + 1);
                      attractionsList.add(newAttraction);
                    } else {
                      attractionsList[currentIndex] = newAttraction;
                    }
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text('Save'),
            )
          ],
        );
      },
    );
  }

  Widget slideRightBackground() {
    return Container(
      color: Colors.green,
      child: Align(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 20,
            ),
            Icon(
              Icons.edit,
              color: Colors.white,
            ),
            Text(
              " Edit",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.left,
            ),
          ],
        ),
        alignment: Alignment.centerLeft,
      ),
    );
  }

  Widget slideLeftBackground() {
    return Container(
      color: Colors.red,
      child: Align(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Icon(
              Icons.delete,
              color: Colors.white,
            ),
            Text(
              " Delete",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.right,
            ),
            SizedBox(
              width: 20,
            ),
          ],
        ),
        alignment: Alignment.centerRight,
      ),
    );
  }
}
