//
//  ConnecterManager.h
//  GPSDKDemo
//
//  Created by max on 2020/7/22.
//  Copyright © 2020 max. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLEConnecter.h"
#import "EthernetConnecter.h"
#import "Connecter.h"

/**
 *  @enum ConnectMethod
 *  @discussion 连接方式
 *  @constant BLUETOOTH 蓝牙连接
 *  @constant ETHERNET 网口连接（wifi连接）
 */
typedef enum : NSUInteger{
    BLUETOOTH,
    ETHERNET
}ConnectMethod;

/**
 *  @enum CommandType
 *  @discussion 指令类型
 *  @constant UNKNOWN 未知
 *  @constant ESC 票据模式
 *  @constant TSC 标签模式
 */
typedef enum :NSUInteger{
    UNKNOWN,
    ESC,
    TSC,
    CPCL
}CommandType;

#define Manager [ConnecterManager sharedInstance]

@interface ConnecterManager : NSObject
@property(nonatomic,strong)BLEConnecter * bleConnecter;
@property(nonatomic,strong)EthernetConnecter *ethernetConnecter;
@property(nonatomic,strong)Connecter *connecter;
@property(nonatomic,assign)BOOL isConnected;
@property(nonatomic,copy)ConnectDeviceState state;
@property(nonatomic,strong)NSString *UUIDString;

@property(nonatomic,assign)ConnectMethod currentConnMethod;
@property(nonatomic,assign)CommandType type;
@property(nonatomic,copy)UpdateState updateCenterBluetoothState;
@property(nonatomic,strong)CBPeripheral *peripheral;

+(instancetype)sharedInstance;

/**
 *  方法说明：连接指定ip和端口号的网络设备
 *  @param ip 设备的ip地址
 *  @param port 设备端口号
 *  @param connectState 连接状态
 *  @param callback 读取数据接口
 */
-(void)connectIP:(NSString *)ip port:(int)port connectState:(void (^)(ConnectState state))connectState callback:(void (^)(NSData *data))callback;

/**
 *  方法说明：关闭连接
 */
-(void)close;

/**
 *  方法说明: 向输出流中写入数据（只适用于蓝牙）
 *  @param data 需要写入的数据
 *  @param progress 写入数据进度
 *  @param callBack 读取输入流中的数据
 */
-(void)write:(NSData *_Nullable)data progress:(void(^_Nullable)(NSUInteger total,NSUInteger progress))progress receCallBack:(void (^_Nullable)(NSData *_Nullable))callBack;

/**
 *  方法说明：向输出流中写入数据
 *  @param callBack 读取数据接口
 */
-(void)write:(NSData *)data receCallBack:(void (^)(NSData *))callBack;

/**
 *  方法说明：向输出流中写入数据
 *  @param data 需要写入的数据
 */
-(void)write:(NSData *)data;

/**
 *  方法说明：停止扫描
 */
-(void)stopScan;

/**
 *  方法说明：更新蓝牙状态
 *  @param state 蓝牙状态
 */
-(void)didUpdateState:(void(^)(NSInteger state))state;

/**
 *  方法说明：连接外设
 *  @param peripheral 需连接的外设
 *  @param options 其它可选操作
 *  @param timeout 连接时间
 *  @param connectState 连接状态
 */
-(void)connectPeripheral:(CBPeripheral *)peripheral options:(nullable NSDictionary<NSString *,id> *)options timeout:(NSUInteger)timeout connectBlack:(void(^_Nullable)(ConnectState state)) connectState;

/**
 *  方法说明：连接外设
 *  @param peripheral 需连接的外设
 *  @param options 其它可选操作
 */
-(void)connectPeripheral:(CBPeripheral * _Nullable)peripheral options:(nullable NSDictionary<NSString *,id> *)options;

/**
 *  方法说明：扫描外设
 *  @param serviceUUIDs 需要发现外设的UUID，设置为nil则发现周围所有外设
 *  @param options  其它可选操作
 *  @param discover 发现的设备
 */
-(void)scanForPeripheralsWithServices:(nullable NSArray<CBUUID *> *)serviceUUIDs options:(nullable NSDictionary<NSString *, id> *)options discover:(void(^_Nullable)(CBPeripheral *_Nullable peripheral,NSDictionary<NSString *, id> *_Nullable advertisementData,NSNumber *_Nullable RSSI))discover;

@end
