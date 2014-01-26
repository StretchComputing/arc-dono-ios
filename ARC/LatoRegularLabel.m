//
//  LatoRegularLabel.m
//  Dono
//
//  Created by Nick Wroblewski on 1/25/14.
//
//

#import "LatoRegularLabel.h"

@implementation LatoRegularLabel

- (id)initWithCoder:(NSCoder *)decoder {
    
    if ((self = [super initWithCoder: decoder])) {
        
        [self setFont: [UIFont fontWithName:LATO_REGULAR size: self.font.pointSize+4]];
    }
    return self;
}


@end
