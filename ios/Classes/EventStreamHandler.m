//
//  EventStreamHandler.m
//  gp_plugin
//
//  Created by 唐君彬 on 2020/11/21. 
//
#import "EventStreamHandler.h"

@implementation EventStreamHandler

static EventStreamHandler *streamHandler;
static dispatch_once_t once;

+(instancetype)sharedInstance {
    dispatch_once(&once, ^{
        streamHandler = [[EventStreamHandler alloc]init];
    });
    return streamHandler;
}

#pragma mark - FlutterStreamHandler
- (FlutterError* _Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(FlutterEventSink)eventSink{
    NSLog(@"======>onListenWithArguments");
    self.eventSink = eventSink;
//    self.eventSink(@{@"event":@"demoEvent",@"value":@"xxxcvv"});
    return nil;
}
 
- (FlutterError* _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    return nil;
}


@end

