//
//  EventStreamHandler.h
//  gp_plugin
//
//  Created by 唐君彬 on 2020/11/21.
//

#import <Flutter/Flutter.h>


#define StreamHandler [EventStreamHandler sharedInstance]

@interface EventStreamHandler : NSObject<FlutterStreamHandler>
// 定义FlutterEventSink的缓存对象 
@property (nonatomic, strong) FlutterEventSink eventSink;


+(instancetype)sharedInstance;

@end
