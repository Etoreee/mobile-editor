import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late TreeController<FileNode> treeController;

  @override
  void initState() {
    super.initState();
    treeController = TreeController<FileNode>(
      roots: [],
      childrenProvider: (FileNode node) => node.children,
    );
  }

  @override
  void dispose() {
    treeController.dispose();
    super.dispose();
  }

  void _createNewProject() async {
    final textController = TextEditingController();

    final projectName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Створити проєкт'),
          content: TextField(
            autofocus: true,
            controller: textController,
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
                Navigator.of(context).pop(textController.text);
              },
              child: Text('Створити'),
            ),
          ],
        );
      },
    );

    if (projectName != null) {
      final projectNode = FileNode(
        key: DateTime.now().millisecondsSinceEpoch.toString(),
        title: projectName,
        isDirectory: true,
        children: [
          FileNode(
            key: DateTime.now().millisecondsSinceEpoch.toString() + '1',
            title: 'Folder 1',
            isDirectory: true,
            children: [],
          ),
          FileNode(
            key: DateTime.now().millisecondsSinceEpoch.toString() + '2',
            title: 'Folder 2',
            isDirectory: true,
            children: [],
          ),
          FileNode(
            key: DateTime.now().millisecondsSinceEpoch.toString() + '3',
            title: 'Folder 3',
            isDirectory: true,
            children: [],
          ),
        ],
      );

      setState(() {
        treeController.roots = [projectNode];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: treeController.roots.isEmpty
          ? AppBar(
              title: Text('MOBILE-EDITOR'),
            )
          : null,
      body: treeController.roots.isEmpty
          ? Center(
              child: ElevatedButton(
                onPressed: _createNewProject,
                child: Text('Створити проєкт'),
              ),
            )
          : TreeView<FileNode>(
              treeController: treeController,
              nodeBuilder: (BuildContext context, TreeEntry<FileNode> entry) {
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
                    final newNode = FileNode(
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

  void addNode(FileNode parent, FileNode newNode) {
    setState(() {
      parent.children.add(newNode);
    });
  }

  void renameNode(FileNode node, String newTitle) {
    setState(() {
      node.title = newTitle;
    });
  }

  void deleteNode(FileNode node) {
    setState(() {
      if (treeController.roots.isNotEmpty) {
        removeNodeRecursive(treeController.roots.elementAt(0), node);
      }
    });
  }

  void removeNodeRecursive(FileNode node, FileNode targetNode) {
    if (node.children.contains(targetNode)) {
      node.children.remove(targetNode);
      return;
    }

    for (final child in node.children) {
      removeNodeRecursive(child, targetNode);
    }
  }

  void showFileEditor(BuildContext context, FileNode node) {
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

class FileNode {
  final String key;
  String title;
  final bool isDirectory;
  final List<FileNode> children;

  FileNode({
    required this.key,
    required this.title,
    required this.isDirectory,
    this.children = const <FileNode>[],
  });

  FileNode copyWith({String? title, bool? isDirectory, List<FileNode>? children}) {
    return FileNode(
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

  final TreeEntry<FileNode> entry;
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