//
//  MyAccountVC.m
//  FingoShop
//
//  Created by Perumal on 01/05/17.
//  Copyright © 2017 fis. All rights reserved.
//

#import "MyAccountVC.h"
#import "SVProgressHUD.h"

@interface MyAccountVC ()
{
    NSString *serviceType;
}

@end

@implementation MyAccountVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self callGetAccountInfo];
    
    
}

-(void)callGetAccountInfo
{
    [SVProgressHUD showWithStatus:@"Please wait" maskType:SVProgressHUDMaskTypeBlack]; // Progress
    
    seviceconn = [[ServiceConnection alloc]init];
    seviceconn.delegate = self;
    serviceType = @"GetAccountInfo";
    [seviceconn GetCustomerAccount];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveButtonAction:(id)sender {
}
- (IBAction)changePasswordButtonAction:(id)sender {
}



#pragma mark - ServiceConnection Delegate Methods

- (void)jsonData:(NSDictionary *)jsonDict
{
    if (jsonDict != nil){
        if ([serviceType isEqualToString:@"GetAccountInfo"])
        {
            
            
            
       }
        else {
           // if (jsonDict.count == 0) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"FINGOSHOP" message:[jsonDict objectForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:ok];
                
                [self presentViewController:alertController animated:YES completion:nil];
           // }
                   }
        
    }
    
    
    [SVProgressHUD dismiss];
    
}



- (void)errorMessage:(NSString *)errMsg
{
    [SVProgressHUD dismiss];
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
