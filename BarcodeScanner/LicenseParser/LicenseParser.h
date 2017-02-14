//
//  LicenseParser.h
//  BarcodeScanner
//
//  Created by hasnainjafri on 2/13/17.
//  Copyright © 2017 Hasnain Jafri. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LicenseParser : NSObject
{
    
}

+(NSMutableDictionary*)parseLicense:(NSString*)rawString;

@end
