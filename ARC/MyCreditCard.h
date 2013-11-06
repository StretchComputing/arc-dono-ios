//
//  MyCreditCard.h
//  HolyDutch
//
//  Created by Nick Wroblewski on 11/5/13.
//
//

#import <Foundation/Foundation.h>

@interface MyCreditCard : NSObject


@property (nonatomic, retain) NSString * expiration;
@property (nonatomic, retain) NSString * number;
@property (nonatomic, retain) NSString * sample;
@property (nonatomic, retain) NSString * securityCode;
@property (nonatomic, retain) NSString * cardType;


@end
