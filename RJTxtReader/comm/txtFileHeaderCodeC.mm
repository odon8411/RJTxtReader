//
//  txtFileHeaderCodeC.m
//  RJTxtReader
//
//  Created by xian zhu on 12-11-1.
//  Copyright (c) 2012年 z. All rights reserved.
//

#import "txtFileHeaderCodeC.h"


CODETYPE GetTxtFileCodeType(const char* pchFileName)
{
    FILE* fpamr = NULL;
	char magic[8];
	fpamr = fopen(pchFileName, "rb");
    if ( fpamr==NULL ) 
		return CODETYPE_DEFAULT;
    // 检查amr文件头
	fread(magic, sizeof(char), strlen(magic), fpamr);
    
    fclose(fpamr);
    if(magic[0]==0xFF && magic[1] == 0xFE)
        return CODETYPE_UNICODE;
    else
        return CODETYPE_GBK;
    return CODETYPE_DEFAULT;

}
@implementation txtFileHeaderCodeC

static txtFileHeaderCodeC* kOnlyOne = nil;
+ (txtFileHeaderCodeC*)getInstance
{
	if (kOnlyOne == nil) {
		kOnlyOne = [[txtFileHeaderCodeC alloc] init];
	}
	return kOnlyOne;
}

- (CODETYPE)GetTxtFileCodeType:(NSString *)pchFileName
{
	return GetTxtFileCodeType([pchFileName UTF8String]);
	
}


@end
