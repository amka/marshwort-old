//
//  MEAppDelegate.h
//  marshwort
//
//  Created by Andrey M. on 18.03.13.
//  Copyright (c) 2013 Andrey M. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MEAppDelegate : NSObject <NSApplicationDelegate, NSTextViewDelegate> {
    NSMutableArray *languagesFromList;
    NSMutableArray *languagesToList;
    NSTimer *textChangedTimer;
}

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSPopUpButton *langFromBox;
@property (weak) IBOutlet NSPopUpButton *langToBox;

@property (unsafe_unretained) IBOutlet NSTextView *originTextView;
@property (unsafe_unretained) IBOutlet NSTextView *translatedTextView;


- (void)getLangs;
- (void)detectLang:(NSString *)text withFormat:(NSString *)format;
- (void)translate:(NSString *)text fromLanguage:(NSString *)language withFormat:(NSString *)format;

@end
