//
//  SVURLRequestModel.h
//  Utility
//
//  Created by ZK on 2017/6/23.
//
//

#import <Foundation/Foundation.h>

@interface SVURLRequestModel : NSObject

@property (nonatomic,strong) NSURLRequest *ne_request;
@property (nonatomic,strong) NSHTTPURLResponse *ne_response;
@property (nonatomic,assign) double myID;
@property (nonatomic,strong) NSString *startDateString;
@property (nonatomic,strong) NSString *endDateString;

//request
@property (nonatomic,strong) NSString *requestURLString;
@property (nonatomic,strong) NSString *requestCachePolicy;
@property (nonatomic,assign) double requestTimeoutInterval;
@property (nonatomic, strong) NSString *requestHTTPMethod;
@property (nonatomic,strong) NSString *requestAllHTTPHeaderFields;
@property (nonatomic,strong) NSString *requestHTTPBody;

//response
@property (nonatomic,strong) NSString *responseMIMEType;
@property (nonatomic,strong) NSString * responseExpectedContentLength;
@property (nonatomic,strong) NSString *responseTextEncodingName;
@property (nonatomic, strong) NSString *responseSuggestedFilename;
@property (nonatomic,assign) int responseStatusCode;
@property (nonatomic,strong) NSString *responseAllHeaderFields;

//JSONData
@property (nonatomic,strong) NSString *receiveJSONData;

@property (nonatomic,strong) NSString *mapPath;
@property (nonatomic,strong) NSString *mapJSONData;


@end


@interface SVURLRequestModelManager : NSObject
{
    NSMutableArray *allRequests;
    BOOL enablePersistent;
}

/**
 *  get NEHTTPModelManager's singleton object
 *
 *  @return singleton object
 */
+ (SVURLRequestModelManager *)defaultManager;

/**
 *  add a SVURLRequestModel object to SQLite
 *
 *  @param aModel a SVURLRequestModel object
 */
- (void)addModel:(SVURLRequestModel *) aModel;

/**
 *  get SQLite all SVURLRequestModel object
 *
 *  @return all SVURLRequestModel object
 */
- (NSMutableArray *)allobjects;

/**
 *  delete all SQLite records
 */
- (void) deleteAllItem;

- (NSMutableArray *)allMapObjects;
- (void)addMapObject:(SVURLRequestModel *)mapReq;
- (void)removeMapObject:(SVURLRequestModel *)mapReq;
- (void)removeAllMapObjects;

@end

