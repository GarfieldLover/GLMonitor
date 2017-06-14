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
        self.saveRequestMaxCount=2;
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
        [staticManager createTable];
    });
    return staticManager;
    
}

+ (NSString *)filename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *ducumentsDirectory = [paths objectAtIndex:0];
    NSString *str=[[NSString alloc] initWithFormat:@"%@/networkeye.sqlite",ducumentsDirectory];
    return  str;
}

- (void)createTable {
    
    NSMutableString *init_sqls=[NSMutableString stringWithCapacity:1024];
    [init_sqls appendFormat:@"create table if not exists nenetworkhttpeyes(myID double primary key,startDateString text,endDateString text,requestURLString text,requestCachePolicy text,requestTimeoutInterval double,requestHTTPMethod text,requestAllHTTPHeaderFields text,requestHTTPBody text,responseMIMEType text,responseExpectedContentLength text,responseTextEncodingName text,responseSuggestedFilename text,responseStatusCode int,responseAllHeaderFields text,receiveJSONData text);"];
}

- (void)addModel:(NEHTTPModel *) aModel {
    
    if ([aModel.responseMIMEType isEqualToString:@"text/html"]) {
        aModel.receiveJSONData=@"";
    }
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"nenetworkhttpeyecache"] isEqualToString:@"a"]) {
        [self deleteAllItem];
        [[NSUserDefaults standardUserDefaults] setObject:@"b" forKey:@"nenetworkhttpeyecache"];
    }

    BOOL isNull;
    isNull=(aModel.receiveJSONData==nil);
    if (isNull) {
        aModel.receiveJSONData=@"";
    }
    NSString *receiveJSONData;
    receiveJSONData=[self stringToSQLFilter:aModel.receiveJSONData];
    if (enablePersistent) {
    }else {
        [allRequests addObject:aModel];
    }
    
    return ;
    
}

- (NSMutableArray *)allobjects {
    
    if (!enablePersistent) {
        if (allRequests.count>=self.saveRequestMaxCount) {
            [[NSUserDefaults standardUserDefaults] setObject:@"a" forKey:@"nenetworkhttpeyecache"];
        }
        return allRequests;
    }
    return nil;
}

- (void) deleteAllItem {
    
    if (!enablePersistent) {
        [allRequests removeAllObjects];
        return;
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

#pragma mark - Utils

- (id)stringToSQLFilter:(id)str {
    
    if ( [str respondsToSelector:@selector(stringByReplacingOccurrencesOfString:withString:)]) {
        id temp = str;
        temp = [temp stringByReplacingOccurrencesOfString:kSTRShortMarks withString:kSQLShortMarks];
        temp = [temp stringByReplacingOccurrencesOfString:kSTRDoubleMarks withString:kSQLDoubleMarks];
        return temp;
    }
    return str;
    
}

- (id)stringToOBJFilter:(id)str {
    
    if ( [str respondsToSelector:@selector(stringByReplacingOccurrencesOfString:withString:)]) {
        id temp = str;
        temp = [temp stringByReplacingOccurrencesOfString:kSQLShortMarks withString:kSTRShortMarks];
        temp = [temp stringByReplacingOccurrencesOfString:kSQLDoubleMarks withString:kSTRDoubleMarks];
        return temp;
    }
    return str;
    
}

@end
