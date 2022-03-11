import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_zaynidddin/model/task.dart';
import 'package:todo_zaynidddin/pages/add_task.dart';
import 'package:todo_zaynidddin/services/db_helper.dart';

class TskListScreen extends StatefulWidget {
  const TskListScreen();

  static const String id = "task_list_screen";

  @override
  _TskListScreenState createState() => _TskListScreenState();
}

class _TskListScreenState extends State<TskListScreen> {
  late Future<List<Task>> _taskList;
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');

  @override
  void initState() {
    super.initState();
    _updateTaskList();
  }

  void _updateTaskList() {
    setState(() {
      _taskList = DBHelper().getTaskList();
    });
  }

  Widget _buildItem(Task task) {
    return Container(
      height: 60,
      margin: EdgeInsets.only(bottom: 5),
      color: Colors.deepOrangeAccent,
      child: ListTile(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => AddTask(
                      updateTaskList: _updateTaskList,
                      task: task,
                    ))),
        title: Text(
          task.title!,
          style: TextStyle(
            decoration: task.status == 0
                ? TextDecoration.none
                : TextDecoration.lineThrough,
          ),
        ),
        subtitle: Text(
          _dateFormat.format(task.date),
          style: TextStyle(
              decoration: task.status == 0
                  ? TextDecoration.none
                  : TextDecoration.lineThrough),
        ),
        trailing: Checkbox(
          activeColor: Theme.of(context).primaryColor,
          onChanged: (bool? value) {
            if (value != null) task.status = value ? 1 : 0;
            DBHelper().updateTask(task);
            _updateTaskList();
          },
          value: task.status == 0 ? false : true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("App Bar"),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            UserAccountsDrawerHeader(
              arrowColor: Colors.green,
              accountName: Text("Zakariya"),
              accountEmail: Text("zakariya@gmail.com"),
              currentAccountPicture: GestureDetector(
                child: CircleAvatar(
                    backgroundImage: AssetImage(
                  "assets/images/user.jpeg",
                )),
              ),
              // decoration: BoxDecoration(color: Colors.red),
            ),
            ListTile(
              title: Text("Home"),
              leading: Icon(Icons.home),
              onTap: () {},
            ),
            ListTile(
              title: Text("Categories"),
              leading: Icon(Icons.view_list),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: Container(
          child: FutureBuilder(
        future: _taskList,
        builder: (context, AsyncSnapshot snapshot) {
          return ListView.builder(
            itemCount: snapshot.data.length+1 ,
            itemBuilder: (BuildContext context, int index) {
              final int completedTask = snapshot.data
                  .where((Task task) => task.status == 1)
                  .toList()
                  .length;

              if(index == 0) {
                return Container(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "My Tasks",
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "$completedTask/${snapshot.data.length}",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    )
                  ],
                ));
              } else {
                return _buildItem(snapshot.data[index - 1]);
              }
            },
          );
        },
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => AddTask(
                      updateTaskList: _updateTaskList,
                    ))),
        child: Icon(Icons.add),
      ),
    );
  }
}
