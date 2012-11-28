/*!
 * \file    NativeAction
 * \project 
 * \author  Andy Rifken 
 * \date    11/25/12.
 *
 * Copyright 2012 Andy Rifken

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



#import "NativeAction.h"


@implementation NativeAction
@synthesize method = mMethod;
@synthesize params = mParams;

- (id)initWithAction:(NSString *)action method:(NSString *)method params:(NSDictionary *)params {
    self = [super init];
    if (self) {
        self.action = action;
        mMethod = method;
        mParams = params;
    }
    return self;
}

+ (id)objectWithAction:(NSString *)action method:(NSString *)method params:(NSDictionary *)params {
    return [[NativeAction alloc] initWithAction:action method:method params:params];
}

- (NSString *)action {
    return mAction;
}

- (void)setAction:(NSString *)action {
    if (mAction != action) {
        mAction = [action lowercaseString];
    }

}


@end