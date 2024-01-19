import 'package:chatapp/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TodoApp extends StatefulWidget {
  const TodoApp({super.key});

  @override
  TodoAppState createState() => TodoAppState();
}

class TodoAppState extends State<TodoApp> {
  final TextEditingController _taskController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User _user;
  late CollectionReference tasks;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!;
    tasks = FirebaseFirestore.instance.collection('tasks_${_user.uid}');
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginScreen()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Signed out succesfully"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo App'),
        actions: [
          IconButton(
            onPressed: () => showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("SignOut"),
                  content: const Text("Do you want to signout ?"),
                  actions: [
                    ElevatedButton(
                        onPressed: _signOut, child: const Text('Yes')),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('No')),
                  ],
                );
              },
            ),
            icon: const Icon(Icons.logout_outlined),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(color: Colors.red),
                height: 200,
                width: MediaQuery.of(context).size.width,
                child: Image.asset(
                  'assets/Todo.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              TextField(
                controller: _taskController,
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    addTask(value);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Task added."),
                      ),
                    );
                    _taskController.clear();
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Add a task',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      if (_taskController.text != "") {
                        addTask(_taskController.text);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Task added."),
                          ),
                        );
                        _taskController.clear();
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Tasks:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              StreamBuilder<QuerySnapshot>(
                stream: tasks.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: SizedBox(
                          height: 150,
                          width: 150,
                          child: CircularProgressIndicator()),
                    );
                  }

                  List<DocumentSnapshot> documents = snapshot.data!.docs;

                  return SizedBox(
                    height: 400,
                    child: ListView.builder(
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        return buildTaskItem(documents[index]);
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTaskItem(DocumentSnapshot document) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(document['task']),
        leading: Checkbox(
          value: document['completed'],
          onChanged: (bool? value) {
            updateTask(document.id, {'completed': value});
          },
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                showUpdateDialog(document);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                deleteTask(document.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> addTask(String task) {
    return tasks.add({
      'task': task,
      'completed': false,
    });
  }

  Future<void> updateTask(String taskId, Map<String, dynamic> data) {
    return tasks.doc(taskId).update(data);
  }

  Future<void> deleteTask(String taskId) {
    return tasks.doc(taskId).delete();
  }

  Future<void> showUpdateDialog(DocumentSnapshot document) async {
    TextEditingController updateController = TextEditingController();
    updateController.text = document['task'];
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Task'),
          content: TextField(
            controller: updateController,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                updateTask(document.id, {'task': updateController.text});
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Task updated."),
                  ),
                );
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }
}
