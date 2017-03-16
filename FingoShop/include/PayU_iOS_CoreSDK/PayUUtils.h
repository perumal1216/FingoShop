//
//  PayUUtils.h
//  PayU_iOS_CoreSDK
//
//  Created by Umang Arya on 30/09/15.
//  Copyright © 2015 PayU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PayUConstants.h"

@interface PayUUtils : NSObject

typedef void (^completionBlockForWebServiceResponse)(id JSON ,NSString *errorMessage, id extraParam);

-(NSMutableURLRequest *)getURLRequestWithPostParam:(NSString *) postParam withURL:(NSURL *) paramURL;

-(void)getWebServiceResponse:(NSMutableURLRequest *) webServiceRequest withCompletionBlock:(completionBlockForWebServiceResponse) completionBlock;

@end
