#import "URLParser.h"

@implementation URLParser
@synthesize variables;

- (id) initWithURLString:(NSString *)url{
    
    NSLog(@"URL: %@", url);
    
    self = [super init];
    if (self != nil) {
        NSString *string = url;
        NSScanner *scanner = [NSScanner scannerWithString:string];
        [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"&?"]];
        NSString *tempString;
        NSMutableArray *vars = [NSMutableArray new];
        [scanner scanUpToString:@"?" intoString:nil];       //ignore the beginning of the string and skip to the vars
        while ([scanner scanUpToString:@"&" intoString:&tempString]) {
            [vars addObject:[tempString copy]];
        }
        self.variables = vars;
    }
    return self;
}

- (NSString *)valueForVariable:(NSString *)varName {
    for (NSString *var in self.variables) {
        if ([var rangeOfString:varName].location != NSNotFound) {
            
            NSArray *parts = [var componentsSeparatedByString:@"="];
            
            if ([parts count] > 1) {
                return  [parts objectAtIndex:1];
            }
        }
    }
    return nil;
}


@end