import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  MyNode? rootNode;
  late TreeController<MyNode> treeController;

  @override
  void initState() {
    super.initState();
    treeController = TreeController<MyNode>(
      roots: rootNode != null ? [rootNode!] : [],
      childrenProvider: (MyNode node) => node.children,
    );
  }

  @override
  void dispose() {
    treeController.dispose();
    super.dispose();
  }

  void _createNewProject() async {
    final projectName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Створити проєкт'),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Ім\'я проєкту',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Відмінити'),
            ),
            ElevatedButton(
              onPressed: () {
                _createNewProject();
                Navigator.of(context).pop();
              },
              child: Text('Створити'),
            ),
          ],
        );
      },
    );

    if (projectName != null) {
      final projectNode = MyNode(
        key: DateTime.now().millisecondsSinceEpoch.toString(),
        title: projectName,
        isDirectory: true,
        children: [
          MyNode(
            key: DateTime.now().millisecondsSinceEpoch.toString() + '1',
            title: 'Folder 1',
            isDirectory: true,
            children: [],
          ),
          MyNode(
            key: DateTime.now().millisecondsSinceEpoch.toString() + '2',
            title: 'Folder 2',
            isDirectory: true,
            children: [],
          ),
          MyNode(
            key: DateTime.now().millisecondsSinceEpoch.toString() + '3',
            title: 'Folder 3',
            isDirectory: true,
            children: [],
          ),
        ],
      );

      setState(() {
        rootNode = projectNode;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: rootNode == null
          ? AppBar(
              title: Text('MOBILE-EDITOR'),
            )
          : null,
      body: rootNode == null
          ? Center(
              child: ElevatedButton(
                onPressed: _createNewProject,
                child: Text('Створити проєкт'),
              ),
            )
          : TreeView<MyNode>(
              treeController: treeController,
              nodeBuilder: (BuildContext context, TreeEntry<MyNode> entry) {
                return MyTreeTile(
                  entry: entry,
                  onTap: () {
                    if (!entry.node.isDirectory) {
                      showFileEditor(context, entry.node);
                    } else {
                      treeController.toggleExpansion(entry.node);
                    }
                  },
                  onRename: (newTitle) => renameNode(entry.node, newTitle),
                  onDelete: () => deleteNode(entry.node),
                  onAddChild: () {
                    final newNode = MyNode(
                      key: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: 'New Folder',
                      isDirectory: true,
                      children: [],
                    );
                    addNode(entry.node, newNode);
                  },
                );
              },
            ),
    );
  }

  void addNode(MyNode parent, MyNode newNode) {
    setState(() {
      parent.children.add(newNode);
    });
  }

  void renameNode(MyNode node, String newTitle) {
    setState(() {
      node.title = newTitle;
    });
  }

  void deleteNode(MyNode node) {
    setState(() {
      if (rootNode != null) {
        removeNodeRecursive(rootNode!, node);
      }
    });
  }

  void removeNodeRecursive(MyNode node, MyNode targetNode) {
    if (node.children.contains(targetNode)) {
      node.children.remove(targetNode);
      return;
    }

    for (final child in node.children) {
      removeNodeRecursive(child, targetNode);
    }
  }

  void showFileEditor(BuildContext context, MyNode node) {
    final textController = TextEditingController(text: node.title);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('MOBILE-EDITOR'),
          content: TextField(
            controller: textController,
            maxLines: null,
            expands: true,
            style: TextStyle(
              fontFamily: 'RobotoMono',
              fontSize: 16.0,
            ),
            decoration: InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Відмінити'),
            ),
            TextButton(
              onPressed: () {
                renameNode(node, textController.text);
                Navigator.pop(context);
              },
              child: Text('Зберегти'),
            ),
          ],
        );
      },
    );
  }
}

class MyNode {
  final String key;
  String title;
  final bool isDirectory;
  final List<MyNode> children;

  MyNode({
    required this.key,
    required this.title,
    required this.isDirectory,
    this.children = const <MyNode>[],
  });

  MyNode copyWith({String? title, bool? isDirectory, List<MyNode>? children}) {
    return MyNode(
      key: key,
      title: title ?? this.title,
      isDirectory: isDirectory ?? this.isDirectory,
      children: children ?? this.children,
    );
  }
}

class MyTreeTile extends StatefulWidget {
  const MyTreeTile({
    super.key,
    required this.entry,
    required this.onTap,
    required this.onRename,
    required this.onDelete,
    required this.onAddChild,
  });

  final TreeEntry<MyNode> entry;
  final VoidCallback onTap;
  final ValueChanged<String> onRename;
  final VoidCallback onDelete;
  final VoidCallback onAddChild;

  @override
  State<MyTreeTile> createState() => _MyTreeTileState();
}

class _MyTreeTileState extends State<MyTreeTile> {
  bool _isRenaming = false;
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textController.text = widget.entry.node.title;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: TreeIndentation(
        entry: widget.entry,
        guide: IndentGuide.connectingLines(indent: 48),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 8, 8),
          child: Row(
            children: [
              FolderButton(
                isOpen: widget.entry.hasChildren ? widget.entry.isExpanded : null,
                onPressed: widget.entry.hasChildren ? widget.onTap : null,
              ),
              if (_isRenaming)
                Expanded(
                  child: TextField(
                    controller: _textController,
                    onSubmitted: (newTitle) {
                      setState(() {
                        _isRenaming = false;
                      });
                      widget.onRename(newTitle);
                    },
                  ),
                )
              else
                Expanded(
                  child: Text(
                    widget.entry.node.title,
                    style: TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 16.0,
                    ),
                  ),
                ),
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  setState(() {
                    _isRenaming = true;
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: widget.onDelete,
              ),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: widget.onAddChild,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FolderButton extends StatelessWidget {
  const FolderButton({
    super.key,
    this.isOpen,
    this.onPressed,
  });

  final bool? isOpen;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isOpen == null
            ? Icons.folder
            : isOpen!
                ? Icons.folder_open
                : Icons.folder,
      ),
      onPressed: onPressed,
    );
  }
}