import 'dart:async';
import 'dart:indexed_db' as idb;
import 'dart:html' show window;

class Store {
  static const String _DATABASE_NAME = 'todoDB';
  static const String _TODO_STORE = 'todoStore';
  static const String _NAME_INDEX = 'text';

  final List<Map> todos = [];
  idb.Database _db;

  // Open database connection
  Future open () async {
    return window.indexedDB.open(_DATABASE_NAME, version: 1, onUpgradeNeeded: _initializeDatabase)
    .then(await _loadFromDB)
    .catchError(_onError);
  }

  // Handle Errors for Developers
  void _onError(e) {
    print('Oh no! Something went wrong. See the console for details.');
    print('An error occurred: {$e}');
    throw e;
  }

  // Create the database schema
  void _initializeDatabase(idb.VersionChangeEvent e) {
    idb.Database db = (e.target as idb.Request).result;
    var objectStore = db.createObjectStore(_TODO_STORE, autoIncrement: true);
    objectStore.createIndex(_NAME_INDEX, 'todo', unique: true);
  }

  // Load all database objects
  Future _loadFromDB(idb.Database db) {
    _db = db;
    var transaction = _db.transaction(_TODO_STORE, 'readonly');
    var store = transaction.objectStore(_TODO_STORE);
    var cursors = store.openCursor(autoAdvance:true);
    cursors.listen((cursor) {
      Map rawTodo = cursor.value;
      rawTodo['id'] = cursor.key;
      todos.add(rawTodo);
    })
    .onError(_onError);
    return store.transaction.completed.then((e) => e );
  }

  // Get all records
  Future getAll() {
    todos.clear();
    var transaction = _db.transaction(_TODO_STORE, 'readonly');
    var store = transaction.objectStore(_TODO_STORE);
    var cursors = store.openCursor(autoAdvance:true);
    cursors.listen((cursor) {
      Map rawTodo = cursor.value;
      rawTodo['id'] = cursor.key;
      todos.add(rawTodo);
    })
    .onError(_onError);
    return store.transaction.completed.then((e) => todos );
  }

  // Get one record
  Future get (int key) {
    var transaction = _db.transaction(_TODO_STORE, 'readonly');
    var store = transaction.objectStore(_TODO_STORE);
    return store.getObject(key)
    .then((rawItem) {
      (rawItem as Map)['id'] = key;
      return rawItem;
    })
    .catchError(_onError);
  }

  // Insert one record
  Future add(Map rawItem) {
    var transaction = _db.transaction(_TODO_STORE, 'readwrite');
    var store = transaction.objectStore(_TODO_STORE);

    store.add(rawItem)
    .then((key) {
      rawItem['id'] = key;
      return rawItem;
    })
    .catchError((e) => _onError);

    return transaction.completed.then((e) {
      todos.add(rawItem);
      return rawItem;
    });
  }

  // Update a record
  Future update(int key, Map rawItem) async{
    var transaction = _db.transaction(_TODO_STORE, 'readwrite');
    var store = transaction.objectStore(_TODO_STORE);

    store.put(rawItem, key)
    .then((key) => key)
    .catchError(_onError);

    return transaction.completed.then((key) => key );
  }

  // Delete a record
  Future delete(int key) {
    var transaction = _db.transaction(_TODO_STORE, 'readwrite');
    var store = transaction.objectStore(_TODO_STORE);

    return store.delete(key)
    .then((key) => key)
    .catchError(_onError);
  }

  // Delete all records
  Future deleteAll() {
    var transaction = _db.transaction(_TODO_STORE, 'readwrite');
    var store = transaction.objectStore(_TODO_STORE);

    return store.clear()
    .catchError(_onError);
  }
}