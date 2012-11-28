/*!
 * \file    JavascriptBridgeURLCache
 * \project 
 * \author  Andy Rifken 
 * \date    11/20/12.
 *
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



#import <Foundation/Foundation.h>

@class NativeAction;
@protocol JavascriptBridgeDelegate;

@interface JavascriptBridgeURLCache : NSURLCache {
    id <JavascriptBridgeDelegate> __weak mDelegate;
}

@property(weak) id <JavascriptBridgeDelegate> delegate;

@end


@protocol JavascriptBridgeDelegate <NSObject>
- (NSDictionary *)handleAction:(NativeAction *)action error:(NSError **)error;
@end


/*!
 * These are convenience methods for setting/getting the delegate from our custom instance of NSURLCache. They safely check
 * the type of the shared NSURLCache object to make sure it is our class before attempting to retrieve the deletgate.
 */
@interface NSURLCache (JavascriptBridge)
+ (id <JavascriptBridgeDelegate>)javascriptBridgeDelegate;

+ (void)setJavascriptBridgeDelegate:(id <JavascriptBridgeDelegate>)delegate;
@end