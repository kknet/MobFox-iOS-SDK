//
//  MFURLProtocol.m
//  DemoApp
//
//  Created by Itamar Nabriski on 16/01/2017.
//  Copyright © 2017 Matomy Media Group Ltd. All rights reserved.
//


#import "MFURLProtocol.h"


@implementation MFURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
  //  static NSUInteger requestCount = 0;
    //NSLog(@"Request #%lu: URL = %@", (unsigned long)requestCount++, request);
    
    if ([NSURLProtocol propertyForKey:@"MyURLProtocolHandledKey" inRequest:request]) {
        return NO;
    }
    
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b {
    return [super requestIsCacheEquivalent:a toRequest:b];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if([str rangeOfString:@"<htmlString><![CDATA["].length > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
             [MFReport log:@"network" withInventoryHash:@"xxx" andWithMessage:@"ad served"];
        });
    }
    [self.client URLProtocol:self didLoadData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.client URLProtocolDidFinishLoading:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.client URLProtocol:self didFailWithError:error];
}

- (void)startLoading {
    NSMutableURLRequest *newRequest = [self.request mutableCopy];
    [NSURLProtocol setProperty:@YES forKey:@"MyURLProtocolHandledKey" inRequest:newRequest];
    
    self.connection = [NSURLConnection connectionWithRequest:newRequest delegate:self];
}

- (void)stopLoading {
    [self.connection cancel];
    self.connection = nil;
}

@end
