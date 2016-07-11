//
//  M3U8Handler.m
//  M3U8Demo
//
//  Created by AdminZhiHua on 16/5/13.
//  Copyright © 2016年 AdminZhiHua. All rights reserved.
//

#import "M3U8Handler.h"

@interface M3U8Handler ()

@end

@implementation M3U8Handler

- (instancetype)init {
    if (self = [super init]) {
        self.segments = [NSMutableArray array];
    }
    return self;
}

- (void)praseM3U8With:(NSURL *)url handlerDelegate:(id<M3U8HandlerDelegate>)delegate {
    
    self.delegate = delegate;
    
    self.urlString = url.absoluteString;
    
    NSError *error;
    NSStringEncoding encoding;
    
    NSString *dataString = [[NSString alloc] initWithContentsOfURL:url usedEncoding:&encoding error:&error];
    
    //获取m3u8的内容出错
    if (error) {
        if ([self.delegate respondsToSelector:@selector(M3U8Handler:praseError:)]) {
            [self.delegate M3U8Handler:self praseError:error];
        }
        return;
    }
    
    //判断m3u8的内容是否正确
    NSRange range = [dataString rangeOfString:@"#EXTINF"];
    
    if (range.location == NSNotFound) {
        if ([self.delegate respondsToSelector:@selector(M3U8Handler:praseError:)]) {
            //定义格式错误
            NSError *formatError = [[NSError alloc] initWithDomain:@"NSDataFormateError" code:8888 userInfo:@{@"info":@"数据格式错误"}];
            [self.delegate M3U8Handler:self praseError:formatError];
        }
        return;
    }
    
    NSURL *baseUrl = [url URLByDeletingLastPathComponent];
    
    [self tsInfoWithM3U8String:dataString baseUrlStr:baseUrl.absoluteString];
    
    //解析完成
    if ([self.delegate respondsToSelector:@selector(praseM3U8InfoFinish:)]) {
        [self.delegate praseM3U8InfoFinish:self];
    }
}

//获取ts信息
- (void)tsInfoWithM3U8String:(NSString *)m3u8Str baseUrlStr:(NSString *)baseUrlStr {
    
    NSArray *components = [m3u8Str componentsSeparatedByString:@"\n"];
    
    NSMutableArray *durations = [NSMutableArray array];
    NSMutableArray *urlArray = [NSMutableArray array];
    
    for (NSString *infoString in components) {
        
        NSRange durationRange = [infoString rangeOfString:@"#EXTINF:"];
        NSRange tsRange = [infoString rangeOfString:@".ts"];
        
        if (durationRange.location != NSNotFound) {
            NSString *durationStr = [infoString substringFromIndex:durationRange.length];
            [durations addObject:durationStr];
        }
        else if (tsRange.location != NSNotFound) {
            [urlArray addObject:infoString];
        }
    }
    
    for (int i = 0; i<durations.count; i++) {
        NSString *durationStr = durations[i];
        NSString *tsURL = urlArray[i];
        
        tsURL = [baseUrlStr stringByAppendingString:tsURL];
        
        SegmentInfo *tsInfo = [SegmentInfo infoWith:[durationStr doubleValue] tsURL:tsURL];
        [self.segments addObject:tsInfo];
    }
#ifdef DEBUG
    for (SegmentInfo *info in self.segments) {
        NSLog(@"%@",info.tsURL);
    }
#endif
    
}

@end

@implementation SegmentInfo

+ (instancetype)infoWith:(NSTimeInterval)duration tsURL:(NSString *)url {
    SegmentInfo *info = [SegmentInfo new];
    info.duration = duration;
    info.tsURL = url;
    return info;
}

@end
