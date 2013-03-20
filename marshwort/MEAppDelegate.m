//
//  MEAppDelegate.m
//  marshwort
//
//  Created by Andrey M. on 18.03.13.
//  Copyright (c) 2013 Andrey M. All rights reserved.
//

#import "MEAppDelegate.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "AFJSONRequestOperation.h"

@implementation MEAppDelegate

- (id)init
{
    if(self = [super init]) {
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (void)detectLang:(NSString *)text withFormat:(NSString *)format
{
    NSURL *url = [NSURL URLWithString:@"http://translate.yandex.net/api/v1/tr.json/detect"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            NSLog(@"Langs: %@", JSON);
    } failure:nil];
    
    [operation start];
}

- (void)translate:(NSString *)text fromLanguage:(NSString *)from toLanguage:(NSString *)to withFormat:(NSString *)format
{
    NSURL *url = [NSURL URLWithString:@"http://translate.yandex.net/api/v1/tr.json/translate"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                    cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                timeoutInterval:60.0];

    [request setHTTPMethod:@"POST"];
    
    NSString *postString = [NSString stringWithFormat:@"lang=%@-%@&text=%@", from, to, text];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {

        if ([[JSON objectForKey:@"text"] objectAtIndex:0]) {
            [_translatedTextView setString:[[JSON objectForKey:@"text"] objectAtIndex:0]];
        }
        
    } failure:nil];
    
    [operation start];
}

- (void)textDidChange:(NSNotification *)notification
{
    if (!textChangedTimer)
        textChangedTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f
                                                            target:self
                                                          selector:@selector(translateClicked:)
                                                          userInfo:nil
                                                           repeats:NO];
}

- (IBAction)translateClicked:(id)sender {
    textChangedTimer = nil;
//    NSLog(@"translating %@->%@", [[_langFromBox selectedItem] title], [[_langToBox selectedItem] title]);
    
    [self translate:[_originTextView string]
       fromLanguage:[[_langFromBox selectedItem] title]
         toLanguage:[[_langToBox selectedItem] title]
         withFormat:@"plain"];
}
@end
