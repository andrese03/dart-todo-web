// Model for Todo Class
class Todo {
  final int id;
  final String text;
  final bool checked;

  Todo(this.text, this.checked);

  Todo.fromJson(Map value):
  id = value['id'],
  text = value['text'],
  checked = (value['checked'] == 'true') ? true : false;

  Map toRaw() {
    return {
      'text': this.text,
      'checked': this.checked
    };
  }
}