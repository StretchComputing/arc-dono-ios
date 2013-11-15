//
//  SteelfishBoldButton.m
//  HolyDutch
//
//  Created by Nick Wroblewski on 11/15/13.
//
//

#import "SteelfishBoldButton.h"
#import "SteelfishLabel.h"

@implementation SteelfishBoldButton


- (id)initWithCoder:(NSCoder *)decoder {
    
    if ((self = [super initWithCoder: decoder])) {
        
        [self.titleLabel setFont: [UIFont fontWithName:FONT_BOLD size: self.titleLabel.font.pointSize]];
        
        [self setTitleEdgeInsets:UIEdgeInsetsMake(1.0, 0.0, 0.0, 0.0)];
        
    }
    return self;
}

@end
