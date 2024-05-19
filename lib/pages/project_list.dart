import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'project.dart';

class ProjectList extends StatefulWidget {
  @override
  _ProjectListState createState() => _ProjectListState();
}

class _ProjectListState extends State<ProjectList> {
  List<String> projects = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Список проектів'),
      ),
      body: ListView.builder(
        itemCount: projects.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(projects[index]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProjectPage(
                    projectName: projects[index],
                    treeController: TreeController(
                      roots: [],
                      childrenProvider: (FileNode node) => node.children,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              String newProjectName = '';
              return AlertDialog(
                title: Text('Створити новий проект'),
                content: TextField(
                  onChanged: (value) {
                    newProjectName = value;
                  },
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Скасувати'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        projects.add(newProjectName);
                      });
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProjectPage(
                            projectName: newProjectName,
                            treeController: TreeController(
                              roots: [],
                              childrenProvider: (FileNode node) => node.children,
                            ),
                          ),
                        ),
                      );
                    },
                    child: Text('Створити'),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}