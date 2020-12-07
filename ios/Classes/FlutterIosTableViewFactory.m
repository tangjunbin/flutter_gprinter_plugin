//
//  FlutterIosTableViewFactory.m
//  gp_plugin
//
//  Created by 唐君彬 on 2020/11/14.
//

#import "FlutterIosTableViewFactory.h"
#import "FlutterIosTableView.h"

@implementation FlutterIosTableViewFactory{
     NSObject<FlutterBinaryMessenger>*_messenger;
}
- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger> *)messager{
    self = [super init];
    if (self) {
        _messenger = messager;
    }
    return self;
}

//设置参数的编码方式
-(NSObject<FlutterMessageCodec> *)createArgsCodec{
    return [FlutterStandardMessageCodec sharedInstance];
}

//用来创建 ios 原生view
- (nonnull NSObject<FlutterPlatformView> *)createWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id _Nullable)args {
    //args 为flutter 传过来的参数
    FlutterIosTableView *tableview = [[FlutterIosTableView alloc] initWithWithFrame:frame viewIdentifier:viewId arguments:args binaryMessenger:_messenger ];

    return tableview;
}

@end
