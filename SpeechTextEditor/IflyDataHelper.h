//
//  IflyDataHelper.h
//  SpeechTextEditor
//
//  Created by 王乙飞 on 2017/6/6.
//  Copyright © 2017年 王乙飞. All rights reserved.
//

#ifndef IflyDataHelper_h
#define IflyDataHelper_h
#import <Foundation/Foundation.h>

@interface ISRDataHelper : NSObject

// 解析命令词返回的结果
+ (NSString*)stringFromAsr:(NSString*)params;

// 解析JSON数据
+ (NSString *)stringFromJson:(NSString*)params;


// 解析语法识别返回的结果
+ (NSString *)stringFromABNFJson:(NSString*)params;

@end

#endif /* IflyDataHelper_h */
