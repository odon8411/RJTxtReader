//
//  txtFileHeaderCodeC.h
//  RJTxtReader
//
//  Created by xian zhu on 12-11-1.
//  Copyright (c) 2012年 z. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIkit.h>
#include <stdio.h>

typedef enum {
    CODETYPE_DEFAULT   =0,
	CODETYPE_UNICODE,
	CODETYPE_GBK
}CODETYPE;
// 判断Txt编码类型
CODETYPE GetTxtFileCodeType(const char* pFileName);

@interface txtFileHeaderCodeC : NSObject


+ (txtFileHeaderCodeC*)getInstance;
- (CODETYPE)GetTxtFileCodeType:(NSString *)pchFileName;
@end
