import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/core/constants/app_strings.dart';
import 'package:sunu_task/models/Task.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/providers/task_provider.dart';
import 'package:sunu_task/widgets/cards/task_card.dart';
import 'package:uuid/uuid.dart';

void showCreateTaskDialog(BuildContext context) {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  final auth = Provider.of<AuthProvider>(context, listen: false);
  final taskProv = Provider.of<TaskProvider>(context, listen: false);

  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text(AppStrings.newTask),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: AppStrings.taskTitleLabel,
              hintText: AppStrings.taskTitleHint,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: descController,
            decoration: const InputDecoration(
              labelText: AppStrings.taskDescriptionOptional,
              hintText: AppStrings.taskDescriptionHint,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text(AppStrings.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            if (titleController.text.isNotEmpty && auth.currentUser != null) {
              final newTask = Task(
                id: const Uuid().v4(),
                userId: auth.currentUser!.id,
                title: titleController.text,
                description: descController.text,
                createdAt: DateTime.now(),
                isCompleted: false,
              );

              taskProv.createTask(newTask);
              Navigator.pop(dialogContext);
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text(AppStrings.create, style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

void showEditTaskDialog(BuildContext context, Task task) {
  final TextEditingController titleController = TextEditingController(text: task.title);
  final TextEditingController descController = TextEditingController(text: task.description);

  final taskProv = Provider.of<TaskProvider>(context, listen: false);

  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text(AppStrings.editTask),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: AppStrings.taskTitleLabel,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: descController,
            decoration: const InputDecoration(
              labelText: AppStrings.taskDescriptionOptional,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text(AppStrings.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            if (titleController.text.isNotEmpty) {
              final updated = task.copyWith(
                title: titleController.text,
                description: descController.text,
              );
              taskProv.updateTask(updated);
              Navigator.pop(dialogContext);
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text(AppStrings.save, style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

void showDeleteTaskDialog(BuildContext context, Task task) {
  final taskProv = Provider.of<TaskProvider>(context, listen: false);

  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text(AppStrings.deleteTask),
      content: Text(
        "${AppStrings.confirmDeleteTaskPrefix} \"${task.title}\" ? ${AppStrings.confirmDeleteTaskSuffix}",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text(AppStrings.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            taskProv.deleteTask(task.id);
            Navigator.pop(dialogContext);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text(AppStrings.delete, style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

class TasksTab extends StatelessWidget {
  const TasksTab({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final tasks = taskProvider.tasks;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      floatingActionButton: Builder(
        builder: (innerContext) => FloatingActionButton(
          onPressed: () => showCreateTaskDialog(innerContext),
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      body: tasks.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return TaskCard(
                  task: task,
                  onTap: () {},
                  onEdit: (t) => showEditTaskDialog(context, t),
                  onDelete: (_) => showDeleteTaskDialog(context, task),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            AppStrings.noTasks,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
          const Text(AppStrings.noTasksDesc),
        ],
      ),
    );
  }
}
