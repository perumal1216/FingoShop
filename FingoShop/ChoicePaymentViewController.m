//
//  ChoicePaymentViewController.m
//  FingoShop
//
//  Created by SkoopView on 16/08/16.
//  Copyright © 2016 fis. All rights reserved.
//

#import "ChoicePaymentViewController.h"
#import "PaymentTypeCell.h"
#import "AmountDetailsCell.h"
#import "SVProgressHUD.h"
#import "Constants.h"
#import "PayUUIConstants.h"
#import "PayUSAGetHashes.h"
#import "iOSDefaultActivityIndicator.h"
#import "PayUSAGetTransactionID.h"
#import "NetBankingViewController.h"
#import "PaymentViewController.h"


@interface ChoicePaymentViewController ()
{
    NSString *ServiceType;
    NSMutableDictionary *shippingdict;
    NSString *selectedPaymentMethod,*selectedPaymentType;
    NSDictionary *paymentTypesDict;
    NSString *selected_Method;
    NSIndexPath *selected_indexPath;
    NSIndexPath *oldIndex;
    
}
@property (weak, nonatomic) IBOutlet UITableView *tblPayment;
@property (strong,nonatomic) NSArray *paymentTypesArray;

//payment

@property (strong, nonatomic) PayUModelPaymentParams *paymentParamForPassing;
@property (strong, nonatomic) iOSDefaultActivityIndicator *defaultActivityIndicator;
@property (strong, nonatomic) NSMutableArray *listOfNilKeys;
@property (strong, nonatomic) NSArray * listofAllKeys;
@property (strong, nonatomic) PayUWebServiceResponse *webServiceResponse;
@property (strong, nonatomic) PayUSAGetHashes *getHashesFromServer;
@property (strong, nonatomic) PayUSAGetTransactionID *getTransactionID;

@end

@implementation ChoicePaymentViewController
@synthesize shippingInfo,productInfo;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"shippingInfo %@",shippingInfo);
    
    
    
    shippingdict=[shippingInfo objectForKey:@"shippingAddress"];
    
    NSString *total = [NSString stringWithFormat:@"%@",[shippingdict objectForKey:@"grand_total"]];
    
    double grand_total = [total doubleValue];
    
    if (grand_total > 2000) {
        _paymentTypesArray = @[@"Net Banking",
                               @"Credit Card",
                               @"Debit Card"];
        
    }
    else{
        
        _paymentTypesArray = @[@"Net Banking",
                               @"Credit Card",
                               @"Debit Card",
                               @"Cash on Delivery"];
    }
    
    
    
    
   


    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataReceived:) name:@"passData" object:nil];
    [_tblPayment reloadData];

//    [self CallGetPaymentMethods];
    
    
}




-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    //if (_SelectedShipmentName) {
        [self startPayment:nil];
        [_tblPayment reloadData];
    //}

    self.getTransactionID = [PayUSAGetTransactionID new];
    
}


#pragma mark - UITableView Delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return _paymentTypesArray.count;
    }
    else{
        return 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        PaymentTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"paymentTypeCell"];
        if (cell == nil) {
            cell = [[PaymentTypeCell alloc]initWithFrame:CGRectZero];
        }
//        NSDictionary *dict = [paymentTypesDict objectForKey:[_paymentTypesArray objectAtIndex:indexPath.row]];
//        cell.paymentLabel.text = [dict objectForKey:@"label"];
        
        cell.paymentLabel.text = [_paymentTypesArray objectAtIndex:indexPath.row];
        return cell;
    }
    else {
        
        AmountDetailsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"amountDetailsCell"];
        if (cell == nil) {
            cell = [[AmountDetailsCell alloc]initWithFrame:CGRectZero];
        }
        
        shippingdict=[shippingInfo objectForKey:@"shippingAddress"];
        
        
        [cell.btnSelectShipment addTarget:self action:@selector(btnShipmentClicked) forControlEvents:UIControlEventTouchUpInside];

        cell.lblAmount.text = [NSString stringWithFormat:@"₹ %@",[shippingdict objectForKey:@"subtotal"]];
        //cell.lblDelivery.text = [NSString stringWithFormat:@"₹ 0"];
        cell.lblTotalAmount.text = [NSString stringWithFormat:@"₹ %@",[shippingdict objectForKey:@"grand_total"]];
        if (_SelectedShipmentName) {
            cell.lblShippingMethod.text=_SelectedShipmentName;

        }else
        {
            cell.lblShippingMethod.text=@"";
        }
        
        if (_SelectedShipmentPrice) {
            cell.lblDelivery.text=[NSString stringWithFormat:@"₹ %@",_SelectedShipmentPrice];
            
        }else
        {
            cell.lblDelivery.text= [NSString stringWithFormat:@"₹ %@",[shippingdict objectForKey:@"shipping_amount"]];
        }
        
        // continue button 
        
        if ([selected_Method isEqualToString:@"PaymentSelected"]) {
            [cell.continue_button setHidden:NO];
        }
        else{
             [cell.continue_button setHidden:YES];
        }
        
        NSString *payment_method = [_paymentTypesArray objectAtIndex:selected_indexPath.row];
        
        if ([payment_method isEqualToString:@"Cash on Delivery"]) {
            
            [cell.continue_button setTitle:@"PLACE ORDER" forState:UIControlStateNormal];
            
        }else{
            
            [cell.continue_button setTitle:@"CONTINUE" forState:UIControlStateNormal];
        }
        
        [cell.continue_button addTarget:self action:@selector(continueButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
        
        return cell;

    }
 
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    oldIndex = [tableView indexPathForSelectedRow];
    [tableView cellForRowAtIndexPath:oldIndex].accessoryType = UITableViewCellAccessoryNone;
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    return indexPath;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{   NSDictionary *dict = [paymentTypesDict objectForKey:[_paymentTypesArray objectAtIndex:indexPath.row]];
    
    if (indexPath.section == 0) {
    AmountDetailsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"amountDetailsCell"];
        selected_indexPath = indexPath;
        selected_Method = @"PaymentSelected";
        [cell.continue_button setHidden:NO];
        
        
    NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:0 inSection:1];
        NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
        [_tblPayment reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
    }
    
    
    
  /*  if (indexPath.section == 0)
    {
        //if (_SelectedShipmentName) {
            
        if ([[_paymentTypesArray objectAtIndex:indexPath.row] isEqualToString:@"Credit Card"] || [[_paymentTypesArray objectAtIndex:indexPath.row] isEqualToString:@"Debit Card"]) {
            selectedPaymentType = @"Credit Card";
            selectedPaymentMethod = @"payubiz";

            [self callSavePayment:selectedPaymentMethod];
            
            
        }
        else if ([[_paymentTypesArray objectAtIndex:indexPath.row] isEqualToString:@"Cash on Delivery"]) {
            selectedPaymentType = @"Cash on Delivery";
            selectedPaymentMethod = @"cashondelivery";

            [self callSavePayment:selectedPaymentMethod];
            
        }
        else if ([[_paymentTypesArray objectAtIndex:indexPath.row] isEqualToString:@"Net Banking"]) {

            selectedPaymentType = @"Net Banking";
            selectedPaymentMethod = @"payubiz";
            
           [self callSavePayment:selectedPaymentMethod];
            
            
        }
       
   
            
//    }else
//        {
//            UIAlertController*  alertController = [UIAlertController alertControllerWithTitle:@"FINGOSHOP" message:@"Select Shipping Method" preferredStyle:UIAlertControllerStyleAlert];
//            
//            [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//                
//                
//            }]];
//            
//            [self presentViewController:alertController animated:YES completion:nil];
//
//        }
    

    }*/
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView*)tableView
heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return 10.0;
    }
    else {
        return 0.0;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 40.0;

    }
    else {
        return 250.0;

    }
}
- (IBAction)btnBackClicked:(id)sender {
  
    [self.navigationController popViewControllerAnimated:YES];
   // [self performSegueWithIdentifier:@"Home" sender:self];
}

-(void)btnShipmentClicked
{
    [self performSegueWithIdentifier:@"ShipmentMethod" sender:self];
}
-(void)continueButtonClicked:(UIButton *)sender
{
    
    //  if (indexPath.section == 0)
    // {
     
     if ([[_paymentTypesArray objectAtIndex:selected_indexPath.row] isEqualToString:@"Credit Card"] || [[_paymentTypesArray objectAtIndex:selected_indexPath.row] isEqualToString:@"Debit Card"]) {
     selectedPaymentType = @"Credit Card";
     selectedPaymentMethod = @"payubiz";
     
     [self callSavePayment:selectedPaymentMethod];
     
     
     }
     else if ([[_paymentTypesArray objectAtIndex:selected_indexPath.row] isEqualToString:@"Cash on Delivery"]) {
     selectedPaymentType = @"Cash on Delivery";
     selectedPaymentMethod = @"cashondelivery";
     
     [self callSavePayment:selectedPaymentMethod];
     
     }
     else if ([[_paymentTypesArray objectAtIndex:selected_indexPath.row] isEqualToString:@"Net Banking"]) {
     
     selectedPaymentType = @"Net Banking";
     selectedPaymentMethod = @"payubiz";
     
     [self callSavePayment:selectedPaymentMethod];
     
     
     }
     
//}
    
    
}


#pragma mark - ServiceConnection Methods

-(void)CallGetPaymentMethods {
    
    [SVProgressHUD showWithStatus:@"Please wait" maskType:SVProgressHUDMaskTypeBlack]; // Progress
//    paymentMethod = [paymentMethod stringByReplacingOccurrencesOfString:@" " withString:@""];
    serviceconn = [[ServiceConnection alloc]init];
    serviceconn.delegate = self;
    ServiceType=@"PaymentMethods";
    [serviceconn getPaymentMethods];

}

-(void)callSavePayment:(NSString*)paymentMethod {
    [SVProgressHUD showWithStatus:@"Please wait" maskType:SVProgressHUDMaskTypeBlack]; // Progress
    
    serviceconn = [[ServiceConnection alloc]init];
    serviceconn.delegate = self;
    ServiceType=@"SavePayment";
    [serviceconn savePayment:paymentMethod];

}

-(void)callsubmitOrder {
    [SVProgressHUD showWithStatus:@"Please wait" maskType:SVProgressHUDMaskTypeBlack]; // Progress
    
    serviceconn = [[ServiceConnection alloc]init];
    serviceconn.delegate = self;
    ServiceType=@"SubmitOrder";
    [serviceconn submitOrder];
    
}

-(void)callDestroyCartItems {
    [SVProgressHUD showWithStatus:@"Please wait" maskType:SVProgressHUDMaskTypeBlack]; // Progress
    
    serviceconn = [[ServiceConnection alloc]init];
    serviceconn.delegate = self;
    ServiceType=@"DestroyCart";
    [serviceconn destroyCartItems];
    
}


#pragma mark - ServiceConnection Delegate Methods

- (void)jsonData:(NSDictionary *)jsonDict
{
    NSLog(@"Result Dict:%@",jsonDict);
    
    if ([ServiceType isEqualToString:@"PaymentMethods"]) {
        
        
        paymentTypesDict = jsonDict;
        _paymentTypesArray = [paymentTypesDict allKeys];
        [self.tblPayment reloadData];
    }

    else if ([ServiceType isEqualToString:@"SavePayment"]) {
        
        if ([[jsonDict objectForKey:@"status"] isEqualToString:@"success"] && [[jsonDict objectForKey:@"nextStep"] isEqualToString:@"submit"]) {
            if ([[jsonDict objectForKey:@"status"] isEqualToString:@"success"]) {
                
                
                if ([selectedPaymentType isEqualToString:@"Credit Card"]) {
                    
                    [self performSegueWithIdentifier:@"CreditCardPage" sender:self];
                }
                else if ([selectedPaymentType isEqualToString:@"Net Banking"]) {
                    
                    [self performSegueWithIdentifier:@"NetBanking" sender:self];
                    
                }
                else if ([selectedPaymentType isEqualToString:@"Cash on Delivery"]) {
                    [self callsubmitOrder];
                    [self callDestroyCartItems];
                 //
                }

          // [self callsubmitOrder];
        }
        
    }
//    else if ([ServiceType isEqualToString:@"SubmitOrder"]) {
//        
//        if ([[jsonDict objectForKey:@"status"] isEqualToString:@"success"]) {
//            
//            
//            if ([selectedPaymentType isEqualToString:@"Credit Card"]) {
//                
//                [self performSegueWithIdentifier:@"CreditCardPage" sender:self];
//            }
//            else if ([selectedPaymentType isEqualToString:@"Net Banking"]) {
//                
//                [self performSegueWithIdentifier:@"NetBanking" sender:self];
//
//            }
//            else if ([selectedPaymentType isEqualToString:@"Cash on Delivery"]) {
//                
//                [self callDestroyCartItems];
//                
//            }
        //}
        else
        {
            UIAlertController*  alertController = [UIAlertController alertControllerWithTitle:@"FINGOSHOP" message:@"Somthing went wrong,call customer care." preferredStyle:UIAlertControllerStyleAlert];
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
                [self.navigationController popToRootViewControllerAnimated:YES];
                
                
            }]];
            
            [self presentViewController:alertController animated:YES completion:nil];
            
        }
    }
    else if ([ServiceType isEqualToString:@"SubmitPayU"]) {
        
        [self callDestroyCartItems];
    }
    else if ([ServiceType isEqualToString:@"DestroyCart"]) {
        if ([[jsonDict objectForKey:@"message"] isEqualToString:@"Cart was cleared Successfully"]) {

                        UIAlertController*  alertController = [UIAlertController alertControllerWithTitle:@"FINGOSHOP" message:@"Your Order is Successfully Placed !" preferredStyle:UIAlertControllerStyleAlert];
                
                            [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                                
                                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"CartCount"];
                                [self.navigationController popToRootViewControllerAnimated:YES];
               
                
                
                        }]];
                            
                        [self presentViewController:alertController animated:YES completion:nil];

                
               
                
            }
            
        }
        else {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"FINGOSHOP" message:[jsonDict objectForKey:@"status"] preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:ok];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
        
    
   
    [SVProgressHUD dismiss];

}


- (void)errorMessage:(NSString *)errMsg
{
    [SVProgressHUD dismiss];
}



-(void)dataReceived:(NSNotification *)noti
{
    NSLog(@"dataReceived from surl/furl:%@", noti.object);
    NSString *message = [NSString stringWithFormat:@"%@",noti.object];
    if ([message rangeOfString:@"status=success"].location == NSNotFound) {
        //failure block
        UIAlertController*  alertController = [UIAlertController alertControllerWithTitle:@"FINGOSHOP" message:@"Payment failed" preferredStyle:UIAlertControllerStyleAlert];
        
                [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        
                                    [self.navigationController popToRootViewControllerAnimated:YES];
        
        
                }]];
        
                [self presentViewController:alertController animated:YES completion:nil];

    } else {
        //success block
        
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        [arr addObject:noti.object];
        NSString *post=[NSString stringWithFormat:@"payu=%@",arr];
        NSLog(@"Post: %@",post);
        
        //PAYUALERT(@"Status", message);
        [SVProgressHUD showWithStatus:@"Please wait" maskType:SVProgressHUDMaskTypeBlack]; // Progress
        
        serviceconn = [[ServiceConnection alloc]init];
        serviceconn.delegate = self;
        ServiceType=@"SubmitPayU";
        [serviceconn submitPayUResponse:post];
    }
    
}


- (IBAction)startPayment:(id)sender {
    
    
    self.getTransactionID = [PayUSAGetTransactionID new];
    self.defaultActivityIndicator = [[iOSDefaultActivityIndicator alloc]init];
    _paymentParamForPassing = [PayUModelPaymentParams new];
    self.paymentParamForPassing.key = @"BMjHuo"; //gtKFFx
//    self.paymentParamForPassing.amount = @"1.0";
    self.paymentParamForPassing.amount = [NSString stringWithFormat:@"%@",[shippingdict objectForKey:@"grand_total"]];
    self.paymentParamForPassing.productInfo = productInfo;
    self.paymentParamForPassing.firstName = [shippingdict  objectForKey:@"firstname"];
    self.paymentParamForPassing.email = [shippingdict  objectForKey:@"email"];

    self.paymentParamForPassing.userCredentials = [NSString stringWithFormat:@"%@:rara",[shippingdict objectForKey:@"email"]];
//    @"kushal.mandala@gmail.com:rara";
//    self.paymentParamForPassing.phoneNumber = @"1111111111";
    self.paymentParamForPassing.phoneNumber = [shippingdict  objectForKey:@"telephone"];
    self.paymentParamForPassing.SURL = @"https://payu.herokuapp.com/ios_success";
    self.paymentParamForPassing.FURL = @"https://payu.herokuapp.com/ios_failure";
    self.paymentParamForPassing.udf1 = @"u1";
    self.paymentParamForPassing.udf2 = @"u2";
    self.paymentParamForPassing.udf3 = @"u3";
    self.paymentParamForPassing.udf4 = @"u4";
    self.paymentParamForPassing.udf5 = @"u5";
    self.paymentParamForPassing.Environment = @"0";
    self.paymentParamForPassing.offerKey = @"offer@123";
    self.paymentParamForPassing.transactionID = [self.getTransactionID getTransactionIDWithLength:15];

    
    [self.defaultActivityIndicator startAnimatingActivityIndicatorWithSelfView:self.view];
    self.view.userInteractionEnabled = NO;
    self.getHashesFromServer = [PayUSAGetHashes new];
    [self.getHashesFromServer generateHashFromServer:self.paymentParamForPassing withCompletionBlock:^(PayUHashes *hashes, NSString *errorString) {
        if (errorString) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.defaultActivityIndicator stopAnimatingActivityIndicator];
                PAYUALERT(@"Error", errorString);
            });
        }
        else{
            self.paymentParamForPassing.hashes = hashes;
            PayUWebServiceResponse *respo = [PayUWebServiceResponse new];
            [respo callVASForMobileSDKWithPaymentParam:self.paymentParamForPassing];        //FORVAS1
            self.webServiceResponse = [PayUWebServiceResponse new];
            [self.webServiceResponse getPayUPaymentRelatedDetailForMobileSDK:self.paymentParamForPassing withCompletionBlock:^(PayUModelPaymentRelatedDetail *paymentRelatedDetails, NSString *errorMessage, id extraParam) {
                [self.defaultActivityIndicator stopAnimatingActivityIndicator];
                if (errorMessage) {
                    PAYUALERT(@"Error", errorMessage);
                }
                else{

                    self.paymentRelatedDetailone=paymentRelatedDetails;
                
                }
            }];
        }
    }];
}


// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

// Called when the UIKeyboardDidShowNotification is sent.
//- (void)keyboardWasShown:(NSNotification*)aNotification
//{
//    NSDictionary* info = [aNotification userInfo];
//    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
//    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
//    self.startScreenScrollView.contentInset = contentInsets;
//    self.startScreenScrollView.scrollIndicatorInsets = contentInsets;
//    
//    // If active text field is hidden by keyboard, scroll it so it's visible
//    // Your application might not need or want this behavior.
//    CGRect aRect = self.view.frame;
//    aRect.size.height -= kbSize.height;
//    //    if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
//    //        CGPoint scrollPoint = CGPointMake(0.0, activeField.frame.origin.y-kbSize.height);
//    //        [self.startScreenScrollView setContentOffset:scrollPoint animated:YES];
//    //    }
//}
//
//// Called when the UIKeyboardWillHideNotification is sent
//- (void)keyboardWillBeHidden:(NSNotification*)aNotification
//{
//    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
//    self.startScreenScrollView.contentInset = contentInsets;
//    self.startScreenScrollView.scrollIndicatorInsets = contentInsets;
//}

-(void)handleSingleTap{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:true];
    //[[NSNotificationCenter defaultCenter] removeObserver:self
                                            //        name:UIKeyboardDidShowNotification
                                              //    object:nil];
    //[[NSNotificationCenter defaultCenter] removeObserver:self
                                                //    name:UIKeyboardWillHideNotification
                                                  //object:nil];
}



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"NetBanking"]) {
        NetBankingViewController *ivc = [segue destinationViewController];
        ivc.paymentRelatedDetail = self.paymentRelatedDetailone;
        ivc.paymentParam=self.paymentParamForPassing;
    }
    else if ([segue.identifier isEqualToString:@"CreditCardPage"]) {
        PaymentViewController *pvc = [segue destinationViewController];
        pvc.totalPay = [NSString stringWithFormat:@"₹ %@",[shippingdict objectForKey:@"grand_total"]];
        pvc.paymentParam = self.paymentParamForPassing;
        }
}


@end
