//
//  SVURLProtocol.m
//  Utility
//
//  Created by ZK on 2017/6/14.
//
//

#import "SVURLProtocol.h"
#import "SVURLSessionConfiguration.h"
#import "SVURLRequestModel.h"

#import "LXDHostMapper.h"
#import "LXDHostFilterRule.h"

@interface SVURLProtocol ()<NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSURLConnection *connection;

@property (nonatomic, strong) NSURLResponse *response;

@property (nonatomic, strong) NSMutableData *data;

@property (nonatomic, strong) NSDate *startDate;

@property (nonatomic,strong) SVURLRequestModel *ne_HTTPModel;

@end

@implementation SVURLProtocol

+ (void)registerProtocolClass {
    [NSURLProtocol registerClass:[SVURLProtocol class]];
    [[SVURLSessionConfiguration sharedConfiguration] swizzleProtocolClasses];
}

+ (void)unregisterProtocolClass {
    [NSURLProtocol unregisterClass:[SVURLProtocol class]];
    [[SVURLSessionConfiguration sharedConfiguration] unSwizzleProtocolClasses];
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if (![request.URL.scheme isEqualToString:@"http"] &&
        ![request.URL.scheme isEqualToString:@"https"]) {
        return NO;
    }
    
    if ([NSURLProtocol propertyForKey:@"SVURLProtocol" inRequest:request] ) {
        return NO;
    }
    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    
    NSString * host = request.URL.host;
    NSString * ip = [LXDHostMapper parseHost: host];
    if (ip == nil) { return request; }
    if ([LXDHostFilterRule isIpInvalid: ip]) { return request; }
    
    NSString * absoluteURLString = request.URL.absoluteString;
    NSRange range = [absoluteURLString rangeOfString: host];
    if (range.location == NSNotFound) { return request; }
    
    absoluteURLString = [absoluteURLString stringByReplacingCharactersInRange: range withString: ip];
    NSMutableURLRequest * canonicalRequest = request.mutableCopy;
    
    [NSURLProtocol setProperty:@YES forKey:@"SVURLProtocol" inRequest:canonicalRequest];
    
    canonicalRequest.URL = [NSURL URLWithString: absoluteURLString];
    return canonicalRequest;
}

- (void)startLoading {
    self.startDate = [NSDate date];
    self.data = [NSMutableData data];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    self.connection = [[NSURLConnection alloc] initWithRequest:[[self class] canonicalRequestForRequest:self.request] delegate:self startImmediately:YES];
#pragma clang diagnostic pop
    
    self.ne_HTTPModel=[[SVURLRequestModel alloc] init];
    self.ne_HTTPModel.ne_request=self.request;
    self.ne_HTTPModel.startDateString=[self stringWithDate:[NSDate date]];
    
    NSTimeInterval myID= [[NSDate date] timeIntervalSince1970];
    double randomNum= ((double)(arc4random() % 100))/10000;
    self.ne_HTTPModel.myID = myID+randomNum;
}

- (void)stopLoading {
    [self.connection cancel];
    
    self.ne_HTTPModel.ne_response=(NSHTTPURLResponse *)self.response;
    self.ne_HTTPModel.endDateString=[self stringWithDate:[NSDate date]];
    
    NSString *mimeType = self.response.MIMEType;
    if ([mimeType isEqualToString:@"application/json"]) {
        
        self.ne_HTTPModel.receiveJSONData = [self responseJSONFromData:self.data];
    } else if ([mimeType isEqualToString:@"text/javascript"]) {
        
        NSString *jsonString = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
        if ([jsonString hasSuffix:@")"]) {
            jsonString = [NSString stringWithFormat:@"%@;", jsonString];
        }
        if ([jsonString hasSuffix:@");"]) {
            NSRange range = [jsonString rangeOfString:@"("];
            if (range.location != NSNotFound) {
                range.location++;
                range.length = [jsonString length] - range.location - 2;
                jsonString = [jsonString substringWithRange:range];
                NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
                self.ne_HTTPModel.receiveJSONData = [self responseJSONFromData:jsonData];
            }
        }
        
    }else if ([mimeType isEqualToString:@"application/xml"] ||[mimeType isEqualToString:@"text/xml"]){
        NSString *xmlString = [[NSString alloc]initWithData:self.data encoding:NSUTF8StringEncoding];
        if (xmlString && xmlString.length>0) {
            self.ne_HTTPModel.receiveJSONData = xmlString;
        }
    }
    [[SVURLRequestModelManager defaultManager] addModel:self.ne_HTTPModel];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [[self client] URLProtocol:self didFailWithError:error];
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection {
    return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [[self client] URLProtocol:self didReceiveAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [[self client] URLProtocol:self didCancelAuthenticationChallenge:challenge];
}

#pragma mark - NSURLConnectionDataDelegate
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
    if (response != nil){
        self.response = response;
        [[self client] URLProtocol:self wasRedirectedToRequest:request redirectResponse:response];
    }
    return request;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
  
    if ([response isKindOfClass: [NSHTTPURLResponse class]]) {
        NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode == 404) {
            NSString * host = response.URL.host;
            if ([LXDHostMapper validIp: host]) {
                [connection cancel];
                [LXDHostFilterRule registerInvailIp: host];
                
//                NSString * absoluteURLString = response.URL.absoluteString;
//                NSRange range = [absoluteURLString rangeOfString: host];
//                if (range.location != NSNotFound) {
//                    absoluteURLString = [absoluteURLString stringByReplacingCharactersInRange: range withString: [LXDHostFilterRule getHostFromIpAddress: host]];
//                    lxd_invalid_ip_handle([NSURL URLWithString: absoluteURLString]);
//                }
            }
        }
    }
    
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    self.response = response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSString *mimeType = self.response.MIMEType;
    if ([mimeType isEqualToString:@"application/json"]) {
        NSArray *allMapRequests = [[SVURLRequestModelManager defaultManager] allMapObjects];
        for (NSInteger i=0; i < allMapRequests.count; i++) {
            SVURLRequestModel *req = [allMapRequests objectAtIndex:i];
            if ([[self.ne_HTTPModel.ne_request.URL absoluteString] containsString:req.mapPath]) {
                NSData *jsonData = [req.mapJSONData dataUsingEncoding:NSUTF8StringEncoding];
                [[self client] URLProtocol:self didLoadData:jsonData];
                [self.data appendData:jsonData];
                return;
                
            }
        }
    }
    [[self client] URLProtocol:self didLoadData:data];
    [self.data appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return cachedResponse;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [[self client] URLProtocolDidFinishLoading:self];
}

#pragma mark - Utils

-(id)responseJSONFromData:(NSData *)data {
    if(data == nil) return nil;
    NSError *error = nil;
    id returnValue = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if(error) {
        NSLog(@"JSON Parsing Error: %@", error);
        return nil;
    }
    if (!returnValue || returnValue == [NSNull null]) {
        return nil;
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:returnValue options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

- (NSString *)stringWithDate:(NSDate *)date {
    NSString *destDateString = [[SVURLProtocol defaultDateFormatter] stringFromDate:date];
    return destDateString;
}

+ (NSDateFormatter *)defaultDateFormatter {
    static NSDateFormatter *staticDateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        staticDateFormatter=[[NSDateFormatter alloc] init];
        [staticDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    });
    return staticDateFormatter;
}

@end
