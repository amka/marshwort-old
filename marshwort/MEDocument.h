//
//  MEDocument.h
//  Marshwort
//
//  Created by Andrey M. on 23.03.13.
//  Copyright (c) 2013 Andrey M. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MEDocument : NSDocument <NSTextViewDelegate> {
    NSArray *languagesFrom;
    NSArray *languagesTo;
    NSString *sourceText;
    NSString *translatedText;
    NSTimer *translateTimer;
    NSUserDefaults *userDefaults;
}

@property (unsafe_unretained) IBOutlet NSTextView *sourceTextView;
@property (unsafe_unretained) IBOutlet NSTextView *translatedTextView;
@property (weak) IBOutlet NSPopUpButtonCell *languageFromBox;
@property (weak) IBOutlet NSPopUpButtonCell *languageToBox;
@property (strong) IBOutlet NSArrayController *langsFromArrayController;
@property (strong) IBOutlet NSArrayController *langsToArrayController;
@property (weak) IBOutlet NSProgressIndicator *inworkIndicator;

- (IBAction)reverseLanguages:(id)sender;

- (IBAction)changeLanguage:(id)sender;
- (void)translate:(NSString *)text fromLanguage:(NSString *)from toLanguage:(NSString *)to withFormat:(NSString *)format;
- (IBAction)beginTranslate:(id)sender;
- (void)beginTranslateTimer;
@end
