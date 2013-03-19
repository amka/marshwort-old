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
        languagesFromList = [[NSMutableArray alloc] init];
        languagesToList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [self getLangs];
}

- (void)getLangs
{
    NSURL *url = [NSURL URLWithString:@"http://translate.yandex.net/api/v1/tr.json/getLangs"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        for(NSString *dir in [JSON objectForKey:@"dirs"])
        {
            NSString *from = [dir substringToIndex:2];
            NSString *to = [dir substringFromIndex:3];
            if (![languagesFromList containsObject:from] == NO)
                [languagesFromList addObject:from];

            if ([languagesToList containsObject:to] == NO)
                [languagesToList addObject:to];
        }
        [languagesFromList sortUsingSelector:@selector(compare:)];
        [languagesToList sortUsingSelector:@selector(compare:)];
//        NSLog(@"Langs: %@", languagesToList);
    } failure:nil];
    
    [operation start];
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

- (void)translate:(NSString *)text fromLanguage:(NSString *)language withFormat:(NSString *)format
{
    NSURL *url = [NSURL URLWithString:@"http://translate.yandex.net/api/v1/tr.json/translate"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            NSLog(@"Langs: %@", JSON);
    } failure:nil];
    
    [operation start];
}

- (void)textDidChange:(NSNotification *)notification
{
    if (!textChangedTimer)
        textChangedTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f
                                                            target:self
                                                          selector:@selector(translateIt)
                                                          userInfo:nil
                                                           repeats:NO];
}

- (void)translateIt
{
    textChangedTimer = nil;
    NSLog(@"%@", [_originTextView string]);
    NSLog(@"translating..");
}

@end
