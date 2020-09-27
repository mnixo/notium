import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:simplewave/core/graph.dart';
import 'package:simplewave/core/interactive_viewer.dart';
import 'package:simplewave/core/notes_folder_fs.dart';

class GraphViewScreen extends StatefulWidget {
  @override
  _GraphViewScreenState createState() => _GraphViewScreenState();
}

class _GraphViewScreenState extends State<GraphViewScreen> {
  Graph graph;

  @override
  Widget build(BuildContext context) {
    if (graph == null) {
      var rootFolder = Provider.of<NotesFolderFS>(context);
      setState(() {
        graph = Graph.fromFolder(rootFolder);
        graph.addListener(() {
          setState(() {});
        });
      });
      return Container(width: 2500, height: 2500);
    }

    return SafeArea(child: GraphView(graph));
  }
}

class GraphView extends StatefulWidget {
  final Graph graph;

  GraphView(this.graph);

  @override
  _GraphViewState createState() => _GraphViewState();
}

class _GraphViewState extends State<GraphView> {
  final nodeSize = 50.0;

  @override
  void initState() {
    super.initState();

    widget.graph.addListener(() {
      setState(() {});
    });
  }

  Offset _getLocationPosition(Offset globalPos) {
    RenderBox graphViewRenderBox = context.findRenderObject();
    assert(graphViewRenderBox != null);

    return graphViewRenderBox.globalToLocal(globalPos);
  }

  @override
  Widget build(BuildContext context) {
    var children = <Widget>[];

    children.add(CustomPaint(painter: GraphEdgePainter(widget.graph)));

    for (var node in widget.graph.nodes) {
      var w = Positioned(
        child: GestureDetector(
          child: NodeWidget(node, nodeSize),
          onPanStart: (details) {
            var pos = _getLocationPosition(details.globalPosition);
            node.x = pos.dx;
            node.y = pos.dy;
            node.pressed = true;

            if (node.y <= nodeSize / 2) {
              node.y = nodeSize / 2;
            }
            if (node.x <= nodeSize / 2) {
              node.x = nodeSize / 2;
            }

            widget.graph.notify();
            // print("Pan start ${node.label} $pos");
          },
          onPanEnd: (DragEndDetails details) {
            // print("Pan end ${node.label} $details");
            node.pressed = false;
            widget.graph.notify();
          },
          onPanUpdate: (details) {
            var pos = _getLocationPosition(details.globalPosition);
            node.x = pos.dx;
            node.y = pos.dy;

            if (node.y <= nodeSize / 2) {
              node.y = nodeSize / 2;
            }
            if (node.x <= nodeSize / 2) {
              node.x = nodeSize / 2;
            }

            widget.graph.notify();
            // print("Pan update ${node.label} $pos");
          },
        ),
        left: node.x - (nodeSize / 2),
        top: node.y - (nodeSize / 2),
        width: nodeSize,
      );
      children.add(w);
    }

    var view = Container(
      width: 2500,
      height: 2500,
      child: Stack(
        children: children,
        fit: StackFit.expand,
      ),
    );

    return InteractiveViewerCopy(
      child: view,
      panEnabled: true,
      constrained: false,
    );
  }
}

class GraphEdgePainter extends CustomPainter {
  final Graph graph;

  GraphEdgePainter(this.graph) : super(repaint: graph);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw all the edges
    for (var edge in graph.edges) {
      var strokeWitdth = 2.5;
      if (edge.a.pressed || edge.b.pressed) {
        strokeWitdth *= 2;
      }

      canvas.drawLine(
        Offset(edge.a.x, edge.a.y),
        Offset(edge.b.x, edge.b.y),
        Paint()
          ..color = Colors.green
          ..strokeWidth = strokeWitdth,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class NodeWidget extends StatelessWidget {
  final Node node;
  final double size;

  NodeWidget(this.node, this.size);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var textStyle = theme.textTheme.subtitle1.copyWith(fontSize: 8.0);

    var label = node.label;
    if (label.startsWith('docs/')) {
      label = label.substring(5);
    }
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.orange,
            shape: BoxShape.circle,
            border: Border.all(
              width: 1,
              color: Colors.black,
              style: BorderStyle.solid,
            ),
          ),
        ),
        Text(label, style: textStyle),
      ],
      crossAxisAlignment: CrossAxisAlignment.center,
    );
  }
}
