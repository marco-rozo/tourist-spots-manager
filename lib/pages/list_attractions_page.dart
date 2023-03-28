import 'package:attractions_app/model/AttractionModel.dart';
import 'package:attractions_app/widgets/content_dialog.dart';
import 'package:attractions_app/widgets/content_form_dialog.dart';
import 'package:attractions_app/widgets/slide_left_background.dart';
import 'package:attractions_app/widgets/slide_right_background.dart';
import 'package:flutter/material.dart';

class ListAttractionsPage extends StatefulWidget {
  const ListAttractionsPage({Key? key}) : super(key: key);

  @override
  State<ListAttractionsPage> createState() => _ListAttractionsPageState();
}

class _ListAttractionsPageState extends State<ListAttractionsPage> {
  static const ORDER_BY_ID = 'ORDER_BY_ID';
  static const ORDER_BY_NAME = 'ORDER_BY_NAME';
  static const ORDER_BY_DATE = 'ORDER_BY_DATE';

  bool _orderByIDAsc = true;
  bool _orderByNameAsc = false;
  bool _orderByDateAsc = false;

  // final List<AttractionModel> attractionsList = [];

  final List<AttractionModel> attractionsList = List<AttractionModel>.generate(
    5,
    (int index) => AttractionModel(
      id: index + 1,
      title: 'title$index',
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
        actions: [
          PopupMenuButton<String>(
            child: const Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.filter_list_rounded),
            ),
            itemBuilder: (BuildContext context) => _filterItensPopMenu(),
            onSelected: (String selectedValue) {
              if (selectedValue == ORDER_BY_ID) {
                _orderListById();
              } else if (selectedValue == ORDER_BY_NAME) {
                _orderListByName();
              } else {
                _orderListByDate();
              }
            },
          )
        ],
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

  List<PopupMenuEntry<String>> _filterItensPopMenu() {
    return [
      PopupMenuItem<String>(
        value: ORDER_BY_ID,
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                !_orderByIDAsc ? 'Order by ID ASC' : 'Order by ID DESC',
              ),
            )
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: ORDER_BY_NAME,
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                !_orderByNameAsc ? 'Order by NAME ASC' : 'Order by NAME DESC',
              ),
            )
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: ORDER_BY_DATE,
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                !_orderByDateAsc ? 'Order by DATE ASC' : 'Order by DATE DESC',
              ),
            )
          ],
        ),
      ),
    ];
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

  void _orderListById() {
    setState(() {
      if (_orderByIDAsc) {
        attractionsList.sort((a, b) => b.id.compareTo(a.id));
      } else {
        attractionsList.sort((a, b) => a.id.compareTo(b.id));
      }
      _orderByIDAsc = !_orderByIDAsc;
    });
  }

  void _orderListByName() {
    setState(() {
      if (_orderByNameAsc) {
        attractionsList.sort((a, b) => b.title.compareTo(a.title));
      } else {
        attractionsList.sort((a, b) => a.title.compareTo(b.title));
      }
      _orderByNameAsc = !_orderByNameAsc;
    });
  }

  void _orderListByDate() {
    setState(() {
      if (_orderByDateAsc) {
        attractionsList.sort(
          (a, b) => DateTime.parse(b.date.toString()).compareTo(
            DateTime.parse(a.date.toString()),
          ),
        );
      } else {
        attractionsList.sort(
          (a, b) => DateTime.parse(a.date.toString()).compareTo(
            DateTime.parse(b.date.toString()),
          ),
        );
      }
      _orderByDateAsc = !_orderByDateAsc;
    });
  }
}
