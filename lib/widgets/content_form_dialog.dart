import 'package:attractions_app/model/AttractionModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:intl/intl.dart';

class ContentFormDialog extends StatefulWidget {
  final AttractionModel? currentAttraction;

  ContentFormDialog({Key? key, this.currentAttraction}) : super(key: key);

  @override
  ContentFormDialogState createState() => ContentFormDialogState();
}

class ContentFormDialogState extends State<ContentFormDialog> {
  final formKey = GlobalKey<FormState>();
  final descriptionTEController = TextEditingController();
  final titleTEController = TextEditingController();
  final differentialTEController = TextEditingController();
  final dateTEControler = TextEditingController();
  final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    dateTEControler.text = _dateFormat.format(DateTime.now());

    if (widget.currentAttraction != null) {
      descriptionTEController.text = widget.currentAttraction!.description;
      titleTEController.text = widget.currentAttraction!.title;
      differentialTEController.text =
          widget.currentAttraction!.differential ?? '';
      dateTEControler.text = widget.currentAttraction!.dateFormatted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: titleTEController,
            decoration: InputDecoration(labelText: 'Title'),
            validator: (String? valor) {
              if (valor == null || valor.isEmpty) {
                return 'Enter the title';
              }
              return null;
            },
          ),
          TextFormField(
            controller: descriptionTEController,
            decoration: InputDecoration(labelText: 'Description'),
            validator: (String? valor) {
              if (valor == null || valor.isEmpty) {
                return 'Enter the description';
              }
              return null;
            },
          ),
          TextFormField(
            controller: differentialTEController,
            decoration: InputDecoration(labelText: 'Differential'),
          ),
          TextFormField(
            controller: dateTEControler,
            decoration: InputDecoration(
              labelText: 'Date',
              prefixIcon: IconButton(
                onPressed: _showCalendario,
                icon: const Icon(Icons.calendar_today),
              ),
              suffixIcon: IconButton(
                onPressed: () => dateTEControler.clear(),
                icon: const Icon(Icons.close),
              ),
            ),
            readOnly: true,
          )
        ],
      ),
    );
  }

  void _showCalendario() {
    final dataFormatted = dateTEControler.text;

    var data = DateTime.now();
    if (dataFormatted.isNotEmpty) {
      data = _dateFormat.parse(dataFormatted);
    }
    showDatePicker(
      context: context,
      initialDate: data,
      firstDate: data.subtract(Duration(days: 365 * 5)),
      lastDate: data.add(Duration(days: 365 * 5)),
    ).then((DateTime? dataSelected) {
      if (dataSelected != null) {
        setState(() {
          dateTEControler.text = _dateFormat.format(dataSelected);
        });
      }
    });
  }

  bool validatedData() => formKey.currentState!.validate() == true;

  AttractionModel get newAttraction => AttractionModel(
        id: widget.currentAttraction?.id ?? 0,
        title: titleTEController.text,
        description: descriptionTEController.text,
        differential: differentialTEController.text,
        date: dateTEControler.text.isEmpty
            ? DateTime.now()
            : _dateFormat.parse(dateTEControler.text),
      );
}
