class Task:
    def __init__(self, title, description, due_date):
        self.title = title
        self.description = description
        self.due_date = due_date
        self.completed = False

    def mark_completed(self):
        self.completed = True

    def __str__(self):
        status = "Completed" if self.completed else "Pending"
        return f"{self.title} - {status} (Due: {self.due_date})"


class TaskManager:
    def __init__(self):
        self.tasks = []

    def add_task(self, title, description, due_date):
        task = Task(title, description, due_date)
        self.tasks.append(task)

    def list_tasks(self):
        if not self.tasks:
            print("No tasks available.")
            return
        for idx, task in enumerate(self.tasks, start=1):
            print(f"{idx}. {task}")

    def mark_task_completed(self, task_index):
        if 0 <= task_index < len(self.tasks):
            self.tasks[task_index].mark_completed()
            print(f"Task '{self.tasks[task_index].title}' marked as completed.")
        else:
            print("Invalid task index.")

    def delete_task(self, task_index):
        if 0 <= task_index < len(self.tasks):
            removed_task = self.tasks.pop(task_index)
            print(f"Task '{removed_task.title}' has been deleted.")
        else:
            print("Invalid task index.")

    def edit_task(self, task_index, new_title=None, new_description=None, new_due_date=None):
        if 0 <= task_index < len(self.tasks):
            task = self.tasks[task_index]
            if new_title:
                task.title = new_title
            if new_description:
                task.description = new_description
            if new_due_date:
                task.due_date = new_due_date
            print(f"Task '{task.title}' has been updated.")
        else:
            print("Invalid task index.")

    def search_tasks(self, keyword):
        results = [task for task in self.tasks if keyword.lower() in task.title.lower() or keyword.lower() in task.description.lower()]
        if results:
            print("Search results:")
            for task in results:
                print(task)
        else:
            print("No tasks found matching the keyword.")

    def clear_completed_tasks(self):
        self.tasks = [task for task in self.tasks if not task.completed]
        print("All completed tasks have been cleared.")

    def sort_tasks_by_due_date(self):
        self.tasks.sort(key=lambda task: task.due_date)
        print("Tasks have been sorted by due date.")


# Example usage
if __name__ == "__main__":
    manager = TaskManager()
    manager.add_task("Buy groceries", "Milk, eggs, bread", "2023-10-10")
    manager.add_task("Finish project", "Complete the final report", "2023-10-15")
    manager.list_tasks()
    manager.mark_task_completed(0)
    manager.list_tasks()
    manager.edit_task(1, new_title="Submit project", new_due_date="2023-10-14")
    manager.list_tasks()
    manager.search_tasks("project")
    manager.clear_completed_tasks()
    manager.list_tasks()
    manager.sort_tasks_by_due_date()
    manager.list_tasks()