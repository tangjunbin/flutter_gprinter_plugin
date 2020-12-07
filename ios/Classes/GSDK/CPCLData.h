//
//  CPCLData.h
//  GPSDKDemo
//
//  Created by max on 2020/7/23.
//  Copyright © 2020 max. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BitmapImage : NSObject
@property(nonatomic,strong)NSData* bitmap;
@property(nonatomic,assign)NSInteger width;
@property(nonatomic,assign)NSInteger height;
@end

@interface CPCLData : NSObject
@property(nonatomic,assign)NSInteger w;
@property(nonatomic,assign)NSInteger h;
- (id)initWithUIImage:(UIImage *)image maxWidth:(int)maxWidth;
-(NSData *)printCPCLData;
@end
