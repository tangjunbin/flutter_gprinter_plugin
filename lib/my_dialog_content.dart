part of gp_plugin;

class MyDialogContent extends StatefulWidget {
  final List<String> cuntries;
  final String jsonString;
  MyDialogContent({Key key, this.cuntries, this.jsonString}) : super(key: key);
  @override
  _MyDialogContentState createState() => _MyDialogContentState();
}

class _MyDialogContentState extends State<MyDialogContent> {
  bool _loading = true;
  String _msg = "检测打印机中";
  int _step = 0;
  List<BlueTooth> _blueToothList;
  String _address;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.delayed(Duration(seconds: 1), () async {
      // 获取已配对蓝牙列表
      if (defaultTargetPlatform == TargetPlatform.android) {
        _blueToothList = await GpPlugin.blueToothList();
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        //Todo 连接指定的蓝牙外设 还有问题
        // final Map<String,dynamic> res = await GpPlugin.OpenPort("CE2D81A7-2F56-FDBA-55D9-EB66F978E7AB");
        // print(res);
        // print("---123123-----");
      }
      Map<String, dynamic> res = await GpPlugin.myPrint(widget.jsonString);
      print("---------");
      print(res);
      // Map<String,dynamic> sss = await GpPlugin.print("DC:1D:30:8A:12:04");
      if (res['code'] == "1") {
        setState(() {
          _step = 1;
          _loading = false;
          // _msg = "未连接蓝牙打印机${GpPlugin.sssc}";
          _msg = "未连接蓝牙打印机";
        });
      }
    });
  }

  ///生成card内容
  Widget _buildContent() {
    switch (_step) {
      case 0:
        return _alertContent(_loadingContent());
        break;
      case 1:
        return _alertContent(_noblueToothContent());
        break;
      case 88:
        return _alertContent(_completePrintContent());
        break;
      case 2:
        if (defaultTargetPlatform == TargetPlatform.android) {
          return _listContent(_blueToothListContent());
        } else if (defaultTargetPlatform == TargetPlatform.iOS) {
          return _alertContent(Container(
            height: 400,
            width: MediaQuery.of(context).size.width,
            color: Colors.pinkAccent,
            child: UiKitView(
              //设置标识
              viewType: "com.gh.gpprinter/tableView",
            ),
          ));
        }

        break;
    }
  }

  Widget _alertContent(Widget widget) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            child: Card(
              color: Colors.white,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              child: Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      height: 180,
                      width: MediaQuery.of(context).size.width,
                      child: widget,
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  ///列表
  Widget _listContent(Widget widget) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            child: Card(
              color: Colors.white,
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      height: 400,
                      width: MediaQuery.of(context).size.width,
                      child: widget,
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  ///组合内容（检测打印机中）
  Widget _loadingContent() {
    return new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _buildCircular(),
        _buildText(),
      ],
    );
  }

  ///组合内容（未连接蓝牙）
  Widget _noblueToothContent() {
    return new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        RaisedButton(
            child: Text("点击连接蓝牙"),
            onPressed: () {
              setState(() {
                _step = 2;
              });
            }),
        _buildSampleText(),
      ],
    );
  }

  Widget _completePrintContent() {
    return new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        RaisedButton(
            child: Text(_msg),
            onPressed: () {
              Navigator.pop(context);
            }),
        _buildSampleText(),
      ],
    );
  }

  ///组合内容（蓝牙列表）
  Widget _blueToothListContent() {
    return ListView.builder(
      //元素数量
      itemCount: _blueToothList.length,
      itemBuilder: (context, index) {
        BlueTooth item = _blueToothList[index];
        return Container(
          decoration: new BoxDecoration(
              border: Border(
                  top: BorderSide(color: new Color(0xFF000000), width: 1))
//              image: new DecorationImage(image: new NetworkImage(imgUrl))
              ),
          child: ListTile(
            title: Text("${item.name}"),
            subtitle: Text("${item.address}"),
            onTap: () async {
              setState(() {
                _step = 0;
                _loading = true;
                _msg = '连接中...';
              });
              Map<String, dynamic> res = await GpPlugin.OpenPort(item.address);
            },
          ),
        );
      },
    );
  }

  ///组合内容（打印中）
  Widget _buildCircular() {
    if (_loading) {
      return new CircularProgressIndicator();
    } else {
      return new Container();
    }
  }

  Widget _buildText() {
    if (_loading) {
      return new Padding(
        padding: const EdgeInsets.only(
          top: 20.0,
        ),
        child: new Text(
          _msg,
          style: new TextStyle(fontSize: 12.0),
        ),
      );
    } else {
      return new Text(
        _msg,
        style: new TextStyle(fontSize: 14.0),
      );
    }
  }

  Widget _buildSampleText() {
    return new Text(
      _msg,
      style: new TextStyle(fontSize: 14.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    GpPlugin.bus.on("printStatus", (arg) {
      int code = 0;
      if(defaultTargetPlatform == TargetPlatform.android){
        code = arg['code'];
      }else{
        code = int.parse(arg['code']);
      }
      try {
        if (code == 0) {
          setState(() {
            _loading = true;
            _msg = arg['msg'] as String;
          });
        } else if (code == 88) {
          //打印完成
          setState(() {
            _loading = false;
            _msg = arg['msg'] as String;
            _step = 88;
          });
        }else {
          setState(() {
            _step = 88;
            _loading = false;
            _msg = arg['msg'] as String;
          });
        }
      } catch (e) {
        print(e.toString());
        print("原生回传事件处理异常-=-----");
      }
    });

    GpPlugin.bus.on("connectStatus", (arg) {
      setState(() {
        if (arg['value'] == "connecting") {
          _step = 0;
          _loading = true;
          _msg = arg['value'] as String;
        } else {
          _step = 88;
          _loading = false;
          _msg = arg['value'] as String;
        }
      });
    });

    return _buildContent();
  }
}
