/// Abstract base class for all tasks in the PSM system
/// Provides a standardized way to execute operations
abstract class Task<O> {
  const Task();

  /// Executes the task and returns a result of type O
  Future<O> run();
}

/// A group of tasks that are executed sequentially
/// The result of the last task in the group is returned
class TaskGroup<O> extends Task<O> {
  final List<Task> tasks;

  const TaskGroup({required this.tasks}) : super();

  /// Executes all tasks in the group sequentially
  /// Returns the result of the last executed task
  @override
  Future<O> run() async {
    dynamic result;
    for (var task in tasks) {
      result = await task.run();
    }
    return result as O;
  }
}
