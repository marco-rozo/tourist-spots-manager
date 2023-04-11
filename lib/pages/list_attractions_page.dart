import 'package:attractions_app/dao/attraction_dao.dart';
import 'package:attractions_app/model/attraction_model.dart';
import 'package:attractions_app/widgets/content_dialog.dart';
import 'package:attractions_app/widgets/content_form_dialog.dart';
import 'package:attractions_app/widgets/custom_bottom_modal.dart';
import 'package:attractions_app/widgets/custom_list_tile.dart';
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
  bool _isLoading = false;

  final List<AttractionModel> allAttractionsList = [];
  // final List<AttractionModel> allAttractionsList =
  //     List<AttractionModel>.generate(
  //   5,
  //   (int index) => AttractionModel(
  //     id: index + 1,
  //     title: 'title$index',
  //     description: 'description',
  //     differential: 'differential',
  //     date: DateTime.now(),
  //   ),
  // );

  List<AttractionModel> foundAttractionsList = [];
  final _inputController = TextEditingController();
  final _dao = AttractionDao();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _updateList();

    setState(() {
      _inputController.text = '';
    });
  }

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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        tooltip: "New attraction",
        child: const Icon(Icons.add),
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Column(
            children: [
              TextField(
                autofocus: false,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  suffixIcon: _inputController.text != ''
                      ? IconButton(
                          onPressed: () => {
                            _inputController.text = '',
                            _filterList(_inputController.text)
                          },
                          icon: Icon(Icons.close),
                        )
                      : Icon(Icons.search),

                  // icon: Icon(Icons.person),
                  hintText: 'Pesquisar',
                ),
                controller: _inputController,
                onChanged: (value) => {
                  _filterList(value),
                },
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: _isLoading
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Align(
                            alignment: AlignmentDirectional.center,
                            child: CircularProgressIndicator(),
                          ),
                          Align(
                            alignment: AlignmentDirectional.center,
                            child: Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: Text(
                                'Loading list...',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          )
                        ],
                      )
                    : foundAttractionsList.isEmpty
                        ? const Center(
                            child: Text('No tourist attractions registered :('))
                        : ListView.separated(
                            key: UniqueKey(),
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    const Divider(),
                            itemCount: foundAttractionsList.length,
                            itemBuilder: (context, index) {
                              final attraction = foundAttractionsList[index];
                              return Dismissible(
                                background: slideRightBackground(),
                                secondaryBackground: slideLeftBackground(),
                                key: UniqueKey(),
                                onDismissed: (DismissDirection direction) {
                                  if (direction ==
                                      DismissDirection.endToStart) {
                                    _delete(attraction, index);
                                    // setState(() {
                                    // allAttractionsList.removeAt(index);
                                    // allAttractionsList.remove(attraction);
                                    // foundAttractionsList = allAttractionsList;
                                    // });
                                  } else {
                                    _openForm(
                                      currentAttraction: attraction,
                                      currentIndex: index,
                                    );
                                  }
                                },
                                child: InkWell(
                                  onTap: () => showBottomFilter(attraction),
                                  child: CustomListTile(
                                    title: attraction.title,
                                    date: attraction.dateFormatted,
                                    subtitle: attraction.description,
                                  ),
                                ),
                              );
                            },
                          ),
              )
            ],
          )),
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
              onPressed: () {
                Navigator.of(context).pop();
                if (currentIndex != null) {
                  setState(() {
                    allAttractionsList[currentIndex] = currentAttraction!;
                  });
                }
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (key.currentState != null &&
                    key.currentState!.validatedData()) {
                  Navigator.of(context).pop();
                  final newAttraction = key.currentState!.newAttraction;
                  _dao.salvar(newAttraction).then((success) {
                    if (success) {
                      _updateList();
                    }
                  });
                  _updateList();
                  // setState(() {
                  //   if (currentIndex == null) {
                  //     newAttraction.id = (allAttractionsList.length + 1);
                  //     allAttractionsList.add(newAttraction);
                  //   } else {
                  //     allAttractionsList[currentIndex] = newAttraction;
                  //   }
                  //   foundAttractionsList = allAttractionsList;
                  // });
                }
              },
              child: Text('Save'),
            )
          ],
        );
      },
    );
  }

  void _updateList() async {
    setState(() {
      _isLoading = false;
    });
    final attractions = await _dao.listar(
      filter: '',
      fieldOrder: AttractionModel.FIELD_ID,
      isDescOrder: false,
    );
    setState(() {
      allAttractionsList.clear();
      foundAttractionsList.clear();
      if (attractions.isNotEmpty) {
        allAttractionsList.addAll(attractions);
        foundAttractionsList.addAll(attractions);
      }

      _isLoading = false;
    });
  }

  Future<void> showBottomFilter(AttractionModel attraction) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      isScrollControlled: true,
      barrierColor: Colors.white.withOpacity(0.01),
      builder: (BuildContext context) {
        return CustomBottomModal(
          attraction: attraction,
        );
      },
    );
  }

  void _delete(AttractionModel attraction, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: const [
              Icon(
                Icons.warning,
                color: Colors.red,
              ),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text('Caution!'),
              ),
            ],
          ),
          content: Text('This record will be permanently deleted'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  allAttractionsList[index] = attraction;
                });
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (attraction.id == null) {
                  return;
                }
                _dao.remover(attraction.id!).then((success) {
                  if (success) _updateList();
                });

                // setState(() {
                //   allAttractionsList.remove(attraction);
                //   // allAttractionsList.removeAt(index);
                //   foundAttractionsList = allAttractionsList;
                // });
              },
              child: Text('Confirm'),
            )
          ],
        );
      },
    );
  }

  void _orderListById() {
    setState(() {
      if (_orderByIDAsc) {
        allAttractionsList.sort((a, b) => b.id!.compareTo(a.id!));
      } else {
        allAttractionsList.sort((a, b) => a.id!.compareTo(b.id!));
      }
      _orderByIDAsc = !_orderByIDAsc;
      foundAttractionsList = allAttractionsList;
    });
  }

  void _orderListByName() {
    setState(() {
      if (_orderByNameAsc) {
        allAttractionsList.sort((a, b) => b.title.compareTo(a.title));
      } else {
        allAttractionsList.sort((a, b) => a.title.compareTo(b.title));
      }
      _orderByNameAsc = !_orderByNameAsc;
      foundAttractionsList = allAttractionsList;
    });
  }

  void _orderListByDate() {
    setState(() {
      if (_orderByDateAsc) {
        allAttractionsList.sort(
          (a, b) => DateTime.parse(b.date.toString()).compareTo(
            DateTime.parse(a.date.toString()),
          ),
        );
      } else {
        allAttractionsList.sort(
          (a, b) => DateTime.parse(a.date.toString()).compareTo(
            DateTime.parse(b.date.toString()),
          ),
        );
      }
      _orderByDateAsc = !_orderByDateAsc;
      foundAttractionsList = allAttractionsList;
    });
  }

  void _filterList(String value) {
    List<AttractionModel> newList = [];

    newList = allAttractionsList.where((o) {
      if (o.title.contains(value)) {
        return true;
      }

      if (o.description.contains(value)) {
        return true;
      }

      if (o.differential != null && o.differential!.contains(value)) {
        return true;
      }

      if (o.id.toString() == value) {
        return true;
      }

      return false;
    }).toList();

    setState(() {
      foundAttractionsList = newList;
    });
  }
}
