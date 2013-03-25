//
//  MEDocument.m
//  Marshwort
//
//  Created by Andrey M. on 23.03.13.
//  Copyright (c) 2013 Andrey M. All rights reserved.
//

#import "MEDocument.h"
#import "MELanguage.h"
#import "AFJSONRequestOperation.h"

@implementation MEDocument

- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        MELanguage *english = [[MELanguage alloc] init];
        english.code = @"en";
        english.name = @"Английский";
        english.flag = [NSImage imageNamed:@"en.icns"];
        
        MELanguage *russian = [[MELanguage alloc] init];
        russian.code = @"ru";
        russian.name = @"Русский";
        russian.flag = [NSImage imageNamed:@"ru.icns"];
        
        MELanguage *italian = [[MELanguage alloc] init];
        italian.code = @"it";
        italian.name = @"Итальянский";
        italian.flag = [NSImage imageNamed:@"it.png"];
        
        MELanguage *ukranian = [[MELanguage alloc] init];
        ukranian.code = @"uk";
        ukranian.name = @"Украинский";
        ukranian.flag = [NSImage imageNamed:@"uk"];
        
        MELanguage *turkey = [[MELanguage alloc] init];
        turkey.code = @"tr";
        turkey.name = @"Турецкий";
        turkey.flag = [NSImage imageNamed:@"tr.png"];
        
        MELanguage *deutch = [[MELanguage alloc] init];
        deutch.code = @"de";
        deutch.name = @"Немецкий";
        deutch.flag = [NSImage imageNamed:@"de.png"];
        
        languagesFrom = [NSArray arrayWithObjects:english, italian, deutch, russian, turkey, ukranian, nil];
        languagesTo = [NSArray arrayWithObjects:english, italian, deutch, russian, turkey, ukranian, nil];
        
        userDefaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"MEDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (void)awakeFromNib {
    [_langsToArrayController setSelectionIndex:3];
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
//    NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
//    @throw exception;
    NSMutableDictionary *attrs = [NSDictionary dictionaryWithObject:NSPlainTextDocumentType
                                                            forKey:NSDocumentTypeDocumentAttribute];
    NSData *data = [[_sourceTextView textStorage] dataFromRange:NSMakeRange(0, sourceText.length)
                              documentAttributes:attrs
                                           error:nil];
    if (!data && outError) {
        *outError = [NSError errorWithDomain:NSCocoaErrorDomain
                                        code:NSFileWriteUnknownError userInfo:nil];
    }
    return data;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
    // If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
    sourceText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
//    NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
//    @throw exception;
    [self beginTranslateTimer];
    return YES;
}

- (IBAction)reverseLanguages:(id)sender {
    NSUInteger indexFrom = [_langsFromArrayController selectionIndex];
    NSUInteger indexTo = [_langsToArrayController selectionIndex];
    [_langsFromArrayController setSelectionIndex:indexTo];
    [_langsToArrayController setSelectionIndex:indexFrom];
    [self beginTranslateTimer];
}

- (IBAction)changeLanguage:(id)sender {
    [self beginTranslateTimer];
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

- (void)beginTranslateTimer
{
    if (!translateTimer)
        translateTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f
                                                          target:self
                                                        selector:@selector(beginTranslate:)
                                                        userInfo:nil
                                                         repeats:NO];
    [_inworkIndicator startAnimation:self];
}

- (IBAction)beginTranslate:(id)sender
{
    [_inworkIndicator stopAnimation:self];
    translateTimer = nil;
    MELanguage *langFrom = [languagesFrom objectAtIndex:[_langsFromArrayController selectionIndex]];
    MELanguage *langTo = [languagesTo objectAtIndex:[_langsToArrayController selectionIndex]];
    [self translate:[_sourceTextView string]
       fromLanguage:langFrom.code
         toLanguage:langTo.code
         withFormat:@"plain"];
}

- (void)textDidChange:(NSNotification *)notification
{
    [self beginTranslateTimer];
}
@end
