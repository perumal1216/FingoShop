//
//  MyOrdersViewController.h
//  FingoShop
//
//  Created by Rambabu Mannam on 25/04/1938 Saka.
//  Copyright © 1938 Saka fis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServiceConnection.h"

@interface MyOrdersViewController : UIViewController<ServiceConnectionDelegate>
{
    ServiceConnection *seviceconn;

}
@end
