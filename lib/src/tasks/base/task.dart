abstract class Task<O> {
  const Task();

  Future<O> run();
}

class TaskGroup<O> extends Task<O> {
  final List<Task> tasks;

  const TaskGroup({required this.tasks}) : super();

  @override
  Future<O> run() async {
    dynamic result;
    for (var task in tasks) {
      result = await task.run();
    }
    return result as O;
  }
}
