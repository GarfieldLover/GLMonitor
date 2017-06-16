//
//  NEHTTPModelManager.h
//  NetworkEye
//
//  Created by coderyi on 15/11/4.
//  Copyright © 2015年 coderyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NEHTTPModel;
@interface NEHTTPModelManager : NSObject
{
    NSMutableArray *allRequests;
    BOOL enablePersistent;
}

/**
 *  get NEHTTPModelManager's singleton object
 *
 *  @return singleton object
 */
+ (NEHTTPModelManager *)defaultManager;

/**
 *  add a NEHTTPModel object to SQLite
 *
 *  @param aModel a NEHTTPModel object
 */
- (void)addModel:(NEHTTPModel *) aModel;

/**
 *  get SQLite all NEHTTPModel object
 *
 *  @return all NEHTTPModel object
 */
- (NSMutableArray *)allobjects;

/**
 *  delete all SQLite records
 */
- (void) deleteAllItem;

- (NSMutableArray *)allMapObjects;
- (void)addMapObject:(NEHTTPModel *)mapReq;
- (void)removeMapObject:(NEHTTPModel *)mapReq;
- (void)removeAllMapObjects;

@end
