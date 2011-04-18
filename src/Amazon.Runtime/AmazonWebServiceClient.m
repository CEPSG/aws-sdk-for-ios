/*
 * Copyright 2010-2011 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License.
 * A copy of the License is located at
 *
 *  http://aws.amazon.com/apache2.0
 *
 * or in the "license" file accompanying this file. This file is distributed
 * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 * express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

#import "AmazonWebServiceClient.h"
#import "AmazonEndpoints.h"

@implementation AmazonWebServiceClient

@synthesize endpoint, maxRetries, timeout, userAgent;

-(id)initWithAccessKey:(NSString *)theAccessKey withSecretKey:(NSString *)theSecretKey
{
    if (self = [self init]) {
        credentials = [[AmazonCredentials alloc] initWithAccessKey:theAccessKey withSecretKey:theSecretKey];
        maxRetries  = 5;
        timeout     = 240;
        userAgent   = [[AmazonSDKUtil userAgentString] retain];
    }
    return self;
}

-(id)initWithCredentials:(AmazonCredentials *)theCredentials
{
    if (self = [self init]) {
        credentials = theCredentials;
        maxRetries  = 5;
        timeout     = 240;
        userAgent   = [[AmazonSDKUtil userAgentString] retain];
    }
    return self;
}

+(id)constructResponseFromRequest:(AmazonServiceRequest *)request
{
    NSString *requestClassName  = NSStringFromClass([request class]);
    NSString *responseClassName = [[requestClassName substringToIndex:[requestClassName length] - 7] stringByAppendingFormat:@"Response"];

    id       response = [[NSClassFromString(responseClassName) alloc] init];

    if (nil == response) {
        response = [[AmazonServiceResponse alloc] init];
    }

    return [response autorelease];
}

-(AmazonServiceResponse *)invoke:(AmazonServiceRequest *)request
{
    if (nil == request) {
        @throw [AmazonClientException exceptionWithMessage : @"Request cannot be nil."];
    }

    [request setUserAgent:self.userAgent];

    if (nil == request.endpoint) {
        request.endpoint = [self endpoint];
    }
    if (nil == request.credentials) {
        [request setCredentials:credentials];
    }

    NSMutableURLRequest *urlRequest = [request configureURLRequest];
    [request sign];
    [urlRequest setHTTPBody:[[request queryString] dataUsingEncoding:NSUTF8StringEncoding]];

    AMZLogDebug(@"%@ %@", [urlRequest HTTPMethod], [urlRequest URL]);
    AMZLogDebug(@"Request body: ");
    NSString *rBody = [[NSString alloc] initWithData:[urlRequest HTTPBody] encoding:NSUTF8StringEncoding];
    AMZLogDebug(@"%@", rBody);
    [rBody release];

    AmazonServiceResponse *response = nil;
    int                   retries   = 0;
    while (retries < self.maxRetries) {
        AMZLogDebug(@"Begin Request: %@:%d", NSStringFromClass([request class]), retries);

        response = [AmazonWebServiceClient constructResponseFromRequest:request];
        [response setRequest:request];

        [urlRequest setTimeoutInterval:self.timeout];

        // Setting this here and not the AmazonServiceRequest because S3 extends that class and sets its own Content-Type Header.
        [urlRequest addValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];

        NSURLConnection *urlConnection = [NSURLConnection connectionWithRequest:urlRequest delegate:response];
        NSTimer         *timeoutTimer  = [NSTimer scheduledTimerWithTimeInterval:self.timeout target:response selector:@selector(timeout) userInfo:nil repeats:NO];

        while (!response.isFinishedLoading && !response.exception && !response.didTimeout) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }

        if (response.didTimeout) {
            [urlConnection cancel];
        }
        else {
            [timeoutTimer invalidate];     //  invalidate also releases the object.
        }


        AMZLogDebug(@"Response Status Code : %d", response.httpStatusCode);
        if ( [self shouldRetry:response]) {
            AMZLog(@"Retring Request: %d", retries);

            [self pauseExponentially:retries];
            retries++;
        }
        else {
            break;
        }
    }


    if (response.exception) {
        @throw response.exception;
    }


    return response;
}

-(AmazonServiceResponse *)parseResponse:(AmazonServiceResponse *)aResponse withDelegateType:(Class)delegateType
{
    NSString *tmpStr = [[NSString alloc] initWithData:[aResponse body] encoding:NSUTF8StringEncoding];

    AMZLogDebug(@"Response Body:\n%@", tmpStr);
    [tmpStr release];
    NSXMLParser                       *parser         = [[NSXMLParser alloc] initWithData:[aResponse body]];
    AmazonServiceResponseUnmarshaller *parserDelegate = [[delegateType alloc] init];
    [parser setDelegate:parserDelegate];
    [parser parse];

    AmazonServiceResponse *tmpReq   = [parserDelegate response];
    AmazonServiceResponse *response = [tmpReq retain];

    [parser release];
    [parserDelegate release];

    if (response.exception) {
        NSException *exception = [[response.exception copy] autorelease];
        [response release];
        if ([(NSObject *)[[aResponse request] delegate] respondsToSelector:@selector(request:didFailWithServiceException:)]) {
            [[[aResponse request] delegate] request:[aResponse request] didFailWithServiceException:(AmazonServiceException *)exception];
            return nil;
        }
        else {
            @throw exception;
        }
    }

    if ([(NSObject *)[[aResponse request] delegate] respondsToSelector:@selector(request:didCompleteWithResponse:)]) {
        [[[aResponse request] delegate] request:[aResponse request] didCompleteWithResponse:response];
    }

    [response postProcess];

    return [response autorelease];
}

-(bool)shouldRetry:(AmazonServiceResponse *)response
{
    if (response.didTimeout ||
        response.httpStatusCode == 500 ||
        response.httpStatusCode == 503 ||
        (response.exception != nil &&
         response.exception.reason != nil &&
         [response.exception.reason rangeOfString:@"Throttling"].location != NSNotFound)) {
        return YES;
    }

    return NO;
}

-(void)pauseExponentially:(int)tryCount
{
    NSTimeInterval pause = 0.5 * (pow(2, tryCount));

    [NSThread sleepForTimeInterval:pause];
}

-(void)setUserAgent:(NSString *)newUserAgent
{
    userAgent = [[NSString stringWithFormat:@"%@, %@", newUserAgent, [AmazonSDKUtil userAgentString]] retain];
}

-(void)dealloc
{
    [credentials release];
    [endpoint release];
    [userAgent release];

    [super dealloc];
}

@end