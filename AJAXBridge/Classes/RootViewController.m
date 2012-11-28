/*!
 * \file    WebViewController
 * \project 
 * \author  Andy Rifken 
 * \date    11/20/12.
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



#import "RootViewController.h"
#import "JavascriptBridgeURLCache.h"
#import "NativeAction.h"
#import <AddressBook/AddressBook.h>

@implementation RootViewController
@synthesize webView = mWebView;

+ (void)initialize {
    [super initialize];

    // Create an instance of our custom NSURLCache object to use for
    // to check any outgoing requests in our app
    JavascriptBridgeURLCache *cache = [[JavascriptBridgeURLCache alloc] init];
    [NSURLCache setSharedURLCache:cache];
}


- (void)viewDidLoad {
    [super viewDidLoad];

    // Tell our custom NSURLCache object that we want this class to handle requests to native code. This method
    // is a category on NSURLCache that safely sets the delegate property (defined in JavascriptBridgeURLCache.h)
    [NSURLCache setJavascriptBridgeDelegate:self];

    // create our webview and add it to the view hierarchy
    mWebView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    mWebView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:mWebView];

    // load our HTML and JS from a local file
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"www/index" ofType:@"html"];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    [mWebView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)dealloc {
    // This instance is going away, so unbind it from our custom NSURLCache
    [NSURLCache setJavascriptBridgeDelegate:nil];
}

#pragma mark -
#pragma mark WebView Delegate
//============================================================================================================


/*!
 * This is the method that gets called when Javascript wants to tell our native app something. It is called from our
 * shared JavascriptBridgeURLCache object.
 *
 * \param nativeAction The request from Javascript
 * \param error A pointer to an error object that we can populate if we encounter a problem in handling this request
 * \return A dictionary that will be serialized into a JSON object and sent back to Javascript as the response
 */
- (NSDictionary *)handleAction:(NativeAction *)nativeAction error:(NSError **)error {
    // For this demo, we'll handle two types of requests. The first will simply show a native UIAlertView with params
    // passed from Javascript, and the second will go fetch the contacts from our address book and pass names and phone
    // numbers back to Javascript.

    // -------- GET /alert
    if ([nativeAction.action isEqualToString:@"alert"]) {
        //Typically, this request is sent to native code on the Web Thread, so if we want to do something that is
        // going to draw to the screen from native code, we need to run it on the main thread.
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[nativeAction.params objectForKey:@"title"] message:[nativeAction.params objectForKey:@"message"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
        });
        return nil;
    }

    // -------- GET /contacts
    else if ([nativeAction.action isEqualToString:@"contacts"]) {
        // dictionary to store names and phone numbers from the address book
        NSMutableDictionary *namesAndNumbers = [[NSMutableDictionary alloc] init];

        // get names and numbers from the address book
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        CFArrayRef array = ABAddressBookCopyArrayOfAllPeople(addressBook);
        for (int j = 0; j < CFArrayGetCount(array); j++) {
            CFStringRef name = ABRecordCopyValue(CFArrayGetValueAtIndex(array, j), kABPersonFirstNameProperty);
            NSArray *numbers = (__bridge NSArray *) ABMultiValueCopyArrayOfAllValues(ABRecordCopyValue(CFArrayGetValueAtIndex(array, j), kABPersonPhoneProperty));
            if (name && numbers) {
                NSString *number = nil;
                if ([numbers count] > 0) {
                    number = [numbers objectAtIndex:0];
                }
                [namesAndNumbers setObject:number forKey:(__bridge NSString *) name];
            }
            CFRelease((CFTypeRef) name);
        }
        CFRelease((CFTypeRef) array);
        CFRelease(addressBook);

        return @{
        @"contacts" : namesAndNumbers
        };
    }

    return nil;
}


@end