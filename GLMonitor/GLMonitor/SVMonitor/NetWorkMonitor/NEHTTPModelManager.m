//
//  NEHTTPModelManager.m
//  NetworkEye
//
//  Created by coderyi on 15/11/4.
//  Copyright © 2015年 coderyi. All rights reserved.
//

#import "NEHTTPModelManager.h"

#import "NEHTTPModel.h"

#define kSTRDoubleMarks @"\""
#define kSQLDoubleMarks @"\"\""
#define kSTRShortMarks  @"'"
#define kSQLShortMarks  @"''"
@interface NEHTTPModelManager(){
    NSMutableArray *allMapRequests;
}
@end

@implementation NEHTTPModelManager

- (id)init {
    self = [super init];
    if (self) {
        allRequests = [NSMutableArray arrayWithCapacity:1];
        allMapRequests = [NSMutableArray arrayWithCapacity:1];
        enablePersistent = NO;
    }
    return self;
}

+ (NEHTTPModelManager *)defaultManager {
    
    static NEHTTPModelManager *staticManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        staticManager=[[NEHTTPModelManager alloc] init];
    });
    return staticManager;
    
}

- (void)addModel:(NEHTTPModel *) aModel {
    
    if ([aModel.responseMIMEType isEqualToString:@"text/html"]) {
        aModel.receiveJSONData=@"";
    }
    
    BOOL isNull;
    isNull=(aModel.receiveJSONData==nil);
    if (isNull) {
        aModel.receiveJSONData=@"";
    }
    if (enablePersistent) {
    }else {
        [allRequests addObject:aModel];
    }
}

- (NSMutableArray *)allobjects {
    
    if (!enablePersistent) {
        return allRequests;
    }
    return nil;
}

- (void) deleteAllItem {
    
    if (!enablePersistent) {
        [allRequests removeAllObjects];
    }
}

#pragma mark - map local

- (NSMutableArray *)allMapObjects {
    return allMapRequests;
}

- (void)addMapObject:(NEHTTPModel *)mapReq {
    
    for (NSInteger i=0; i < allMapRequests.count; i++) {
        NEHTTPModel *req = [allMapRequests objectAtIndex:i];
        if (![mapReq.mapPath isEqualToString:req.mapPath]) {
            [allMapRequests replaceObjectAtIndex:i withObject:mapReq];
            return;
        }
    }
    [allMapRequests addObject:mapReq];
}

- (void)removeMapObject:(NEHTTPModel *)mapReq {
    
    for (NSInteger i=0; i < allMapRequests.count; i++) {
        NEHTTPModel *req = [allMapRequests objectAtIndex:i];
        if ([mapReq.mapPath isEqualToString:req.mapPath]) {
            [allMapRequests removeObject:mapReq];
            return;
        }
    }
}

- (void)removeAllMapObjects {
    [allMapRequests removeAllObjects];
}


@end
