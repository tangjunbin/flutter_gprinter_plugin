part of gp_plugin;

typedef void TextViewCreatedCallback(TextViewController controller);

///flutter 显示原生view(暂时用不到)
class GpPrinter extends StatefulWidget {

  final TextViewCreatedCallback onTextViewCreated;
  const GpPrinter({
    Key key,
    this.onTextViewCreated,
  });
  @override
  _GpPrinterState createState() => _GpPrinterState();
}

class _GpPrinterState extends State<GpPrinter> {

  _GpPrinterState({this.text});

  final String text;

  @override
  Widget build(BuildContext context) {

    if(defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: "com.gh.gpprinter/textview",
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else if(defaultTargetPlatform == TargetPlatform.iOS){
      ///返回scan外设列表
      return UiKitView(
        //设置标识
        viewType: "com.gh.gpprinter/tableView",
      );
    } else {
      print("不支持当前平台");
      return Container();
    }
  }
  Future<void> _onPlatformViewCreated(int id) async {
    if (widget.onTextViewCreated == null) {
      return;
    }
    widget.onTextViewCreated(new TextViewController._(id));
  }
}



class TextViewController {
  TextViewController._(int id)
      : _channel = new MethodChannel('com.gh.gpprinter/textview_$id');

  final MethodChannel _channel;

  Future<void> setText(String text) async {
    assert(text != null);
    return _channel.invokeMethod('setText', text);
  }
}
