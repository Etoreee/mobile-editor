// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

class ProjectScreen extends StatefulWidget {
  final String projectName;
  final TreeController<FileNode> treeController;
  final VoidCallback onBackPressed;

  const ProjectScreen({super.key, 
    required this.projectName,
    required this.treeController,
    required this.onBackPressed,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ProjectScreenState createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  late TextEditingController _fileContentController;
  FileNode? _selectedFile;

  @override
  void initState() {
    super.initState();
    _fileContentController = TextEditingController();
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
                    treeController: widget.treeController,
                    nodeBuilder: (context, entry) {
                      return MyTreeTile(
                        entry: entry,
                        onTap: () => toggleExpanded(entry),
                        onRename: (newTitle) => renameNode(entry.node, newTitle),
                        onDelete: () => deleteNode(entry.node),
                        onAddChild: () => showCreateNodeDialogInTree(entry.node),
                        isFile: !entry.node.isDirectory,
                        onFileSelected: (node) {
                          setState(() {
                            _selectedFile = node;
                            _fileContentController.text = node.title;
                          },);
                        },
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
                    _selectedFile!.title = value;
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
        title: Text(isDirectory ? 'Створити нову папку' : 'Створити новий файл'),
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

void showCreateNodeDialogInTree(FileNode parentNode) {
  showDialog(
    context: context,
    builder: (context) {
      String newNodeTitle = '';
      bool isNewDirectory = false;
      return AlertDialog(
        title: Text('Створити новий вузол у "${parentNode.title}"'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              onChanged: (value) {
                newNodeTitle = value;
              },
              decoration: const InputDecoration(
                hintText: 'Назва вузла',
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Тип вузла:'),
                RadioListTile<bool>(
                  value: false,
                  groupValue: !isNewDirectory,
                  onChanged: (value) {
                    setState(() {
                      isNewDirectory = value == false;
                    });
                  },
                  activeColor: Theme.of(context).primaryColor,
                  title: const Text('Файл'),
                ),
                RadioListTile<bool>(
                  value: true,
                  groupValue: isNewDirectory,
                  onChanged: (value) {
                    setState(() {
                      isNewDirectory = value == true;
                    });
                  },
                  activeColor: Theme.of(context).primaryColor,
                  title: const Text('Папка'),
                ),
              ],
            ),
          ],
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
              createNode(parentNode, newNodeTitle, isNewDirectory);
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
    widget.treeController.roots = [...widget.treeController.roots, newNode];
  } else {
    addNode(parentNode, newNode);
  }
  widget.treeController.rebuild();
}

void addNode(FileNode parent, FileNode newNode) {
  parent.children.add(newNode);
  widget.treeController.rebuild();
}
  void renameNode(FileNode node, String newTitle) {
    List<FileNode> rootsList = List.from(widget.treeController.roots);
    for (int i = 0; i < rootsList.length; i++) {
      if (rootsList[i].key == node.key) {
        rootsList[i] = node.copyWith(title: newTitle);
        widget.treeController.roots = rootsList;
        widget.treeController.rebuild();
        return;
      }
    }
  }

  void toggleExpanded(TreeEntry<FileNode> entry) {
    widget.treeController.toggleExpansion(entry as FileNode);
  }

  void deleteNode(FileNode node) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Видалити вузол'),
        content: Text('Ви впевнені, що хочете видалити "${node.title}"?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Скасувати'),
          ),
          TextButton(
            onPressed: () {
              _deleteNode(node);
              Navigator.pop(context);
            },
            child: const Text('Видалити'),
          ),
        ],
      );
    },
  );
}

void _deleteNode(FileNode node) {
  List<FileNode> rootsList = List.from(widget.treeController.roots);
  for (int i = 0; i < rootsList.length; i++) {
    removeNodeRecursive(rootsList[i], node);
  }
  widget.treeController.roots = rootsList;
  widget.treeController.rebuild();
}

  void removeNodeRecursive(FileNode node, FileNode targetNode) {
  if (node.children.contains(targetNode)) {
    node.children.remove(targetNode);
    widget.treeController.rebuild();
    return;
  }

  for (final child in node.children) {
    removeNodeRecursive(child, targetNode);
  }
 }
}
class FileNode {
  final String key;
  String title;
  final bool isDirectory;
  final List<FileNode> children;

  FileNode({
    required this.key,
    this.title = '',
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
    required this.isFile,
    required this.onFileSelected,
  });

  final TreeEntry<FileNode> entry;
  final VoidCallback onTap;
  final ValueChanged<String> onRename;
  final VoidCallback onDelete;
  final VoidCallback onAddChild; 
  final bool isFile;
  final ValueChanged<FileNode> onFileSelected;

  @override
  State<MyTreeTile> createState() => _MyTreeTileState();
}



void createNode(FileNode? parentNode, String newNodeTitle, bool isDirectory) {
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