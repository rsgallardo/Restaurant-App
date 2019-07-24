
#import "YelpAPIManager.h"
#import "Parse/Parse.h"

@implementation YelpAPIManager

+ (instancetype)shared {
    static YelpAPIManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });

    return sharedManager;
}

-(void)fetchCompetitors{
    NSMutableArray *placeholder = [[NSMutableArray alloc] init];
    self.competitorArray = [[NSMutableArray alloc] initWithObjects:placeholder, placeholder, placeholder, nil];
    PFUser *currentUser = [PFUser currentUser];
    self.userParameters = [[NSMutableArray alloc] initWithObjects:currentUser[@"address"], currentUser[@"category"], currentUser[@"Price"], nil];
   // [self locationTopRatings:@"NYC" withCategory:@"pizza" withPrice:@"3" withIndex:0];
    [self locationTopRatings:self.userParameters[0] withCategory:@"none" withPrice:@"none" withIndex:0];
    [self locationTopRatings:self.userParameters[0] withCategory:self.userParameters[1] withPrice:@"none" withIndex:1];
   // [self locationTopRatings:self.userParameters[0] withCategory:@"none" withPrice:self.userParameters[2] withIndex:2];
    NSLog(@"hello!");

}

-(void)locationTopRatings:(NSString*)locationRes withCategory:(nullable NSString *)categoryRes withPrice:(nullable NSString *)priceRes withIndex:(NSUInteger)index{
        NSDictionary *headers = @{
                                  @"Authorization": @"Bearer Z505A_B9SNUBRJYRkioQ9NX8ZD9AnREWx3MqrxHSny1dop_ox6v0Ptx2-qbqX6fktt79CfqzXYdCcc6j3iE6BMTK6QHsDThNMbPYSf1mWXec1p7zsC6MupJVmkU2XXYx",
                                  @"User-Agent": @"PostmanRuntime/7.15.0",
                                @"Accept": @"*/*",
                                @"Cache-Control": @"no-cache",
                                @"Postman-Token": @"cdd4afd3-9488-46d1-84eb-b49577689432,71be9541-3f52-4e44-8bcc-098ad7950623",
                                @"Host": @"api.yelp.com",
                                @"cookie": @"__cfduid=d6047e6fa93475a54ffb5335f93cd9fbb1563860170",
                                  @"accept-encoding": @"gzip, deflate",
                                  @"Connection": @"keep-alive"};
                               // @"cache-control": @"no-cache" };

        NSString *baseString = @"https://api.yelp.com/v3/businesses/search?term=restaurants,%20food&type=food,%20restaurants&sort_by=rating&limit=3";
        if (locationRes){
            NSString* locationQuery = [NSString stringWithFormat:@"&location=%@", locationRes];
            baseString = [baseString stringByAppendingString:locationQuery];
        }
        if (!([categoryRes isEqualToString:@"none"])){
            NSString* categoryQuery = [NSString stringWithFormat:@"&categories=%@", categoryRes];
            baseString = [baseString stringByAppendingString:categoryQuery];
        }
        if (!([priceRes isEqualToString:@"none"])){
            NSString* priceQuery = [NSString stringWithFormat:@"&price=%@", priceRes];
            baseString = [baseString stringByAppendingString:priceQuery];
        }
        
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:baseString]
                                                               cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                           timeoutInterval:10.0];
        //  NSMutableURLRequest *request = [NSURLRequest requestWithURL:baseString cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
        [request setHTTPMethod:@"GET"];
        [request setAllHTTPHeaderFields:headers];
        //    //NSDictionary *dataDict = [[NSDictionary alloc] init];
        //    __block NSDictionary *dataDict = nil;
        //    NSURLSession *session = [NSURLSession sharedSession];
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                if (error) {
                    NSString *er = [error localizedDescription];
                    NSLog(@"%@", er);
                } else {
                    NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];

                    [self.competitorArray replaceObjectAtIndex:index withObject:dataDictionary[@"businesses"]];

                    NSLog(@"HELLO %lu", (unsigned long)index);
                    NSLog(@"%@", self.competitorArray[index]);
                }
                
            }];
    
    [dataTask resume];
    
}

@end