// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

class ProjectScreen extends StatefulWidget {
  final String projectName;
  final VoidCallback onBackPressed;

  const ProjectScreen({
    super.key,
    required this.projectName,
    required this.onBackPressed,
  });

  @override
  _ProjectScreenState createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  late TextEditingController _fileContentController;
  late TreeController<FileNode> treeController;
  FileNode? _selectedFile;

  @override
  void initState() {
    super.initState();
    _fileContentController = TextEditingController();
    treeController = TreeController(
        roots: [], childrenProvider: (FileNode node) => node.children);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBackPressed,
        ),
        title: Text(widget.projectName),
      ),
      body: Row(
        children: [
          Drawer(
            child: Column(
              children: [
                UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 37, 35, 42),
                  ),
                  accountName: Text(
                    widget.projectName,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  currentAccountPicture: const CircleAvatar(
                    child: Icon(
                      Icons.folder,
                      color: Colors.white,
                    ),
                  ),
                  accountEmail: null,
                ),
                Expanded(
                  child: TreeView(
                    treeController: treeController,
                    nodeBuilder: (context, entry) {
                      return MyTreeTile(
                        entry: entry,
                        onTap: () => toggleExpanded(entry),
                        onRename: (newTitle) =>
                            renameNode(entry.node, newTitle),
                        onDelete: () => deleteNode(entry),
                        onAddChild: () =>
                            showCreateNodeDialog(entry.node, isDirectory: true),
                        isFile: !entry.node.isDirectory,
                        onFileSelected: (node) {
                          setState(
                            () {
                              _selectedFile = node;
                              _fileContentController.text = node.content;
                            },
                          );
                        },
                        onAddFile: () =>
                            showCreateNodeDialog(entry.node, isDirectory: false),
                        onAddFolder: () =>
                            showCreateNodeDialog(entry.node, isDirectory: true),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _fileContentController,
                maxLines: null,
                expands: true,
                style: const TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 16.0,
                ),
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: _selectedFile == null ? 'Виберіть файл' : null,
                ),
                enabled: _selectedFile != null,
                onChanged: (value) {
                  if (_selectedFile != null) {
                    _selectedFile!.content = value;
                  }
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'file',
            onPressed: createNewFile,
            child: const Icon(Icons.insert_drive_file),
          ),
          const SizedBox(width: 16.0),
          FloatingActionButton(
            heroTag: 'folder',
            onPressed: createNewFolder,
            child: const Icon(Icons.folder),
          ),
        ],
      ),
    );
  }

  void createNewFile() {
    showCreateNodeDialog(null, isDirectory: false);
  }

  void createNewFolder() {
    showCreateNodeDialog(null, isDirectory: true);
  }

  void showCreateNodeDialog(FileNode? parentNode, {bool isDirectory = false}) {
    String defaultTitle = isDirectory ? 'Нова папка' : 'Новий файл';
    showDialog(
      context: context,
      builder: (context) {
        String newNodeTitle = '';
        return AlertDialog(
          title:
              Text(isDirectory ? 'Створити нову папку' : 'Створити новий файл'),
          content: TextField(
            onChanged: (value) {
              newNodeTitle = value;
            },
            decoration: InputDecoration(
              hintText: defaultTitle,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Скасувати'),
            ),
            TextButton(
              onPressed: () {
                createNode(parentNode, newNodeTitle, isDirectory);
                Navigator.pop(context);
              },
              child: const Text('Створити'),
            ),
          ],
        );
      },
    );
  }

  void createNode(FileNode? parentNode, String title, bool isDirectory) {
  FileNode newNode = FileNode(
    key: DateTime.now().millisecondsSinceEpoch.toString(),
    title: title,
    isDirectory: isDirectory,
  );
  if (parentNode == null) {
    treeController.roots = [...treeController.roots, newNode];
  } else {
    parentNode.children = [...parentNode.children, newNode];
  }
  treeController.rebuild(); 

  
  print('Створено новий елемент: $newNode');
}


  void renameNode(FileNode node, String newTitle) {
    node.title = newTitle;
    treeController.rebuild();
  }

  void toggleExpanded(TreeEntry<FileNode> entry) {
    treeController.toggleExpansion(entry.node);
  }

  void deleteNode(TreeEntry<FileNode> entry) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Видалити вузол'),
          content:
              Text('Ви впевнені, що хочете видалити "${entry.node.title}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Скасувати'),
            ),
            TextButton(
              onPressed: () {
                _deleteNode(entry);
                Navigator.pop(context);
              },
              child: const Text('Видалити'),
            ),
          ],
        );
      },
    );
  }

  void _deleteNode(TreeEntry<FileNode> entry) {
    final parent = entry.parent;

    if (parent == null) {
      final roots = treeController.roots.toList();
      roots.remove(entry.node);
      treeController.roots = roots;
    } else {
      parent.node.children.remove(entry.node);
    }

    treeController.rebuild();
  }
}

class FileNode {
  final String key;
  String title;
  String content;
  final bool isDirectory;
  List<FileNode> children;

  FileNode({
    required this.key,
    this.title = '',
    required this.isDirectory,
    this.children = const <FileNode>[],
    this.content = '',
  });
}

class MyTreeTile extends StatefulWidget {
  const MyTreeTile({
    Key? key,
    required this.entry,
    required this.onTap,
    required this.onRename,
    required this.onDelete,
    required this.onAddChild,
    required this.isFile,
    required this.onFileSelected,
    required this.onAddFile,
    required this.onAddFolder,
  }) : super(key: key);

  final TreeEntry<FileNode> entry;
  final VoidCallback onTap;
  final ValueChanged<String> onRename;
  final VoidCallback onDelete;
  final VoidCallback onAddChild;
  final bool isFile;
  final ValueChanged<FileNode> onFileSelected;
  final VoidCallback onAddFile;
  final VoidCallback onAddFolder;

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
      onTap: () {
        widget.onTap();
        if (widget.isFile) {
          widget.onFileSelected(widget.entry.node);
        }
      },
      child: TreeIndentation(
        entry: widget.entry,
        guide: const IndentGuide.connectingLines(indent: 48),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 8, 8),
          child: Row(
            children: [
              NodeIcon(isDirectory: widget.entry.node.isDirectory),
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
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'add_file') {
                    widget.onAddFile();
                  } else if (value == 'add_folder') {
                    widget.onAddFolder();
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'add_file',
                    child: Text('Додати файл'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'add_folder',
                    child: Text('Додати папку'),
                  ),
                ],
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NodeIcon extends StatelessWidget {
  final bool isDirectory;

  const NodeIcon({
    super.key,
    required this.isDirectory,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      isDirectory ? Icons.folder : Icons.insert_drive_file,
      color: Colors.grey[600],
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
