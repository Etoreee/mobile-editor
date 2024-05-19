import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

class ProjectPage extends StatelessWidget {
  final String projectName;
  final TreeController<FileNode> treeController;

  ProjectPage({required this.projectName, required this.treeController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(projectName),
      ),
      body: TreeView(
        treeController: treeController,
        nodeBuilder: (context, entry) {
          return MyTreeTile(
            entry: entry,
            onTap: () => toggleExpanded(entry),
            onRename: (newTitle) => renameNode(entry.node, newTitle),
            onDelete: () => deleteNode(entry.node),
            onAddChild: () => addNode(
              entry.node,
              FileNode(
                key: DateTime.now().millisecondsSinceEpoch.toString(),
                title: 'Новий файл',
                isDirectory: false,
              ),
            ),
          );
        },
      ),
    );
  }

  void addNode(FileNode parent, FileNode newNode) {
    parent.children.add(newNode);
    treeController.rebuild();
  }

  void renameNode(FileNode node, String newTitle) {
    List<FileNode> rootsList = List.from(treeController.roots);
    for (int i = 0; i < rootsList.length; i++) {
      if (rootsList[i].key == node.key) {
        rootsList[i] = node.copyWith(title: newTitle);
        treeController.roots = rootsList;
        treeController.rebuild();
        return;
      }
    }
  }

void toggleExpanded(TreeEntry<FileNode> entry) {
    treeController.toggleExpansion(entry as FileNode);
}


  void deleteNode(FileNode node) {
    if (treeController.roots.isNotEmpty) {
      removeNodeRecursive(treeController.roots.elementAt(0), node);
      treeController.rebuild();
    }
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
          title: const Text('MOBILE-EDITOR'),
          content: TextField(
            controller: textController,
            maxLines: null,
            expands: true,
            style: const TextStyle(
              fontFamily: 'RobotoMono',
              fontSize: 16.0,
            ),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Відмінити'),
            ),
            TextButton(
              onPressed: () {
                renameNode(node, textController.text);
                Navigator.pop(context);
              },
              child: const Text('Зберегти'),
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
        guide: const IndentGuide.connectingLines(indent: 48),
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
                    style: const TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 14.0,
                    ),
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  setState(() {
                    _isRenaming = true;
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: widget.onDelete,
              ),
              IconButton(
                icon: const Icon(Icons.add),
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