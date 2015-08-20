// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:html';
import 'dart:async';
import 'todo.dart';
import 'database.dart';

// UI Controls
InputElement todoInput;
DivElement UIList;
ButtonElement buttonClearTodoList;
ButtonElement buttonAll;
ButtonElement buttonDone;
ButtonElement buttonPending;
Element allTodoLength;
Element pendingTodoLength;
Element doneTodoLength;

// Database Handler
Store context = new Store();

void main() {
  todoInput = querySelector('#todo');
  UIList = querySelector('#todo-list');
  buttonClearTodoList = querySelector('#clear');
  buttonAll = querySelector('#all');
  buttonPending = querySelector('#pending');
  buttonDone = querySelector('#done');
  allTodoLength = querySelector('#all-length');
  pendingTodoLength = querySelector('#pending-length');
  doneTodoLength = querySelector('#done-length');
  todoInput.onChange.listen(addTodo);
  buttonClearTodoList.onClick.listen(removeAllTodos);
  buttonAll.onClick.listen((e) => renderTodos(null));
  buttonPending.onClick.listen((e) => renderTodos(false));
  buttonDone.onClick.listen((e) => renderTodos(true));
  context.open().then((result) => renderTodos(null));
}

Future addTodo(Event e) async {
  Todo todo = new Todo(todoInput.value, false);
  await context.add(todo.toRaw());
  renderTodos(null);
  renderlengthOfTodos();
  todoInput.value = '';
}

Future updateChecked(Event e) async {
  Element div = e.currentTarget as Element;
  int key = int.parse(div.id.split('-')[1]);
  var rawTodo = await context.get(key);
  rawTodo['checked'] = (rawTodo['checked'] == 'true') ? 'false' : 'true';
  await context.update(key, rawTodo);
  (rawTodo['checked'] == 'true') ? div.classes.add('checked-line') : div.classes.remove('checked-line');
  renderlengthOfTodos();
}

Future removeTodo(Event e) async {
  e.stopPropagation();
  Element element = (e.currentTarget as Element).parent;
  int key = int.parse(element.id.split('-')[1]);
  await context.delete(key);
  element.remove();
  renderlengthOfTodos();
}

Future removeAllTodos (Event e) async {
  await context.deleteAll();
  UIList.children.clear();
  renderlengthOfTodos();
}

void renderTodos(bool checked) async {
  List rawTodos = await context.getAll();
  UIList.children.clear();

  // Filter Todos if necessary
  if (checked != null) {
    rawTodos = rawTodos.where((rawTodo) => rawTodo['checked'].toString() == checked.toString());
  }

  rawTodos.forEach((rawTodo) {
    Todo todo = new Todo.fromJson(rawTodo);

    DivElement div = new Element.div();
    div.id = 'todo-' + todo.id.toString();
    div.onClick.listen(updateChecked);
    (todo.checked) ? div.classes.add('checked-line') : null;

    ButtonElement buttonRemove = new ButtonElement();
    buttonRemove.text = 'X';
    buttonRemove.id = todo.id.toString();
    buttonRemove.onClick.listen(removeTodo);

    Element span = new Element.span();
    span.text = todo.text;

    div.children.add(buttonRemove);
    div.children.add(span);
    UIList.children.add(div);
  });

  renderlengthOfTodos();
}


void renderlengthOfTodos () {
  allTodoLength.text = getLenghtOfTodos(null).toString();
  pendingTodoLength.text = getLenghtOfTodos(false).toString();
  doneTodoLength.text = getLenghtOfTodos(true).toString();
}

int getLenghtOfTodos (bool checked) {
  List todos = UIList.children;
  if (checked != null) {

    todos = todos.where((rawTodo) {
      bool result = (rawTodo as Element).classes.contains('checked-line');
      return (checked) ? result : !result;
    });
  }
  return todos.length;
}