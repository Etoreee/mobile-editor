import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

import 'package:mobile_red/pages/home.dart';

class SideBar extends StatelessWidget {
  final TreeController<FileNode> treeController;
  final Function(BuildContext, FileNode) showFileEditor;
  final Function(FileNode, String) renameNode;
  final Function(FileNode) deleteNode;
  final Function(FileNode, FileNode) addNode;

  const SideBar({
    super.key,
    required this.treeController,
    required this.showFileEditor,
    required this.renameNode,
    required this.deleteNode,
    required this.addNode,
  });

  @override
  Widget build(BuildContext context) {
    return TreeView<FileNode>(
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
    );
  }
}