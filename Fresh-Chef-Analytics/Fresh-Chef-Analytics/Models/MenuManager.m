//
//  MenuManager.m
//  Fresh-Chef-Analytics
//
//  Created by selinons on 7/17/19.
//  Copyright © 2019 julia@ipearl.net. All rights reserved.
//

#import "MenuManager.h"
#import "Helpful_funs.h"

@implementation MenuManager
// singleton generates a single instance and initiates itself
+ (instancetype)shared {
    static MenuManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}
- (void)fetchMenuItems:(PFUser *)restaurant withCompletion:(void (^)(NSMutableDictionary * _Nonnull, NSError * _Nullable))fetchedDishes
{
    // construct PFQuery
    PFQuery *dishQuery;
    dishQuery = [Dish query];
    [dishQuery whereKey:@"restaurantID" equalTo:restaurant.objectId];
    dishQuery.limit = 20;
    
    // fetch data asynchronously
    [dishQuery findObjectsInBackgroundWithBlock:^(NSArray<Dish *> * _Nullable dishes, NSError * _Nullable error) {
        self.dishes = dishes;
        [self categorizeDishes];
        NSLog(@"Step 3");
        
        fetchedDishes(self.categoriesOfDishes, nil);
    }];
}

- (void)setOrderedDicts {
    // set ordered dictionaries
    self.dishesByFreq = [self orderDictionary:self.categoriesOfDishes byType:@"orderFrequency"];
    self.dishesByRating =[self orderDictionary:self.categoriesOfDishes byType:@"rating"];
    self.dishesByPrice = [self orderDictionary:self.categoriesOfDishes byType:@"price"];
}

- (NSMutableDictionary *)orderDictionary:(NSMutableDictionary *)dict byType:(NSString *)orderType
{
    NSMutableDictionary *orderedDict = [[NSMutableDictionary alloc] init];
    for(NSString *key in dict){
        orderedDict[key] = [[Helpful_funs shared] orderArray:dict[key] byType:orderType];
    }
    return orderedDict;
}

- (void)removeDishFromTable:(Dish *)delDish withCompletion:(void (^)(NSMutableDictionary * _Nonnull, NSError * _Nullable))removedDish
{
    PFQuery *dishQuery;
    dishQuery = [Dish query];
    [dishQuery whereKey:@"objectId" equalTo:delDish.objectId];
    [dishQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable dishes, NSError *  error) {
        for (Dish *dish in dishes)
        {
            [dish deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (succeeded)
                {
                    NSLog(@"Object removed");
                    [self fetchMenuItems:PFUser.currentUser withCompletion:^(NSMutableDictionary * _Nonnull categoriesOfDishes, NSError * _Nullable error) {
                        if (error==nil)
                        {
                            self.categoriesOfDishes = categoriesOfDishes;
                            NSLog(@"New menu successfuly fetched");
                            NSLog(@"Step 4");

                            removedDish(self.categoriesOfDishes, nil);

                        }
                    }];
                }
                else
                {
                    NSLog(@"%@", error.localizedDescription);
                    
                }
            }];
        }
    }];


}

- (void) categorizeDishes
{
    self.categoriesOfDishes = [[NSMutableDictionary alloc] init];
    NSArray * dishesOfType;
    
    for (Dish *dish in self.dishes)
    {
        [self addDishToDict:dish toArray:dishesOfType];
    }
    NSLog(@"Step 2");
}

- (void) addDishToDict : (Dish *) dish toArray: (NSArray *) dishesOfType
{
    if (self.categoriesOfDishes[dish.type]!=nil)
    {
        dishesOfType = self.categoriesOfDishes[dish.type];
        dishesOfType = [dishesOfType arrayByAddingObject:dish];
        
    }
    else
    {
        dishesOfType = [NSArray arrayWithObject:dish];
    }
    [self.categoriesOfDishes setObject:dishesOfType forKey:dish.type];
}

- (void)setTop3Bottom3Dict
{
    if (self.dishes.count != nil)
    {
        Dish *checkDish = [self.dishes objectAtIndex:0];
        if (![checkDish.name isEqualToString:@"test"]){
            // make sorted array of every menu item
            NSLog(@"dishes %@", self.dishes);
            NSArray *dishesByFreqArray = [[Helpful_funs shared] orderArray:self.dishes byType:@"orderFrequency"];
            NSArray *dishesByRatingArray = [[Helpful_funs shared] orderArray:self.dishes byType:@"rating"];
            // take top 3 and bottom 3 based on reviews/frequency
            NSRange first3Range = NSMakeRange(0, 3);
            NSRange last3Range = NSMakeRange(([dishesByFreqArray count] - 3), 3);
            NSArray *top3Freq = [dishesByFreqArray subarrayWithRange:first3Range];
            NSArray *bottom3Freq = [dishesByFreqArray subarrayWithRange:last3Range];
            NSArray *top3Rating = [dishesByRatingArray subarrayWithRange:first3Range];
            NSArray *bottom3Rating = [dishesByRatingArray subarrayWithRange:last3Range];
            self.top3Bottom3Freq = [[NSMutableDictionary alloc] initWithObjects:@[top3Freq, bottom3Freq] forKeys:@[@"top3", @"bottom3"]];
            self.top3Bottom3Rating = [[NSMutableDictionary alloc] initWithObjects:@[top3Rating, bottom3Rating] forKeys:@[@"top3", @"bottom3"]];
        }
    }
}

// get overal ranked arrays of data and set threshold indices
//- (void)setThresholdIndices
//{
////    self.thresholdsRating = @[@0.33f, @0.66f]; // will use later if user can change values
//    float bottomThreshRating = 0.33f;
//    float upperThresh = 0.66f;
//
//    //RATING
//    // get length of menu and find indices closest to bottom threshold percentile and upper
//    NSUInteger menuLength = [self.dishes count];
//    NSUInteger lowerIndex = lroundf(bottomThresh * menuLength);
//    NSUInteger upperIndex = lroundf(upperThresh * menuLength);
//    //rank all dishes into an array
//    NSArray *rankedDishesByRating = [[Helpful_funs shared] orderArray:self.dishes byType:@"rating"];
//    for (int i = 0; i < [rankedDishesByRating count]; i++) {
//        Dish *dish = rankedDishesByRating[i];
//        if (i <= lowerIndex) {
//            dish.ratingCategory = @"low";
//        } else if (i > lowerIndex && i < upperIndex) {
//            dish.ratingCategory = @"medium";
//        } else {
//            dish.ratingCategory = @"high";
//        }
//    }
//    NSLog(@"dishes ranked by rating: %@", rankedDishesByRating);
//}

- (void)setDishRankings
{
    //rank all dishes into an array
    float bottomThreshRating = 0.33f;
    float upperThreshRating = 0.66f;
    float bottomThreshFreq = 0.33f;
    float upperThreshFreq = 0.66f;
    float bottomThreshProfit = 0.33f;
    float upperThreshProfit = 0.66f;
    // get length of menu and find indices closest to lower and upper threshold percentile
    NSUInteger menuLength = [self.dishes count];
    //RATING
    NSUInteger lowerIndexRating = lroundf(bottomThreshRating * menuLength);
    NSUInteger upperIndexRating = lroundf(upperThreshRating * menuLength);
    NSUInteger lowerIndexFreq = lroundf(bottomThreshFreq * menuLength);
    NSUInteger upperIndexFreq = lroundf(upperThreshFreq * menuLength);
//    NSUInteger lowerIndexProfit = lroundf(bottomThreshProfit * menuLength);
//    NSUInteger upperIndexProfit = lroundf(upperThreshProfit * menuLength);
    //rank all dishes into an array
    NSArray *rankedDishesByRating = [[Helpful_funs shared] orderArray:self.dishes byType:@"rating"];
    NSArray *rankedDishesByFreq = [[Helpful_funs shared] orderArray:self.dishes byType:@"orderFrequency"];
//    NSArray *rankedDishesByProfit = [[Helpful_funs shared] orderArray:self.dishes byType:@"profit"];
    for (int i = 0; i < menuLength; i++) {
        Dish *dish = rankedDishesByRating[i];
        // Check Rating
        if (i <= lowerIndexRating) {
            dish.ratingCategory = @"high"; // if dish is early in array then it has high rating
        } else if (i > lowerIndexRating && i < upperIndexRating) {
            dish.ratingCategory = @"medium";
        } else {
            dish.ratingCategory = @"low"; // if dish is later in array then it has a low rating
        }
    }
    // Check Frequency
    for (int i = 0; i < menuLength; i++) {
        Dish *dish = rankedDishesByFreq[i];
        if (i <= lowerIndexFreq) {
            dish.freqCategory = @"high"; // if dish is early in array then it has high freq
        } else if (i > lowerIndexFreq && i < upperIndexFreq) {
            dish.freqCategory = @"medium";
        } else {
            dish.freqCategory = @"low"; // if dish is later in array then it has a low freq
        }
    }
    // Check Profit
//    for (int i = 0; i < [rankedDishesByProfit count]; i++) {
//        Dish *dish = rankedDishesByRating[i];
//        if (i <= lowerIndexProfit) {
//            dish.profitCategory = @"high"; // if dish is early in array then it has high profit
//        } else if (i > lowerIndexProfit && i < upperIndexProfit) {
//            dish.profitCategory = @"medium";
//        } else {
//            dish.profitCategory = @"low"; // if dish is later in array then it has a low profit
//        }
//    }

}
@end
