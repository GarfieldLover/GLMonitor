//
//  SVHTTPRequestModel.h
//  Utility
//
//  Created by ZK on 2017/6/22.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface SVHTTPRequestModel : NSObject

@property (nonatomic,strong) NSURLRequest *ne_request;
@property (nonatomic,strong) NSHTTPURLResponse *ne_response;
@property (nonatomic,assign) double myID;
@property (nonatomic,strong) NSString *startDateString;
@property (nonatomic,strong) NSString *endDateString;

//request
@property (nonatomic,strong) NSString *requestURLString;
@property (nonatomic,strong) NSString *requestCachePolicy;
@property (nonatomic,assign) double requestTimeoutInterval;
@property (nonatomic,nullable, strong) NSString *requestHTTPMethod;
@property (nonatomic,nullable,strong) NSString *requestAllHTTPHeaderFields;
@property (nonatomic,nullable,strong) NSString *requestHTTPBody;

//response
@property (nonatomic,nullable,strong) NSString *responseMIMEType;
@property (nonatomic,strong) NSString * responseExpectedContentLength;
@property (nonatomic,nullable,strong) NSString *responseTextEncodingName;
@property (nullable, nonatomic, strong) NSString *responseSuggestedFilename;
@property (nonatomic,assign) int responseStatusCode;
@property (nonatomic,nullable,strong) NSString *responseAllHeaderFields;

//JSONData
@property (nonatomic,strong) NSString *receiveJSONData;

@property (nonatomic,strong) NSString *mapPath;
@property (nonatomic,strong) NSString *mapJSONData;

@end
NS_ASSUME_NONNULL_END


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
 *  add a SVHTTPRequestModel object to SQLite
 *
 *  @param aModel a SVHTTPRequestModel object
 */
- (void)addModel:(SVHTTPRequestModel *) aModel;

/**
 *  get SQLite all SVHTTPRequestModel object
 *
 *  @return all SVHTTPRequestModel object
 */
- (NSMutableArray *)allobjects;

/**
 *  delete all SQLite records
 */
- (void) deleteAllItem;

- (NSMutableArray *)allMapObjects;
- (void)addMapObject:(SVHTTPRequestModel *)mapReq;
- (void)removeMapObject:(SVHTTPRequestModel *)mapReq;
- (void)removeAllMapObjects;

@end
