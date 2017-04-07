//
//  SelectFileViewController.m
//  Copyright © 2017 Sequencing.com. All rights reserved
//

#import "SelectFileViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppChainsHelper.h"

// ADD THIS IMPORT
#import "SQOAuth.h"
#import "SQToken.h"
#import "SQFilesAPI.h"
#import "NetworkManager.h"
#import "FilesFilter.h"


#define kMainQueue dispatch_get_main_queue()



@interface SelectFileViewController ()

// activity indicator with label properties
@property (retain, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (retain, nonatomic) UIView    *messageFrame;
@property (retain, nonatomic) UILabel   *strLabel;


@property (weak, nonatomic) IBOutlet UIView     *buttonView;
@property (weak, nonatomic) IBOutlet UIButton   *buttonSelectFile;

@property (weak, nonatomic) IBOutlet UISegmentedControl *getFileInfo;
@property (weak, nonatomic) IBOutlet UIView     *segmentedControlView;

@property (weak, nonatomic) IBOutlet UILabel    *selectedFileTagline;
@property (weak, nonatomic) IBOutlet UILabel    *selectedFileName;
@property (weak, nonatomic) IBOutlet UILabel *value;
@property (weak, nonatomic) IBOutlet UILabel *perfectMatch;


@property (strong, nonatomic) NSDictionary      *selectedFile;
@property (strong, nonatomic) GeneticFile       *selectedGeneticFile;
@property (strong, nonatomic) NSArray           *allFiles;
@property (strong, nonatomic) NSArray           *filteredFiles;
@property (assign, nonatomic) NSNumber         *index;


@end



@implementation SelectFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Using genetic file";
    
    // prepare activity indicator items
    self.messageFrame = [UIView new];
    self.activityIndicator = [UIActivityIndicatorView new];
    self.strLabel = [UILabel new];
    
    
    // adjust buttons view
    self.buttonView.layer.cornerRadius = 5;
    self.buttonView.layer.masksToBounds = YES;
    self.buttonView.layer.borderColor = [UIColor colorWithRed:35/255.0 green:121/255.0 blue:254/255.0 alpha:1.0].CGColor;
    self.buttonView.layer.borderWidth = 1.f;
    
    self.segmentedControlView.layer.cornerRadius = 5;
    self.segmentedControlView.layer.masksToBounds = YES;
    
    [self.selectedFileTagline setHidden:YES];
    [self.selectedFileName setHidden:YES];
    [self.getFileInfo setHidden:YES];
    [self.segmentedControlView setHidden:YES];
    
    self.value.text = nil;
    self.perfectMatch.text = nil;
    [self.value setHidden:YES];
    [self.perfectMatch setHidden:YES];
}


- (void)dealloc {
    // unsubscribe self as delegate to SQFileSelectorProtocol
    [[SQFilesAPI sharedInstance] setDelegate:nil];
}


- (void)viewDidAppear:(BOOL)animated {
    if (!self.filteredFiles) {
        [self startActivityIndicatorWithTitle:@"Loading all files"];
        [[SQOAuth sharedInstance] token:^(SQToken *token, NSString *accessToken) {
            NetworkManager *network = [[NetworkManager alloc] init];
            [network getForFilesWithToken:accessToken onSuccess:^(NSArray *array) {
                
                dispatch_async(kMainQueue, ^{
                    [self stopActivityIndicator];
                    self.allFiles = array;
                    self.filteredFiles = [FilesFilter filterAllFiles:array];
                    [self stopActivityIndicator];
                });
                
                
            } onFailure:^(NSError *error) {
                
            }];
        }];
    }
    
}


#pragma mark - Actions

- (IBAction)loadFilesPressed:(id)sender {
    self.view.userInteractionEnabled = NO;
    [self startActivityIndicatorWithTitle:@"Loading files"];
    
    [self.selectedFileTagline setHidden:YES];
    [self.selectedFileName setHidden:YES];
    [self.getFileInfo setHidden:YES];
    [self.segmentedControlView setHidden:YES];
    self.value.text = nil;
    self.perfectMatch.text = nil;
    [self.value setHidden:YES];
    [self.perfectMatch setHidden:YES];
    
    
    [[SQFilesAPI sharedInstance] showFilesWithTokenProvider:[SQOAuth sharedInstance]
                                            showCloseButton:YES
                                   previouslySelectedFileID:nil
                                                   delegate:self];
}



- (IBAction)signOutButtonPressed:(id)sender {
    [_delegate userDidSignOut];
}




#pragma mark -
#pragma mark SQFileSelectorProtocol

- (void)selectedGeneticFile:(NSDictionary *)file {
    NSLog(@"handleFileSelected: %@", file);
    if (file && [[file allKeys] count] > 0) {
        dispatch_async(kMainQueue, ^{
            self.view.userInteractionEnabled = YES;
            [self stopActivityIndicator];
            
            _selectedFile = file;
            
            GeneticFile *geneticFile = [[GeneticFile alloc] init];
            geneticFile.name    = [file objectForKey:@"FriendlyDesc1"];
            geneticFile.fileID  = [file objectForKey:@"Id"];
            geneticFile.sex     = [file objectForKey:@"Sex"];
            self.selectedGeneticFile = geneticFile;
            
            NSString *fileCategory = [file objectForKey:@"FileCategory"];
            NSString *fileName;
            
            if ([fileCategory containsString:@"Community"]) {
                fileName = [NSString stringWithFormat:@"%@ - %@", [file objectForKey:@"FriendlyDesc1"], [file objectForKey:@"FriendlyDesc2"]];
            } else {
                fileName = [NSString stringWithFormat:@"%@", [file objectForKey:@"Name"]];
            }
            
            _selectedFileName.text = fileName;
            
            [self.selectedFileTagline setHidden:NO];
            [self.selectedFileName setHidden:NO];
            [self.getFileInfo setHidden:NO];
            [self.segmentedControlView setHidden:NO];
        });
        
    } else {
        dispatch_async(kMainQueue, ^{
            [self stopActivityIndicator];
            self.view.userInteractionEnabled = YES;
            [self showAlertWithMessage:@"Sorry, can't load files"];
            
            [self.selectedFileTagline setHidden:YES];
            [self.selectedFileName setHidden:YES];
            [self.getFileInfo setHidden:YES];
            [self.segmentedControlView setHidden:YES];
        });
    }
}


- (void)errorWhileReceivingGeneticFiles:(NSError *)error {
    dispatch_async(kMainQueue, ^{
        [self stopActivityIndicator];
        self.view.userInteractionEnabled = YES;
        NSLog(@"error: %@", error);
    });
}


- (void)closeButtonPressed {
    dispatch_async(kMainQueue, ^{
        [self stopActivityIndicator];
        self.view.userInteractionEnabled = YES;
    });
}





#pragma mark - Get genetic information

- (IBAction)getGeneticInfoPressed:(UISegmentedControl *)sender {
    self.value.text = nil;
    self.perfectMatch.text = nil;
    [self.value setHidden:YES];
    [self.perfectMatch setHidden:YES];
    
    if (_selectedFile && [[_selectedFile allKeys] count] > 0) {
        NSString *selectedSegmentItem = [sender titleForSegmentAtIndex:sender.selectedSegmentIndex];
        
        if ([selectedSegmentItem containsString:@"power"]) {
            // load vitamin info
            [self checkForPower];
            
        } else {
            // load melanoma info
            [self checkForEndurance];
        }
    } else {
        [self showAlertWithMessage:@"Please select genetic file"];
    }
}




#pragma mark - Power marker check

- (void)checkForPower {
    dispatch_async(kMainQueue, ^{
        if (self.selectedFile) {
            [self startActivityIndicatorWithTitle:[NSString stringWithFormat:@"check for Power marker for %@", self.selectedGeneticFile.name]];
            self.view.userInteractionEnabled = NO;
            
            AppChainsHelper *appChainsHelper = [[AppChainsHelper alloc] init];
            [appChainsHelper requestForChain17BasedOnFileID:self.selectedGeneticFile.fileID
                                                accessToken:[SQOAuth sharedInstance]
                                             withCompletion:^(NSString *value) {
                                                 
                                                 dispatch_async(kMainQueue, ^{
                                                     [self stopActivityIndicator];
                                                     self.view.userInteractionEnabled = YES;
                                                     [self.value setHidden:NO];
                                                     
                                                     if ([value containsString:@"True"]) {
                                                         self.value.text = [NSString stringWithFormat:@"%@ has Power marker", self.selectedGeneticFile.name];
                                                         self.index = nil;
                                                         [self.perfectMatch setHidden:NO];
                                                         self.perfectMatch.text = @"will likely have power childred with spouse:";
                                                         [self findPowerMatch];
                                                         
                                                     } else {
                                                         self.index = nil;
                                                         [self.perfectMatch setHidden:NO];
                                                         self.value.text = [NSString stringWithFormat:@"%@ has no Power marker", self.selectedGeneticFile.name];
                                                         self.perfectMatch.text = @"there is no point to search for match";
                                                     }
                                                 });
                                             }];
        } else {
            dispatch_async(kMainQueue, ^{
                //[self.vitaminDInfo setHidden:YES];
                [self showAlertWithMessage:@"Corrupted user info, can't load information."];
            });
        }
    });
}



- (void)findPowerMatch {
    dispatch_async(kMainQueue, ^{
        if (!self.index)
            self.index = [NSNumber numberWithInteger:0];
        else {
            int indexNew = (int)self.index.integerValue;
            indexNew++;
            self.index = [NSNumber numberWithInteger:indexNew];
        }
        
        if (self.index.integerValue < [self.filteredFiles count]) {
            
            GeneticFile *file = self.filteredFiles[self.index.integerValue];
            [self checkForPowerMarkerForFile:file];
            
        } else {
            self.index = nil;
            return;
        }
    });
}


- (void)checkForPowerMarkerForFile:(GeneticFile *)file {
    if (self.selectedGeneticFile.sex != file.sex) {
        
        if ([self canCheckForCurrentFile:file]) {
            
            [self startActivityIndicatorWithTitle:[NSString stringWithFormat:@"check for %@", file.name]];
            self.view.userInteractionEnabled = NO;
            
            AppChainsHelper *appChainsHelper = [[AppChainsHelper alloc] init];
            [appChainsHelper requestForChain17BasedOnFileID:file.fileID
                                                accessToken:[SQOAuth sharedInstance]
                                             withCompletion:^(NSString *value) {
                                                 
                                                 dispatch_async(kMainQueue, ^{
                                                     
                                                     [self stopActivityIndicator];
                                                     self.view.userInteractionEnabled = YES;
                                                     
                                                     if ([value containsString:@"True"]) {
                                                         NSMutableString *string = [NSMutableString stringWithString:self.perfectMatch.text];
                                                         [string appendString:[NSString stringWithFormat:@"\n%@", file.name]];
                                                         
                                                         self.perfectMatch.text = [NSString stringWithString:string];
                                                     }
                                                     
                                                     [self findPowerMatch];
                                                 });
                                             }];
            
        } else
            [self findPowerMatch];
    } else
        [self findPowerMatch];
}





#pragma mark - Endurance check

- (void)checkForEndurance {
    dispatch_async(kMainQueue, ^{
        if (self.selectedFile) {
            [self startActivityIndicatorWithTitle:[NSString stringWithFormat:@"check for Endurance marker for %@", self.selectedGeneticFile.name]];
            self.view.userInteractionEnabled = NO;
            
            AppChainsHelper *appChainsHelper = [[AppChainsHelper alloc] init];
            [appChainsHelper requestForChain18BasedOnFileID:self.selectedGeneticFile.fileID
                                                accessToken:[SQOAuth sharedInstance]
                                             withCompletion:^(NSString *value) {
                                                 
                                                 dispatch_async(kMainQueue, ^{
                                                     [self stopActivityIndicator];
                                                     self.view.userInteractionEnabled = YES;
                                                     [self.value setHidden:NO];
                                                     
                                                     if ([value containsString:@"True"]) {
                                                         self.value.text = [NSString stringWithFormat:@"%@ has Endurance marker", self.selectedGeneticFile.name];
                                                         self.index = nil;
                                                         [self.perfectMatch setHidden:NO];
                                                         self.perfectMatch.text = @"will likely have childred with endurance with spouse:";
                                                         [self findEnduranceMatch];
                                                         
                                                     } else {
                                                         self.index = nil;
                                                         [self.perfectMatch setHidden:NO];
                                                         self.value.text = [NSString stringWithFormat:@"%@ has no Endurance marker", self.selectedGeneticFile.name];
                                                         self.perfectMatch.text = @"there is no point to search for match";
                                                     }
                                                 });
                                             }];
        } else {
            dispatch_async(kMainQueue, ^{
                //[self.vitaminDInfo setHidden:YES];
                [self showAlertWithMessage:@"Corrupted user info, can't load information."];
            });
        }
    });
}


- (void)findEnduranceMatch {
    dispatch_async(kMainQueue, ^{
        if (!self.index)
            self.index = [NSNumber numberWithInteger:0];
        else {
            int indexNew = (int)self.index.integerValue;
            indexNew++;
            self.index = [NSNumber numberWithInteger:indexNew];
        }
        
        if (self.index.integerValue < [self.filteredFiles count]) {
            
            GeneticFile *file = self.filteredFiles[self.index.integerValue];
            [self checkForEnduranceMarkerForFile:file];
            
        } else {
            self.index = nil;
            return;
        }
    });
}


- (void)checkForEnduranceMarkerForFile:(GeneticFile *)file {
    if (self.selectedGeneticFile.sex != file.sex) {
        
        if ([self canCheckForCurrentFile:file]) {
            [self startActivityIndicatorWithTitle:[NSString stringWithFormat:@"check for %@", file.name]];
            self.view.userInteractionEnabled = NO;
            
            AppChainsHelper *appChainsHelper = [[AppChainsHelper alloc] init];
            [appChainsHelper requestForChain18BasedOnFileID:file.fileID
                                                accessToken:[SQOAuth sharedInstance]
                                             withCompletion:^(NSString *value) {
                                                 
                                                 dispatch_async(kMainQueue, ^{
                                                     
                                                     [self stopActivityIndicator];
                                                     self.view.userInteractionEnabled = YES;
                                                     
                                                     if ([value containsString:@"True"]) {
                                                         NSMutableString *string = [NSMutableString stringWithString:self.perfectMatch.text];
                                                         [string appendString:[NSString stringWithFormat:@"\n%@", file.name]];
                                                         
                                                         self.perfectMatch.text = [NSString stringWithString:string];
                                                     }
                                                     
                                                     [self findEnduranceMatch];
                                                 });
                                             }];
        } else
            [self findEnduranceMatch];
        
    } else
        [self findEnduranceMatch];
}


- (BOOL)canCheckForCurrentFile:(GeneticFile *)file {
    BOOL allowed = YES;
    
    if ([self.selectedGeneticFile.name containsString:@"Homer"]) {
        if ([file.name containsString:@"Lisa"] ||
            [file.name containsString:@"Maggie"]) {
            allowed = NO;
        }
    }
    
    if ([self.selectedGeneticFile.name containsString:@"Marge"]) {
        if ([file.name containsString:@"Bart"]) {
            allowed = NO;
        }
    }
    
    return allowed;
}







#pragma mark - Activity Indicator

- (void)startActivityIndicatorWithTitle:(NSString *)title {
    dispatch_async(kMainQueue, ^{
        self.strLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 270, 30)];
        self.strLabel.text = title;
        self.strLabel.font = [UIFont systemFontOfSize:13.f];
        self.strLabel.textColor = [UIColor grayColor];
        
        CGFloat xPos = self.view.frame.size.width / 2 - 150;
        self.messageFrame = [[UIView alloc] initWithFrame:CGRectMake(xPos, 60, 300, 30)];
        self.messageFrame.layer.cornerRadius = 15;
        self.messageFrame.backgroundColor = [UIColor clearColor];
        
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.activityIndicator.frame = CGRectMake(0, 0, 30, 30);
        [self.activityIndicator startAnimating];
        
        [self.messageFrame addSubview:self.activityIndicator];
        [self.messageFrame addSubview:self.strLabel];
        [self.view addSubview:self.messageFrame];
        
    });
}


- (void)stopActivityIndicator {
    dispatch_async(kMainQueue, ^{
        [self.activityIndicator stopAnimating];
        [self.messageFrame removeFromSuperview];
    });
}



#pragma mark -
#pragma mark Alert message

- (void)showAlertWithMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *close = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:close];
    [self presentViewController:alert animated:YES completion:nil];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
