//
//  IflyRecognizer.h
//  SpeechTextEditor
//
//  Created by 王乙飞 on 2017/6/6.
//  Copyright © 2017年 王乙飞. All rights reserved.
//

#ifndef IflyRecognizer_h
#define IflyRecognizer_h

#import <Foundation/Foundation.h>

@interface IATConfig : NSObject

+(IATConfig *)sharedInstance;


+(NSString *)mandarin;
+(NSString *)cantonese;
+(NSString *)sichuanese;
+(NSString *)chinese;
+(NSString *)english;
+(NSString *)lowSampleRate;
+(NSString *)highSampleRate;
+(NSString *)isDot;
+(NSString *)noDot;


/**
 以下参数，需要通过
 iFlySpeechRecgonizer
 进行设置
 ****/
@property (nonatomic, strong) NSString *speechTimeout;
@property (nonatomic, strong) NSString *vadEos;
@property (nonatomic, strong) NSString *vadBos;

@property (nonatomic, strong) NSString *language;
@property (nonatomic, strong) NSString *accent;

@property (nonatomic, strong) NSString *dot;
@property (nonatomic, strong) NSString *sampleRate;

//无关参数
@property (nonatomic, assign) BOOL haveView;
@property (nonatomic, strong) NSArray *accentIdentifer;
@property (nonatomic, strong) NSArray *accentNickName;

@end

#endif /* IflyRecognizer_h */
