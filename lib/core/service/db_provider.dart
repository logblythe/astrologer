import 'dart:io';

import 'package:astrologer/core/data_model/message_model.dart';
import 'package:astrologer/core/data_model/user_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
         id integer primary key not null,
         userId integer,
         firstName text,
         lastName text,
         email text,
         phoneNumber text,
         gender text,
         city text,
         state text,
         country text,
         role text,
         dateOfBirth text,
         birthTime text,
         accurateTime integer
        )""");
      batch.execute(""" 
       create table if not exists messages(
         id integer primary key not null,
         message text,
         sent integer,
         status text,
         questionId integer
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

  Future<int> addUser(UserModel user) async {
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
    return UserModel.fromDb(users.first);
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
    print('message is ${message.toString()}');
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
        "UPDATE messages SET status = ? WHERE questionId = ?", [statusV, questionId]);
    return _id;
  }
}
