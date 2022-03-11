import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_zaynidddin/model/task.dart';

class DBHelper {


  static DBHelper _databaseHelper = DBHelper
      ._createInstance(); //SINGLETON DBHELPER

  static Database? _database;

  DBHelper._createInstance(); //NAMED CONST TO CREATE INSTANCE OF THE DBHELPER

  String dbName = "todo_list";

  String taskTable = 'task_table';

  String colId = 'id';
  String colTitle = 'title';
  String colDate = 'date';
  String colPriority = 'priority';
  String colStatus = 'status';

  factory DBHelper() {
    _databaseHelper = DBHelper._createInstance();
    return _databaseHelper;
  }

  Future<Database?> get database async {
    _database ??= await initializeDatabase();
    return _database;
  }

  Future<Database?> initializeDatabase() async {
    //GET THE PATH TO THE DIRECTORY FOR IOS AND ANDROID TO STORE DB
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + dbName;

    //OPEN/CREATE THE DB AT A GIVEN PATH
    var todoListDb =
    await openDatabase(path, version: 1, onCreate: _createDb);
    return todoListDb;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $taskTable('
            '$colId INTEGER PRIMARY KEY AUTOINCREMENT,'
            '$colTitle TEXT, '
            '$colPriority INTEGER, '
            '$colDate TEXT, '
            '$colStatus INTEGER)'
    );
  }

  Future<List<Map<String, dynamic>>?> getTaskMapList() async {
    Database? db = await this.database;
    final List<Map<String, Object?>>? result = await db?.query(taskTable);
    return result;
  }

  Future<List<Task>> getTaskList() async{
    final List<Map<String, dynamic>>? taskMapList = await getTaskMapList();
    final List<Task> taskList = [];
    taskMapList?.forEach((taskMap) {
      taskList.add(Task.fromMap(taskMap));
    });

    return taskList;
  }

  Future <int?> insertTask(Task task) async {
    Database? db = await this.database;
    final int? result = await db?.insert(taskTable, task.toMap());
    return result;
  }

  Future<int?> updateTask(Task task) async{
    Database? db = await this.database;
    final int? result = await db?.update(taskTable, task.toMap(), where: '$colId = ?', whereArgs: [task.id]);
    return result;
  }

  Future<int?> deleteTask(int? id) async{
     Database? db = await this.database;
     final int ? result = await db?.delete(taskTable, where: '$colId = ?', whereArgs: [id]);
     return result;
  }


}
/*


class DatabaseHelper {
  static Database _database;
  static DatabaseHelper _databaseHelper; //SINGLETON DBHELPER
  DatabaseHelper._createInstance(); //NAMED CONST TO CREATE INSTANCE OF THE DBHELPER

  String noteTable = 'note_table';
  String colid = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colDate = 'date';
  String colPriority = 'priority';

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper =
          DatabaseHelper._createInstance(); //EXEC ONLY ONCE (SINGLETON OBJ)
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    //GET THE PATH TO THE DIRECTORY FOR IOS AND ANDROID TO STORE DB
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + "note.db";

    //OPEN/CREATE THE DB AT A GIVEN PATH
    var notesDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $noteTable($colid INTEGER PRIMARY KEY AUTOINCREMENT,'
        '$colTitle TEXT, $colDescription TEXT, $colPriority INTEGER, $colDate TEXT)');
  }

  //FETCH TO GET ALL NOTES
  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await this.database;
    var result =
        db.rawQuery("SELECT * FROM $noteTable ORDER BY $colPriority ASC");
//    var result = await db.query(noteTable, orderBy: "$colPriority ASC");  //WORKS THE SAME CALLED HELPER FUNC
    return result;
  }

  //INSERT OPS
  Future<int> insertNote(Note note) async
  {
    Database db = await this.database;
    var result = await db.insert(noteTable, note.toMap());
    return result;
  }

  //UPDATE OPS
  Future<int> updateNote(Note note) async
  {
    var db = await this.database;
    var result =
    await db.update(noteTable, note.toMap(), where: '$colid = ?', whereArgs: [note.id]);
    return result;
  }

  //DELETE OPS
  Future<int> deleteNote(int id) async
  {
    var db = await this.database;
    int result = await db.delete(noteTable, where:"$colid = ?", whereArgs: [id]);
    return result;
  }

  //GET THE NO:OF NOTES
  Future<int> getCount() async
  {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery("SELECT COUNT (*) FROM $noteTable");
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  //GET THE 'MAP LIST' [List<Map>] and CONVERT IT TO 'Note List' [List<Note>]
  Future<List<Note>> getNoteList() async
  {
    var noteMapList = await getNoteMapList(); //GET THE MAPLIST FROM DB
    int count = noteMapList.length; //COUNT OF OBJS IN THE LIST
    List<Note> noteList = List<Note>();
    for(int index=0; index<count; index++)
      {
        noteList.add(Note.fromMapObject(noteMapList[index]));
      }
      return noteList;
  }
}*/