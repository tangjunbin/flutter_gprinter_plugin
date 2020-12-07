#import "GpPlugin.h"
#import "FlutterIosTableViewFactory.h"
#import "EventStreamHandler.h"
#import "ConnecterManager.h"
//#import "SVProgressHUD.h"
#import "TscCommand.h"
//#import "JSONKit.h"



@implementation GpPlugin


+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"com.gh.gpprinter"
            binaryMessenger:[registrar messenger]];
  GpPlugin* instance = [[GpPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];


    // 初始化FlutterEventChannel对象
    FlutterEventChannel* eventChannel = [FlutterEventChannel eventChannelWithName:@"com.gh.gpprinter/event" binaryMessenger:[registrar messenger]];
        
    [eventChannel setStreamHandler:StreamHandler];
    
    
    //注册组件
  [registrar registerViewFactory:[
      [FlutterIosTableViewFactory alloc]
        initWithMessenger:registrar.messenger]
        withId:@"com.gh.gpprinter/tableView"];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  }else if ([@"blueToothList" isEqualToString:call.method]){
      [self getBlueToothList:call];
  }else if([@"myPrint" isEqualToString:call.method]){
      if ([Manager isConnected] ) {
          NSLog(@"=======>打印机已经连接");
          [Manager write:[self doPrint:call] progress:^(NSUInteger total, NSUInteger progress) {
              CGFloat p = (CGFloat)progress / (CGFloat)total;
              NSLog(@"=======>发送中...%f",p);
              NSString *fString = [NSString stringWithFormat:@"%0.0f",p*100];
//              [SVProgressHUD showProgress:p status:@"发送中..."];
              StreamHandler.eventSink(@{@"event":@"printStatus",@"code":@"0",@"msg":[@"send " stringByAppendingString:fString ]});
              if(total - progress == 0) {
                  NSLog(@"发送完成");
                  StreamHandler.eventSink(@{@"event":@"printStatus",@"code":@"0",@"msg":@"send Success"});
//                  [SVProgressHUD dismiss];
              }
          } receCallBack:^(NSData * _Nullable data) {
              NSLog(@"返回打印机状态==%@",[self TSPLHexStringWithData:data]);
              NSString *msg = [NSString stringWithFormat:@"返回打印机状态==%@",[self TSPLHexStringWithData:data]];
              StreamHandler.eventSink(@{@"event":@"printStatus",@"code":@"88",@"msg":@"打印完成"});
//              [SVProgressHUD showInfoWithStatus:[self TSPLHexStringWithData:data]];
          }];
          result(@{@"code": @"0",
                  @"message": @"print success"});
      }else{
          NSLog(@"no connected");
          result(@{@"code": @"1",
                  @"message": @"no connected"});
      }
  }else if([@"openPort" isEqualToString:call.method]){
      NSDictionary *arg = call.arguments;
      NSString *serviceUUIDs =  arg[@"address"];

      [Manager scanForPeripheralsWithServices:serviceUUIDs options:nil discover:^(CBPeripheral * _Nullable peripheral, NSDictionary<NSString *,id> * _Nullable advertisementData, NSNumber * _Nullable RSSI) {
              NSLog(@"name -> %@ uuid -> %@",peripheral.name,peripheral.identifier.UUIDString);
      }];
//      CBPeripheral *peripheral = [CBPeripheral alloc];
//      
//      [peripheral identifier:address];
//      [self connectDevice:peripheral];
  }else {
    result(FlutterMethodNotImplemented);
  }
}

#pragma mark
-(NSData *)doPrint:(FlutterMethodCall*)call {
    NSDictionary *arg = call.arguments;
    NSString *jsonString =  arg[@"data"];
    NSLog(@"打印data======>%@",jsonString);
    //将字符串写到缓冲区。
    NSData* jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary* jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    if (error)
    {
        NSLog(@"json解析失败：%@", error);
        return nil;
    }

    NSDictionary* size = [jsonDic objectForKey:@"size"];
    NSString* width = [size objectForKey:@"width"];
    NSString* height = [size objectForKey:@"height"];
    NSString* gap = [jsonDic objectForKey:@"gap"];

    int sizet= 8;
    TscCommand *command = [[TscCommand alloc]init];
    [command addSize:[width integerValue] :[height integerValue]];
    [command addGapWithM:[gap integerValue] withN:0];
    [command addReference:0 :0];
    [command addTear:@"ON"];
    [command addQueryPrinterStatus:ON];
    [command addCls];

    NSArray* itemArr = [jsonDic objectForKey:@"items"];
    
//    [command addTextwithX:(48-(24*2*6)/8)/2*sizet withY:10*sizet withFont:@"TSS24.BF2" withRotation:0 withXscal:1 withYscal:1 withText:@"佳博科技  5/7"];
    for(NSInteger i=0;i<itemArr.count;i++){
        NSDictionary* label = [itemArr objectAtIndex:i];
        NSString* x = [label objectForKey:@"x"];
        NSString* y = [label objectForKey:@"y"];
        NSString* type = [label objectForKey:@"type"];

        if([type isEqualToString:@"text"]){
            NSString* textC = [label objectForKey:@"value"];
            [command addTextwithX:[x integerValue] withY:[y integerValue] withFont:@"TSS24.BF2" withRotation:0 withXscal:1 withYscal:1 withText:textC];
        }else if ( [type isEqualToString:@"image"]){
            UIImage* printLog = [UIImage imageNamed:@"printlogo.jpg"];
            [command addBitmapwithX:[x integerValue] withY:[y integerValue] withMode:0 withWidth:80 withImage:printLog];
            
        }else if ([type isEqualToString:@"QRCode"]){
            NSString* celW = [label objectForKey:@"cellwidth"];
            NSString* qrdata = [label objectForKey:@"data"];
            [command addQRCode:[x integerValue] :[y integerValue] :@"L" :[celW integerValue] :@"A" :0 :qrdata];
        }
    }


    //测试数据
//    int size= 8;
//    int gap = 2;
//    TscCommand *command = [[TscCommand alloc]init];
//    [command addSize:48 :35];
//    [command addGapWithM:gap withN:0];
//    [command addReference:0 :0];
//    [command addTear:@"ON"];
//    [command addQueryPrinterStatus:ON];
//    [command addCls];
//    [command addTextwithX:(48-(24*2*6)/8)/2*sizet withY:10*sizet withFont:@"TSS24.BF2" withRotation:0 withXscal:1 withYscal:1 withText:@"佳博科技  5/7"];
//    [command addTextwithX:(48-(32*3)/8)/2*sizet withY:17*sizet withFont:@"5" withRotation:0 withXscal:1 withYscal:1 withText:@"1-10-03"];
    [command addPrint:1 :1];
    [command queryPrinterStatus]; // 添加该指令可返回打印机状态，若不需要则屏蔽
    
    return [command getCommand];
    
}

- (void)getBlueToothList:(FlutterMethodCall*)call {
    
    __weak __typeof(self)weakSelf = self;
    [Manager scanForPeripheralsWithServices:nil options:nil discover:^(CBPeripheral * _Nullable peripheral, NSDictionary<NSString *,id> * _Nullable advertisementData, NSNumber * _Nullable RSSI) {
              NSLog(@"name -> %@ uuid -> %@",peripheral.name,peripheral.identifier.UUIDString);
//        __strong __typeof(weakSelf)strongSelf = weakSelf;
//        strongSelf.eventSink(@"=========传回去呀");
      }];
}

//连接设备
-(void)connectDevice:(CBPeripheral *)peripheral {
    NSLog(@"peripheral -> %@",peripheral.name);
    __weak __typeof(self)weakSelf = self;
    Manager.currentConnMethod = BLUETOOTH;
   
    [Manager connectPeripheral:peripheral options:nil timeout:2 connectBlack:^(ConnectState state) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        switch (state) {
            case CONNECT_STATE_CONNECTED:
                NSLog(@"/////连接成功");
                Manager.isConnected = YES;
                Manager.UUIDString = peripheral.identifier.UUIDString;
//                [SVProgressHUD showSuccessWithStatus:@"连接成功"];
//                strongSelf.connectStatusLabel.text = [NSString stringWithFormat:@"连接成功：%@",peripheral.name];
//                strongSelf.disconnectBtn.hidden = NO;
                [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"deviceConnectSuccess" object:nil userInfo:nil]];
//                [strongSelf.deviceList reloadData];
//                [_uiTableView reloadData];
//                [self.navigationController popViewControllerAnimated:YES];
                break;
            case CONNECT_STATE_CONNECTING:
                NSLog(@"////连接中....");
                break;
            default:
                NSLog(@"/////连接失败");
                Manager.isConnected = NO;
//                strongSelf.connectStatusLabel.text = @"未连接";
//                strongSelf.disconnectBtn.hidden = YES;
//                [SVProgressHUD showErrorWithStatus:@"当前设备已断开，请尝试重新连接"];
                 [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"deviceDisconnect" object:nil userInfo:nil]];
                break;
        }
    }];
}
#pragma mark - tool
-(NSString *)TSPLHexStringWithData:(NSData *)data{
    Byte *bytes = (Byte *)[data bytes];
    NSString *hexStr=@"";
    for(int i=0;i<[data length];i++) {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];
        if([newHexStr length]==1){
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        }
        else{
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
        }
    }
    hexStr = [hexStr uppercaseString];
    
    NSDictionary *dic = @{
        @"00":@"正常待机",
        @"01":@"开盖",
        @"02":@"卡纸",
        @"03":@"卡纸、开盖",
        @"04":@"缺纸",
        @"05":@"确知、开盖",
        @"08":@"无碳带",
        @"09":@"无碳带、开盖",
        @"0A":@"无碳带、卡纸",
        @"0B":@"无碳带、卡纸、开盖",
        @"0C":@"无碳带、缺纸",
        @"0D":@"无碳带、缺纸、开盖",
        @"10":@"暂停打印",
        @"20":@"正在打印",
        @"41":@"盖子未关闭",
        @"80":@"其他错误",
        
    };
    return ([dic valueForKey:hexStr]) ? [dic valueForKey:hexStr] : @"其他错误";
}

@end
