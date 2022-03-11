import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_zaynidddin/model/task.dart';
import 'package:todo_zaynidddin/services/db_helper.dart';
import 'package:todo_zaynidddin/services/db_helper.dart';

class AddTask extends StatefulWidget {
  final Function? updateTaskList;
  final Task? task;

  const AddTask({this.updateTaskList, this.task});

  static const String id = "add_task";

  @override
  _AddTaskState createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  final _formKey = GlobalKey<FormState>();

  String? _title = "";
  String _priority = "Low";
  DateTime _date = DateTime.now();
  TextEditingController _dateController = TextEditingController();
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  final List<String> _priorities = ["Low", "Medium", "High"];

  _handleDataPicker() async {
    final date = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: DateTime(2020),
        lastDate: DateTime(2050));

    if (date != _date) {
      setState(() {
        _date = date as DateTime;
      });
      _dateController.text = _dateFormat.format(date!);
    }
  }

  _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Task task = new Task(title: _title, date: _date, priority: _priority);


      if(widget.task == null){
        //insert
        task.status = 0;
        DBHelper().insertTask(task);
      } else{
        //update
        task.id = widget.task!.id;
        task.status = widget.task!.status;
        task.title = _title;
        task.date =  _date;
        task.priority = _priority;
        DBHelper().updateTask(task);

      }

      if (widget.updateTaskList != null) widget.updateTaskList!();
      Navigator.pop(context);
    }
  }

  _delete(){
    DBHelper().deleteTask(widget.task!.id);
    widget.updateTaskList!();
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    if(widget.task != null){
      _title = widget.task!.title;
      _date = widget.task!.date;
      _priority = widget.task!.priority as String;
    }

    _dateController.text = _dateFormat.format(_date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Add Task"),
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              child: Column(
                children: [
                  Text(
                    widget.task == null ? 'Create Task' : "Update task",
                    style:
                        TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                  Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            decoration: InputDecoration(labelText: "Title"),
                            onSaved: (input) => _title = input,
                            validator: (input) => input!.trim().isEmpty
                                ? 'Please enter task title'
                                : null,
                            initialValue: _title,
                          ),
                          TextFormField(
                            readOnly: true,
                            controller: _dateController,
                            onTap: _handleDataPicker,
                            decoration: InputDecoration(labelText: "Date"),
                          ),
                          DropdownButtonFormField(
                            icon: Icon(Icons.arrow_drop_down),
                            decoration: InputDecoration(labelText: "Preority"),
                            items: _priorities.map((prop) {
                              return DropdownMenuItem<String>(
                                value: prop,
                                child: Text(
                                  prop,
                                  style: TextStyle(color: Colors.black),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              setState(() {
                                _priority = value! as String;
                              });
                            },
                            value: _priority,
                            validator: (input) => _priority == null
                                ? "Please, select priority level"
                                : null,
                          )
                        ],
                      )),
                  TextButton(
                    onPressed: _submit,
                    child: Text("Save"),
                  ),
                  TextButton(
                    onPressed: _delete,
                    child: Text("Delete"),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
