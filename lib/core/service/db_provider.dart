import 'dart:io';

import 'package:astrologer/core/data_model/message_model.dart';
import 'package:astrologer/core/data_model/user_model.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

const String ID = "id";
const String USER_ID = "userId";
const String FIRST_NAME = "firstName";
const String LAST_NAME = "lastName";
const String EMAIL = "email";
const String PASSWORD = "password";
const String PHONE = "phoneNumber";
const String GENDER = "gender";
const String CITY = "city";
const String STATE = "state";
const String COUNTRY = "country";
const String ROLE = "role";
const String DOB = "dateOfBirth";
const String BIRTH_TIME = "birthTime";
const String ACC_TIME = "accurateTime";

class DbProvider {
  Database db;

  Future<Database> get database async {
    if (db != null) return db;
    db = await init();
    return db;
  }

  List<String> migrationsScripts = [];

  Future<Database> init() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'eventus.db');
    db = await openDatabase(path, version: 1,
        onCreate: (database, version) async {
      Batch batch = database.batch();
      batch.execute(""" 
       create table if not exists user(
         $ID integer primary key autoincrement,
         $USER_ID integer,
         $FIRST_NAME text,
         $LAST_NAME text,
         $EMAIL text,
         $PASSWORD text,
         $PHONE text,
         $GENDER text,
         $CITY text,
         $STATE text,
         $COUNTRY text,
         $ROLE text,
         $DOB text,
         $BIRTH_TIME text,
         $ACC_TIME integer
        )""");
      batch.execute(""" 
       create table if not exists messages(
         $ID integer primary key not null,
         $MESSAGE text,
         $SENT integer,
         $STATUS text,
         $QUESTION_ID integer,
         $CREATED_AT integer,
         $UPDATED_AT integer,
         $ASTROLOGER text
        )""");
      await batch.commit();
    }, onUpgrade: (database, int oldVersion, int newVersion) async {
      print('old version $oldVersion new version $newVersion');
      for (int i = oldVersion - 1; i < newVersion - 1; i++) {
        await database.execute(migrationsScripts[i]);
        print("Migration successful");
      }
    }, onConfigure: onConfigure, onDowngrade: onDatabaseDowngradeDelete);
    return db;
  }

  Future onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future deleteAllTables() async {
    final db = await database;
    db.delete('user');
    db.delete('messages');
  }

  Future<int> addUser(UserModel user) async {
    print('user details ${user.toMapForDb()}');
    final db = await database;
    return db.insert(
      'user',
      user.toMapForDb(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<bool> userExists() async {
    final db = await database;
    var users = await db.query('user', columns: ['*']);
    return users.isNotEmpty;
  }

  Future<UserModel> getLoggedInUser() async {
    final db = await database;
    List<Map<String, dynamic>> users = await db.query('user', columns: ['*']);
    if (users.length > 0) return UserModel.fromDb(users.first);
    return null;
  }

  Future<int> updateUser(UserModel user) async {
    final db = await database;
    return db.update(
      'user',
      user.toMapForDb(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> addMessage(MessageModel message) async {
    final db = await database;
    return db.insert(
      'messages',
      message.toMapForDb(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateMessage(MessageModel messageModel, int id) async {
    final db = await database;
    return db.update(
      'messages',
      messageModel.toMapForDb(),
      where: 'id=?',
      whereArgs: [id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<MessageModel>> getAllMessages() async {
    final db = await database;
    List<Map<String, dynamic>> messages =
        await db.query('messages', columns: ['*']);
    return messages.map((e) {
      return MessageModel.fromDb(e);
    }).toList();
  }

  Future<int> getUnclearedQuestionId() async {
    MessageModel message;
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'messages',
      columns: ['*'],
      where: 'status=?',
      whereArgs: [UNCLEAR],
    );
    if (result.isNotEmpty) message = MessageModel.fromDb(result.first);
    return message?.id;
  }

  Future<int> updateQuestionStatus(int questionId, String statusV) async {
    final db = await database;
    int _id = await db.rawUpdate(
        "UPDATE messages SET status = ? WHERE engQuestionId = ?",
        [statusV, questionId]);
    return _id;
  }

  Future<int> updateQuestionStatusById(int id, String statusV) async {
    final db = await database;
    int _id = await db.rawUpdate(
        "UPDATE messages SET status = ? WHERE $ID = ?", [statusV, id]);
    print(_id);
    return _id;
  }
}
