//
//  M3U8Handler.h
//  M3U8Demo
//
//  Created by AdminZhiHua on 16/5/13.
//  Copyright © 2016年 AdminZhiHua. All rights reserved.
//

#import <Foundation/Foundation.h>

@class M3U8Handler;
@protocol M3U8HandlerDelegate <NSObject>

- (void)M3U8Handler:(M3U8Handler *)handler praseError:(NSError *)error;

- (void)praseM3U8InfoFinish:(M3U8Handler *)handler ;

@end

@interface M3U8Handler : NSObject

@property (nonatomic,weak) id<M3U8HandlerDelegate> delegate;

//分片信息数组
@property (nonatomic,strong) NSMutableArray *segments;

@property (nonatomic,copy) NSString *urlString;

- (void)praseM3U8With:(NSURL *)url handlerDelegate:(id<M3U8HandlerDelegate>)delegate;

@end

@interface SegmentInfo : NSObject

@property (nonatomic,copy) NSString *tsURL;

@property (nonatomic,assign) NSTimeInterval duration;

+ (instancetype)infoWith:(NSTimeInterval)duration tsURL:(NSString *)url;

@end

