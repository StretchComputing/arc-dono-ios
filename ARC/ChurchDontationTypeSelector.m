//
//  ChurchDontationTypeSelector.m
//  HolyDutch
//
//  Created by Nick Wroblewski on 10/16/13.
//
//

#import "ChurchDontationTypeSelector.h"
#import "rSkybox.h"
#import "ChurchAmountSingleType.h"
#import "ChurchAmountMultipleTypes.h"
#import "MFSideMenu.h"

@interface ChurchDontationTypeSelector ()

@end

@implementation ChurchDontationTypeSelector

-(void)viewWillAppear:(BOOL)animated{
    if (self.isHome) {
        [self.goBackButton setImage:[UIImage imageNamed:@"menuIcon"] forState:UIControlStateNormal];
        self.titleLabel.text = @"Home";

    }else{
        self.titleLabel.text = @"Donation Type(s)";

    }

}
- (void)viewDidLoad
{
    
    UIView *tmpView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    tmpView.backgroundColor = [UIColor lightGrayColor];
    
    self.myTableView.tableFooterView = tmpView;
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.merchantNameText.text = self.myMerchant.name;
    
    self.selectedRows = [NSMutableArray array];
    [self.myTableView reloadData];
    
    self.nextButton.text = @"Continue";
}


-(void)next{
    
    if ([self.selectedRows count] > 0) {
        
        
        if ([self.selectedRows count] == 1) {
            
            [self performSegueWithIdentifier:@"single" sender:self];
        }else{
            [self performSegueWithIdentifier:@"multiple" sender:self];
        }
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Select A Donation." message:@"You must select a donation area to continue.  If you wish to make a general donation, please select 'General'." delegate:self cancelButtonTitle:@"General" otherButtonTitles:@"Ok", nil];
        [alert show];
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0) {
       
        NSLog(@"General Donation");
        
    }
    
}

-(void)goBack{

    if (self.isHome) {
        [self.navigationController.sideMenu toggleLeftSideMenu];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    @try {
        
        NSUInteger row = [indexPath row];
        
        if (row == -1) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"dontCareCell"];

            return cell;

        }else{
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"optionCell"];

            SteelfishBoldLabel *nameLabel = (SteelfishBoldLabel *)[cell.contentView viewWithTag:1];
            
            NSDictionary *donationType = [self.myMerchant.donationTypes objectAtIndex:row];
            
            nameLabel.text = [donationType valueForKey:@"Description"];
            
            
            if ([self.selectedRows indexOfObject:[NSString stringWithFormat:@"%d", row]] != NSNotFound) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }else{
                cell.accessoryType = UITableViewCellAccessoryNone;

            }
            
            return cell;

        }
     
        
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ChurchDonationTypeSelector.tableView" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == -1) {
        return 74;
    }
    return 44;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    

    if (indexPath.row == -1) {
        //Go to next screen
        [self performSegueWithIdentifier:@"single" sender:self];
    }else{
        
        NSString *rowString = [NSString stringWithFormat:@"%d", indexPath.row];
        
        
        if ([self.selectedRows indexOfObject:rowString] == NSNotFound) {
            [self.selectedRows addObject:rowString];
        }else{
            [self.selectedRows removeObjectAtIndex:[self.selectedRows indexOfObject:rowString]];
            
        }
        
        [self.myTableView reloadData];
    }
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    @try {
        
        if ([[segue identifier] isEqualToString:@"single"]) {
            
            ChurchAmountSingleType *single = [segue destinationViewController];
            single.myMerchant = self.myMerchant;
            single.isHome = NO;
            int index = [[self.selectedRows objectAtIndex:0] intValue];
            
            single.donationType = [self.myMerchant.donationTypes objectAtIndex:index];
            
            
        }else if ([[segue identifier] isEqualToString:@"multiple"]) {

            
            ChurchAmountMultipleTypes *multiple = [segue destinationViewController];
            multiple.myMerchant = self.myMerchant;
        
            NSMutableArray *types = [NSMutableArray array];
            
            for (int i = 0; i < [self.selectedRows count]; i++) {
                int index = [[self.selectedRows objectAtIndex:i] intValue];

                [types addObject:[self.myMerchant.donationTypes objectAtIndex:index]];
            }
        
            multiple.selectedDonations = [NSMutableArray arrayWithArray:types];
            
        }
        
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ChurchDonationTypeSelector.prepareForSegue" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self.myMerchant.donationTypes count];
}


@end
