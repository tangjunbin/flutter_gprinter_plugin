//
//  CPCLCommand.h
//  GPSDKDemo
//
//  Created by max on 2020/7/22.
//  Copyright © 2020 max. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// 字体枚举
typedef enum {
    FONT_00 = 0,
    FONT_01 = 1,
    FONT_02 = 2,
    FONT_03 = 3,
    FONT_04 = 4,
    FONT_05 = 5,
    FONT_06 = 6,
    FONT_07 = 7,
    FONT_08 = 8,
    FONT_010 = 10,
    FONT_011 = 11,
    FONT_013 = 13,
    FONT_020 = 20,
    FONT_024 = 24,
    FONT_041 = 41,
    FONT_042 = 42,
    FONT_043 = 43,
    FONT_044 = 44,
    FONT_045 = 45,
    FONT_046 = 46,
    FONT_047 = 47,
    FONT_048_00 = 48,
    FONT_048_01 = 48,
    FONT_055 = 55,
}TEXTFONT;

// 打印图片方式枚举
typedef NS_ENUM (NSUInteger,GRAPHICS){
    EXPANDED = 0,//横向打印扩展图形
    COMPRESSED = 1,//横向打印压缩图形
};

// 条码种类枚举
typedef NS_ENUM (NSUInteger,CPCLBARCODETYPE) {
    Code128=1,
    Upc_A = 2,
    Upc_E = 3,
    Ean13 = 4,
    Ean8 = 5,
    Code39 = 6,
    Code93 = 7,
    Codebar = 8,
};

// 速度枚举
typedef enum {
    SPEED00 = 0,
    SPEED01 = 1,
    SPEED02 = 2,
    SPEED03 = 3,
    SPEED04 = 4,
    SPEED05 = 5,
}CPCLSPEED;

// 字段的对齐方式枚举
typedef NS_ENUM (NSUInteger,ALIGNMENT) {
    CENTER = 0,
    LEFT = 1,
    RIGHT = 2,
};

// 字体指令枚举
typedef NS_ENUM (NSUInteger,TEXTCOMMAND) {
    T = 0,    // 横向打印文本。
    VT = 1,   // 逆时针旋转 90 度，纵向打印文本。
    T90 = 2,  // 同上
    T180 = 3, // 逆时针旋转 80 度，反转打印文本。
    T270 = 4, // 逆时针旋转 270 度，纵向打印文本。
};

// 宽窄比枚举
typedef enum {
    Point0 = 0,//1.5:1
    Point1 = 1,//2.0:1
    Point2 = 2,//2.5:1
    Point3 = 3,//3.0:1
    Point4 = 4,//3.5:1
    Point20 = 20,//2.0:1
    Point21 = 21,//2.1:1
    Point22 = 22,//2.2:1
    Point23 = 23,//2.3:1
    Point24 = 24,//2.4:1
    Point25 = 25,//2.5:1
    Point26 = 26,//2.6:1
    Point27 = 27,//2.7:1
    Point28 = 28,//2.8:1
    Point29 = 29,//2.9:1
    Point30 = 30,//3.0:1
}BARCODERATIO;//宽窄比

// 横向或纵向打印枚举
typedef NS_ENUM (NSUInteger,COMMAND){
    BARCODE = 0,
    VBARCODE = 1,
};

@interface CPCLCommand : NSObject

/**
 * 方法说明：初始化
 * @param offset 标签横向偏移量
 * @param height 标签最大高度
 * @param qty 打印标签的张数
 */
-(void)addInitializePrinterwithOffset:(int)offset withHeight:(int)height withQTY:(int)qty;

/**
 * 方法说明：打印标签
 */
-(void)addPrint;


/**
 * 方法说明:获得打印命令
 * @return NSData
 */
-(NSData*)getCommand;


/**
 * 方法说明：在标签上添加文本
 * @param type 指令
 * @param font 字体类型
 * @param x 横向起始位置
 * @param y 纵向起始位置
 * @param text 打印的文本
 */
-(void)addText:(TEXTCOMMAND)type withFont:(TEXTFONT)font withXstart:(int)x withYstart:(int)y withContent:(NSString*)text;


/**
 * 方法说明：将字体放大指定的放大倍数
 * @param w 宽度放大倍数，有效放大倍数为 1 到 16
 * @param h 高度放大倍数，有效放大倍数为 1 到 16
 */
-(void)addSetmagWithWidthScale:(int)w withHeightScale:(int)h;


/**
 * 方法说明：以指定的宽度和高度纵向和横向打印条码
 * @param command 横向或纵向打印
 * @param type 条码种类
 * @param width 条码窄条的单位宽度
 * @param ratio 条码宽条与窄条的比率
 * @param height  条码的单位高度
 * @param x 横向起始位置
 * @param y 纵向起始位置
 * @param text 条码内容
 */
-(void)addBarcode:(COMMAND)command withType:(CPCLBARCODETYPE)type withWidth:(int)width withRatio:(BARCODERATIO)ratio withHeight:(int)height withXstart:(int)x withYstart:(int)y withString:(NSString*)text;


/**
 * 方法说明：打印二维码
 * @param command 横向或纵向打印
 * @param x 横向起始位置
 * @param y 纵向起始位置
 * @param n QR Code 规范编号,1 或 2，默认推荐为 2
 * @param u 模块的单位宽度/单位高度 1-32，默认为 6
 * @param text 二维码内容
 */
-(void)addQrcode:(COMMAND)command withXstart:(int)x withYstart:(int)y with:(int)n with:(int)u withString:(NSString*)text;


/**
 * 方法说明：添加条码注释
 * @param font 注释条码时要使用的字体号
 * @param offset 文本距离条码的单位偏移量
 */
-(void)addBarcodeTextWithFont:(int)font withOffset:(int)offset;


/**
 * 方法说明：禁用条码注释
 */
-(void)addBarcodeTextOff;


/**
 * 方法说明：打印图片
 * @param command 指令
 * @param x 起始点的X 坐标
 * @param y 起始点的 Y 坐标
 * @param img 图片
 * @param maxWidth 最大宽度
 */
-(void)addGraphics:(GRAPHICS)command WithXstart:(int)x withYstart:(int)y withImage:(UIImage*)img withMaxWidth:(int)maxWidth;


/**
 * 方法说明：打印任何长度、宽度和角度方向的线条
 * @param x 起始点的X 坐标
 * @param y 起始点的 Y 坐标
 * @param xend 终止点的 X 坐标
 * @param yend 终止点的 Y 坐标
 * @param width 线条的单位宽度
 */
-(void)addLineWithXstart:(int)x withYstart:(int)y withXend:(int)xend withYend:(int)yend  withWidth:(int)width;


/**
 * 方法说明：打印指定线条宽度的矩形
 * @param x 左上角的X 坐标
 * @param y 左上角的 Y 坐标
 * @param xend 右下角的 X 坐标
 * @param yend 右下角的 Y 坐标
 * @param thickness 形成矩形框的线条的单位宽度
 */
-(void)addBoxWithXstart:(int)x  withYstart:(int)y withXend:(int)xend withYend:(int)yend  withThickness:(int)thickness;


/**
 * 方法说明：绘制反显区域，应先添加内容后再添加反显区域
 * @param x 起始点的X 坐标
 * @param y 起始点的 Y 坐标
 * @param xend  终止点的 X 坐标
 * @param yend 终止点的 Y 坐标
 * @param width 反色区域高度
 */
-(void)addInverseLineWithXstart:(int)x withYstart:(int)y withXend:(int)xend withYend:(int)yend  withWidth:(int)width;


/**
 * 方法说明：控制字段的对齐方式
 * @param align 对齐方式
 */
-(void)addJustification:(ALIGNMENT)align;


/**
 * 方法说明：设置打印宽度
 * @param width 页面的单位宽度
 */
-(void)addPagewidth:(int)width;


/**
 * 方法说明：设置打印速度
 * @param level 打印速度
 */
-(void)addSpeed:(CPCLSPEED)level;


/**
 * 方法说明：让蜂鸣器发出给定时间长度的声音
 * @param beep_length 蜂鸣持续时间，以 1/8 秒为单位递增
 */
-(void)addBeep:(int)beep_length;

/**
 * 方法说明:查询打印机状态
 */
-(void)queryPrinterStatus;


@end

