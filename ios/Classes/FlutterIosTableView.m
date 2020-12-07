//
//  FlutterIosTextLabel.m
//  gp_plugin
//
//  Created by 唐君彬 on 2020/11/13.
//

#import "FlutterIosTableView.h"
#import "ConnecterManager.h"
#import "EventStreamHandler.h"


@interface FlutterIosTableView ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *deviceList;
@property (weak, nonatomic) IBOutlet UILabel *connectStatusLabel;
@property (weak, nonatomic) IBOutlet UIButton *disconnectBtn;
@property(nonatomic,strong)NSMutableArray *devices;
@property(nonatomic,strong)NSMutableDictionary *dicts;
@property (weak, nonatomic) IBOutlet UITextField *ipTextField;
@property (weak, nonatomic) IBOutlet UITextField *portTextField;


@end


@implementation FlutterIosTableView{
    //FlutterIosTableView 创建后的标识
    int64_t _viewId;
//    UILabel * _uiLabel;
    UITableView *_uiTableView;
    //消息回调
    FlutterMethodChannel* _channel;
}

//在这里只是创建了一个UILabel
-(instancetype)initWithWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args binaryMessenger:(NSObject<FlutterBinaryMessenger> *)messenger{
    if ([super init]) {
        if (frame.size.width==0) {
            frame=CGRectMake(frame.origin.x, frame.origin.y, [UIScreen mainScreen].bounds.size.width, 22);
        }
        _uiTableView =[[UITableView alloc] initWithFrame:frame];
        _uiTableView.dataSource = self;
        _uiTableView.delegate = self;
        
        [self getBlueList];//扫描外设蓝牙
        _viewId = viewId;
    
    }
    return self;
    
}



- (nonnull UIView *)view {
    return _uiTableView;
}

-(NSMutableArray *)devices {
    if (!_devices) {
        _devices = [[NSMutableArray alloc]init];
    }
    return _devices;
}

-(NSMutableDictionary *)dicts {
    if (!_dicts) {
        _dicts = [[NSMutableDictionary alloc]init];
    }
    return _dicts;
}
///拉取设备列表信息 初始化视图
-(void)getBlueList {
    
    [Manager stopScan];
    NSLog(@"start get Blue List=======");
    if (Manager.bleConnecter == nil) {
        __weak __typeof(self)weakSelf = self;
        [Manager didUpdateState:^(NSInteger state) {
             __strong __typeof(weakSelf)strongSelf = weakSelf;
            switch (state) {
                case CBManagerStateUnsupported:
                    NSLog(@"The platform/hardware doesn't support Bluetooth Low Energy.");
                    break;
                case CBManagerStateUnauthorized:
                    NSLog(@"The app is not authorized to use Bluetooth Low Energy.");
                    break;
                case CBManagerStatePoweredOff:
                    // 未连接
                    [Manager stopScan];
                    [Manager setIsConnected:NO];
                    [strongSelf.deviceList reloadData];
                    NSLog(@"Bluetooth is currently powered off.");
                    break;
                case CBManagerStatePoweredOn:
                    [strongSelf startScane];
                    NSLog(@"Bluetooth power on");
                    break;
                case CBManagerStateUnknown:
                default:
                    break;
            }
        }];
    } else {
        [self startScane];
    }
}

// 开始搜索 扫描 可用蓝牙设备
-(void)startScane {
    __weak __typeof(self)weakSelf = self;
    [Manager scanForPeripheralsWithServices:nil options:nil discover:^(CBPeripheral * _Nullable peripheral, NSDictionary<NSString *,id> * _Nullable advertisementData, NSNumber * _Nullable RSSI) {
        
        if (peripheral.name != nil) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            
            NSUInteger oldCounts = [strongSelf.dicts count];
            
            
            [strongSelf.dicts setObject:peripheral forKey:peripheral.identifier.UUIDString];
            
            
            //NSLog(@"name -> %@ uuid -> %@ %d %d",peripheral.name,peripheral.identifier.UUIDString,oldCounts,[strongSelf.dicts count]);
            
            
            
            if (oldCounts < [strongSelf.dicts count]) {
                [_uiTableView reloadData];
                [strongSelf.deviceList reloadData];
            }
        }
    }];
}


#pragma mark - tableView datasource and delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.f;
}

// 设置区间的头部
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.frame = CGRectMake(0, 0, self.view.frame.size.width, 40);
    view.backgroundColor = [UIColor whiteColor];
    
    UILabel *topLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,0,300,30)];
    topLabel.text = @"蓝牙设备列表";
    topLabel.textColor = [UIColor blueColor];
    topLabel.font = [UIFont boldSystemFontOfSize:16.f];
    [view addSubview:topLabel];
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[self.dicts allKeys]count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    CBPeripheral *peripheral = [self.dicts objectForKey:[self.dicts allKeys][indexPath.row]];
    cell.textLabel.text = peripheral.name;
    
    cell.detailTextLabel.text = peripheral.identifier.UUIDString;
    return cell;
}
#pragma mark - Notificat & monitor
///点击tableview cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if([Manager isConnected]){
//        [SVProgressHUD showSuccessWithStatus:@"请先断开当前设备"];
        NSLog(@"请先断开当前设备");
        StreamHandler.eventSink(@{@"event":@"connectStatus",@"value":@"error",@"msg":@"请先断开当前设备"});
        return;
    }
    CBPeripheral *peripheral = [self.dicts objectForKey:[self.dicts allKeys][indexPath.row]];
    [self connectDevice:peripheral];
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
                StreamHandler.eventSink(@{@"event":@"connectStatus",@"value":@"connectsuccess"});
//                strongSelf.connectStatusLabel.text = [NSString stringWithFormat:@"连接成功：%@",peripheral.name];
//                strongSelf.disconnectBtn.hidden = NO;
//                [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"deviceConnectSuccess" object:nil userInfo:nil]];
        
                [_uiTableView reloadData];
//                [self.navigationController popViewControllerAnimated:YES];
                break;
            case CONNECT_STATE_CONNECTING:
                StreamHandler.eventSink(@{@"event":@"connectStatus",@"value":@"connecting"});
                NSLog(@"////连接中....");
                break;
            default:
                StreamHandler.eventSink(@{@"event":@"connectStatus",@"value":@"connectfail"});
                NSLog(@"/////连接失败");
                Manager.isConnected = NO;
                strongSelf.connectStatusLabel.text = @"未连接";
                strongSelf.disconnectBtn.hidden = YES;
                //[SVProgressHUD showErrorWithStatus:@"当前设备已断开，请尝试重新连接"];
                 [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"deviceDisconnect" object:nil userInfo:nil]];
                break;
        }
    }];
}
@end



