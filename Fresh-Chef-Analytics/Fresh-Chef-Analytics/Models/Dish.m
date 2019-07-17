//
//  Dish.m
//  Fresh-Chef-Analytics
//
//  Created by selinons on 7/16/19.
//  Copyright © 2019 julia@ipearl.net. All rights reserved.
//

#import "Dish.h"
#import "Parse/Parse.h"

@implementation Dish
@dynamic restaurantID;
@dynamic restaurant;
@dynamic name;
@dynamic dishDescription;
@dynamic type;
@dynamic image;
@dynamic rating;
@dynamic orderFrequency;
@dynamic price;
@dynamic comments;

+ (nonnull NSString *)parseClassName {
    return @"Dish";
}
+ (void) postNewDish: ( NSString * _Nullable )name withType: ( NSString * _Nullable )type withDescription: ( NSString * _Nullable )description withPrice: ( NSNumber * _Nullable )price withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    Dish *newDish = [Dish new];
    
    // Uncomment when sign up/log in works //
    //newDish.restaurant = [PFUser currentUser];
    //newDish.restaurantID = newDish.restaurant.objectId;
    
    newDish.name = name;
    newDish.type = type;
    newDish.dishDescription = description;
    newDish.price = price;
    newDish.rating = nil;
    newDish.orderFrequency = @(0);
    newDish.comments = [[NSArray alloc] init];
    [newDish saveInBackgroundWithBlock:completion];
}
+ (void) postNewDish: ( NSString * _Nullable )name withType: ( NSString * _Nullable )type withDescription: ( NSString * _Nullable )description withPrice: ( NSNumber * _Nullable )price withImage: ( UIImage * _Nullable )image withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    Dish *newDish = [Dish new];
    
    // Uncomment when sign up/log in works //
    //newDish.restaurant = [PFUser currentUser];
    //newDish.restaurantID = newDish.restaurant.objectId;
    newDish.image = [self getPFFileFromImage:image];
    newDish.name = name;
    newDish.type = type;
    newDish.dishDescription = description;
    newDish.price = price;
    newDish.rating = nil;
    newDish.orderFrequency = @(0);
    newDish.comments = [[NSArray alloc] init];
    [newDish saveInBackgroundWithBlock:completion];

}
+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image {
    
    // check if image is not nil
    if (!image) {
        return nil;
    }
    
    NSData *imageData = UIImagePNGRepresentation(image);
    // get image data and check if that is not nil
    if (!imageData) {
        return nil;
    }
    
    return [PFFileObject fileObjectWithData:imageData];
    
}

@end