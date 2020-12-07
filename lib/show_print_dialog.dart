part of gp_plugin;

class ShowPrintDialog extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final String jsonString;
  ShowPrintDialog({
    @required this.jsonString,
    @required this.child,
    @required this.onPressed,
  });
  @override
  _ShowPrintDialogState createState() => _ShowPrintDialogState();
}

class _ShowPrintDialogState extends State<ShowPrintDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      child: widget.child,
      onPressed: () {
        _showMangerDialog(context);
        // 延时1s执行返回
        if (widget.onPressed != null) {
          widget.onPressed();
        }
      },
    );
  }

  _showMangerDialog(BuildContext context) {
    showDialog<void>(
        barrierDismissible: false,
        // 传入 context
        context: context,
        // 构建 Dialog 的视图
        builder: (BuildContext context) {
          return MyDialogContent(
            jsonString: widget.jsonString,
          );
        });
  }
}
