/*!
 * \file    JavascriptBridgeURLCache
 * \project 
 * \author  Andy Rifken 
 * \date    11/20/12.

  Copyright 2012 Andy Rifken

  Permission is hereby granted, free of charge, to any person obtaining
  a copy of this software and associated documentation files (the
  "Software"), to deal in the Software without restriction, including
  without limitation the rights to use, copy, modify, merge, publish,
  distribute, sublicense, and/or sell copies of the Software, and to
  permit persons to whom the Software is furnished to do so, subject to
  the following conditions:

  The above copyright notice and this permission notice shall be
  included in all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "JavascriptBridgeURLCache.h"
#import "GTMNSDictionary+URLArguments.h"
#import "NativeAction.h"
#import "SBJsonWriter.h"

// We'll intercept all requests going to the following host:
const NSString *kAppHost = @"myApp.example.org";

@implementation JavascriptBridgeURLCache

@synthesize delegate = mDelegate;

/*!
 * This method is called by the system before an NSURLRequest goes out. It gives us a chance to intercept an outgoing
 * HTTP request and provide a "cached" response. Typically, this is used to reduce bandwidth usage and unneccessary
 * network transactions, but here we're going to use it to respond to the request as if our native code was the web
 * server.
 */
- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request {

    NSURL *url = [request URL];

    // check the host to see if Javascript is trying to send a request to our app's "fake" host
    if ([[url host] caseInsensitiveCompare:(NSString *) kAppHost] == NSOrderedSame) {

        NSString *action = nil;
        if ([[url pathComponents] count] > 1) { // use index 1 since index 0 is the '/'
            // Theoretically, we could use the :controller/:action/:id pattern here, but for simplicity we'll just do
            // /:action
            action = [[url pathComponents] objectAtIndex:1];
        }
        NSString *query = [url query];
        NSString *method = [request HTTPMethod];
        NSDictionary *params = nil;

        // we also want to extract any arguments passed in the request. In a GET, we can get these from the URL query
        // string. In requests with entities, we can get this from the request body (assume www-form encoded for our purposes
        // here, but we could also handle JSON entities)
        if ([method isEqualToString:@"POST"] || [method isEqualToString:@"PUT"]) {
            NSString *body = nil;
            body = [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding];
            params = [NSDictionary gtm_dictionaryWithHttpArgumentsString:body];
        } else {
            params = [NSDictionary gtm_dictionaryWithHttpArgumentsString:query];
        }

        // construct a NativeAction object to transport this request message to our handler in native code
        NativeAction *nativeAction = [[NativeAction alloc] initWithAction:action method:method params:params];
        NSError *error1 = nil;
        NSMutableDictionary *result = [[self.delegate handleAction:nativeAction error:&error1] mutableCopy];

        // if we got an error, assign it in the hash we'll pass back to javascript
        if (error1) {
            [result setObject:@{
            @"code" : [NSNumber numberWithInt:error1.code],
            @"message" : [error1 localizedDescription]

            }          forKey:@"error"];
        }

        // Lastly, we need to construct an NSCachedURLResponse object to return from this method. This is the response
        // (headers + body) that will be passed back to our jQuery callback
        NSCachedURLResponse *cachedResponse = nil;
        if (result) {
            NSString *jsonString = [[[SBJsonWriter alloc] init] stringWithObject:result];
            NSData *jsonBody = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            NSURLResponse *res = [[NSURLResponse alloc] initWithURL:request.URL MIMEType:@"application/json" expectedContentLength:[jsonBody length] textEncodingName:nil];
            cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:res data:jsonBody];
        }
        return cachedResponse;
    }

    // if not matching our custom host, allow system to handle it
    return [super cachedResponseForRequest:request];
}

@end


@implementation NSURLCache (JavascriptBridge)

+ (id <JavascriptBridgeDelegate>)javascriptBridgeDelegate {
    NSURLCache *sharedURLCache = [NSURLCache sharedURLCache];
    if ([sharedURLCache isKindOfClass:[JavascriptBridgeURLCache class]]) {
        return [(JavascriptBridgeURLCache *) sharedURLCache delegate];
    }
    return nil;
}

+ (void)setJavascriptBridgeDelegate:(id <JavascriptBridgeDelegate>)delegate {
    NSURLCache *sharedURLCache = [NSURLCache sharedURLCache];
    if ([sharedURLCache isKindOfClass:[JavascriptBridgeURLCache class]]) {
        [(JavascriptBridgeURLCache *) sharedURLCache setDelegate:delegate];
    }
}

@end