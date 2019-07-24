//
//  OpenOrders=.h
//  Fresh-Chef-Analytics
//
//  Created by selinons on 7/24/19.
//  Copyright © 2019 julia@ipearl.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Parse/Parse.h"
#import "Waiter.h"
#import "Dish.h"

NS_ASSUME_NONNULL_BEGIN

@interface OpenOrder : PFObject<PFSubclassing>
@property NSArray *orders;
@property Waiter *waiter;
+ (void) postNewOrder: (NSArray *) order withWaiter : (Waiter *) waiter withCompletion : (PFBooleanResultBlock  _Nullable)completion;
//- (NSUInteger) searchOrderforDish:(OpenOrder *)openOrder withDish:(Dish *)dish;
@end
NS_ASSUME_NONNULL_END
