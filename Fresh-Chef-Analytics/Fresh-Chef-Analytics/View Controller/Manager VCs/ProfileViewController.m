//
//  ProfileViewController.m
//  Fresh-Chef-Analytics
//
//  Created by jpearl on 7/16/19.
//  Copyright © 2019 julia@ipearl.net. All rights reserved.
//

#import "ProfileViewController.h"
#import "AppDelegate.h"
#import "LoginViewController.h"

@interface ProfileViewController ()

@property (nonatomic, assign) BOOL isEditable;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Set restaurant name, category and price labels
    self.user = [PFUser currentUser];
    self.restaurantNameLabel.text = self.user[@"username"];
    NSString *category = self.user[@"category"];
    self.isEditable = NO; // the profile is not editable initially
    if(category != nil){
        self.restaurantCategoryLabel.text = self.user[@"category"];
    } else {
        self.restaurantCategoryLabel.text = @"Set Restaurant Category";
    }
    NSString *price = self.user[@"price"];
    if (price != nil) {
        self.restaurantPriceLabel.text = price;
    } else {
        self.restaurantPriceLabel.text = @"Set Restaurant Price Range";
    }
    // show label and hide text field initially
    [self showLabels:YES];
    if(self.user[@"image"] != nil){
        [self setProfilePicture];
    }
}

- (IBAction)didTapLogout:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    appDelegate.window.rootViewController = loginViewController;
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        // PFUser.current() will now be nil
    }];
}

- (IBAction)didTapEdit:(id)sender {
    // not implemented yet, should allow user to edit profile
    if(self.isEditable == NO){
        self.isEditable = YES;
        //change edit label to 'save' and logout button to 'cancel'
        self.editButton.title = @"Save";
        //add logout --> cancel
        //..............
        
        // show text fields and hide labels
        [self showLabels:NO];
        //set text fields
        self.restaurantNameField.text = self.restaurantNameLabel.text;
        self.restaurantCategoryField.text = self.restaurantCategoryLabel.text;
        self.restaurantPriceField.text = self.restaurantPriceLabel.text;
    } else {
        //User pressed 'save' button
        self.isEditable = NO;
        self.editButton.title = @"Edit";
        // Hide text fields, show labels, and save values
        [self showLabels:YES];
        //save values to PFUser
        self.user[@"username"] = self.restaurantNameField.text;
        self.user[@"category"] = self.restaurantCategoryField.text;
//        self.user[@"price"] = self.restaurantPriceField;
        [self.user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if(succeeded){
                NSLog(@"successfully saved updates");
                // set labels to correspond to inputs
                self.restaurantNameLabel.text = self.restaurantNameField.text;
                self.restaurantCategoryLabel.text = self.restaurantCategoryField.text;
                self.restaurantPriceLabel.text = self.restaurantPriceField.text;
            } else {
                NSLog(@"Error saving updates: %@", error.localizedDescription);
            }
        }];
    }
}

-(void) showLabels: (BOOL)trueFalse {
    // if trueFalse is YES then show labels and hide fields
    // if trueFalse is NO then do the reverse
    //name
    self.restaurantNameLabel.hidden = !trueFalse;
    self.restaurantNameField.enabled = !trueFalse;
    self.restaurantNameField.hidden = trueFalse;
    //category
    self.restaurantCategoryLabel.hidden = !trueFalse;
    self.restaurantCategoryField.enabled = !trueFalse;
    self.restaurantCategoryField.hidden = trueFalse;
    //price
    self.restaurantPriceLabel.hidden = !trueFalse;
    self.restaurantPriceField.enabled = !trueFalse;
    self.restaurantPriceField.hidden = trueFalse;
    self.tapToEditLabel.hidden = trueFalse;
}

- (IBAction)didTapBackground:(id)sender {
    //dismiss keyboard
    [self.view endEditing:YES];
}

- (IBAction)didTapProfilePic:(id)sender {
    if(self.isEditable == YES){
        NSLog(@"tapped camera image");
        UIImagePickerController *imagePickerVC = [UIImagePickerController new];
        imagePickerVC.delegate = self;
        imagePickerVC.allowsEditing = YES;
        // if camera is available, use it, else, use camera roll
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        else {
            NSLog(@"Camera 🚫 available so we will use photo library instead");
            imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        [self presentViewController:imagePickerVC animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    // Get the image captured by the UIImagePickerController
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    // Resize image to avoid memory issues in Parse
//    UIImage *resizedImage = [self resizeImage:editedImage withSize:CGSizeMake(400, 400)];
    self.user[@"image"] = [self getPFFileFromImage:editedImage];
    [self.user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(succeeded){
            NSLog(@"successfully saved profile picture");
            [self setProfilePicture];
        } else {
            NSLog(@"Error saving profile image: %@", error.localizedDescription);
        }
    }];
    // Dismiss UIImagePickerController to go back to original view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image {
    // check if image is not nil
    if (!image) {
        return nil;
    }
    NSData *imageData = UIImagePNGRepresentation(image);
    // get image data and check if that is not nil
    if (!imageData) {
        return nil;
    }
    return [PFFileObject fileObjectWithName:@"image.png" data:imageData];
}

- (void)setProfilePicture {
    PFFileObject *userImageFile = self.user[@"image"];
    [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if(!error){
            self.restaurantProfileImage.image = [UIImage imageWithData:imageData];
        }
    }];

//    self.restaurantProfileImage.image = self.user[@"image"];
//    [self.restaurantProfileImage loadInBackground];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
