//
//  Dish.h
//  Fresh-Chef-Analytics
//
//  Created by selinons on 7/16/19.
//  Copyright © 2019 julia@ipearl.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Parse/Parse.h"

NS_ASSUME_NONNULL_BEGIN

@interface Dish : PFObject<PFSubclassing>
@property (nonatomic, strong) NSString *restaurantID;
@property (nonatomic, strong) PFUser *restaurant;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *dishDescription;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) PFFileObject *image;
@property (nonatomic, weak) NSNumber *rating;
@property (nonatomic, strong) NSNumber *orderFrequency;
@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, strong) NSArray *comments;

+ (void) postNewDish: ( NSString * _Nullable )name withType: ( NSString * _Nullable )type withDescription: ( NSString * _Nullable )description withPrice: ( NSNumber * _Nullable )price  withCompletion: (PFBooleanResultBlock  _Nullable)completion;
+ (void) postNewDish: ( NSString * _Nullable )name withType: ( NSString * _Nullable )type withDescription: ( NSString * _Nullable )description withPrice: ( NSNumber * _Nullable )price withImage: ( UIImage * _Nullable )image withCompletion: (PFBooleanResultBlock  _Nullable)completion;
@end

NS_ASSUME_NONNULL_END