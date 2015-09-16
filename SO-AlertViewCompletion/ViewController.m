//
//  ViewController.m
//  SO-AlertViewCompletion
//
//  Created by Duc DoBa on 9/17/15.
//  Copyright © 2015 Ducky Duke. All rights reserved.
//

#import "ViewController.h"

//--------------- Modify NSBunle behavior -------------
#import <objc/runtime.h>

@interface CustomizedBundle : NSBundle
@end

@implementation CustomizedBundle
static const char kAssociatedLanguageBundle = 0;

-(NSString*)localizedStringForKey:(NSString *)key
                            value:(NSString *)value
                            table:(NSString *)tableName {
    
    NSBundle* bundle=objc_getAssociatedObject(self, &kAssociatedLanguageBundle);
    
    return bundle ? [bundle localizedStringForKey:key value:value table:tableName] :
    [super localizedStringForKey:key value:value table:tableName];
}
@end

@implementation NSBundle (Custom)
+ (void)setLanguage:(NSString*)language {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        object_setClass([NSBundle mainBundle], [CustomizedBundle class]);
    });
    
    objc_setAssociatedObject([NSBundle mainBundle], &kAssociatedLanguageBundle, language ?
                             [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:language ofType:@"lproj"]] : nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end

//--------------- Demo ---------------------------------
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIButton *button;

@property (nonatomic, assign) BOOL usingArabic;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self localizeTexts];
}

- (void)localizeTexts {
    self.label.text = NSLocalizedString(@"explanation_message", nil);
    [self.button setTitle:NSLocalizedString(@"language_switch_title", nil) forState:UIControlStateNormal];
}


- (IBAction)switchLanguageTouched:(id)sender {
    _usingArabic = !_usingArabic;
    NSString *targetLang = _usingArabic ? @"ar" : @"en";
    
    [NSBundle setLanguage:targetLang];
    
    [[NSUserDefaults standardUserDefaults] setObject:targetLang forKey:@"selectedLanguage"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [NSBundle setLanguage:targetLang];
    
    [self localizeTexts];
}

@end
