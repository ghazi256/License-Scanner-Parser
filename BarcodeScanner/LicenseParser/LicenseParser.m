//
//  LicenseParser.m
//  BarcodeScanner
//
//  Created by hasnainjafri on 2/13/17.
//  Copyright © 2017 Hasnain Jafri All rights reserved.
//

#import "LicenseParser.h"
#import "BarcodeScanner-Swift.h"

@class License_Regex;

@implementation LicenseParser

+(NSMutableDictionary*)parseLicense:(NSString*)rawString
{
    NSString *currentVersion = [License_Regex firstMatch:@"\\d{6}(\\d{2})\\w+" :rawString];
    
    NSMutableDictionary *elementsDictionary = [self getLicenseDataUsingVersion:[currentVersion integerValue]];
    
    NSMutableDictionary *finalLicenseDataDict = [[NSMutableDictionary alloc] init];
    
    NSArray *sortedKeys = [self getSortedKeysArray:[elementsDictionary allKeys]];
    for (int i=0; i<[sortedKeys count]; i++)
    {
        NSString *currentKeyWord = [sortedKeys objectAtIndex:i];
        
        NSRange range = [rawString  rangeOfString: currentKeyWord options: NSCaseInsensitiveSearch];
        NSLog(@"found: %@", (range.location != NSNotFound) ? @"Yes" : @"No");
        if (range.location != NSNotFound)
        {
            NSString *temp=[rawString substringFromIndex:range.location+range.length];
            
            NSRange end = [temp rangeOfString:@"\n"];
            if (end.location != NSNotFound)
            {
                temp = [temp substringToIndex:end.location];
                temp =[temp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                temp=[temp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
            }
            NSLog(@"temp data : %@",temp);
            [finalLicenseDataDict setObject:temp forKey:elementsDictionary[currentKeyWord]];
        }
    }
    
    return finalLicenseDataDict;
}

+(NSMutableDictionary*)getLicenseDataUsingVersion:(NSInteger)version
{
    NSMutableArray *arrElemensKeyWords_V8=[[NSMutableArray alloc]initWithObjects:@"DAC",@"DCS",@"DAD",@"DBA",@"DBD",@"DBB",@"DBC",@"DAY",@"DAU",@"DAG",@"DAI",@"DAJ",@"DAK",@"DAQ",@"DCF",@"DCG",@"DDG",@"DDF",@"DDE",@"DAH",@"DAZ",@"DCI",@"DCJ",@"DCK",@"DBN",@"DBG",@"DBS",@"DCU", nil];
    
    NSMutableArray *arrHeaderData=[[NSMutableArray alloc]initWithObjects:@"First Name",@"Last Name",@"Middle Name",@"Expiration Date",@"Issue Date",@"Date of Birth",@"Gender",@"Eye Color",@"Height",@"Street Address",@"City",@"State",@"Postal Code",@"Customer ID",@"Document ID",@"Issuing Country",@"Middle Name Truncation",@"First Name Truncation",@"Last Name Truncation",@"Second Street Address",@"Hair Color",@"Place of Birth",@"Audit Information",@"Inventory Control",@"Last Name Alias",@"First Name Alias",@"Suffix Alias",@"Name Suffix" ,nil];
    
    NSMutableDictionary *elementsDataDict = [[NSMutableDictionary alloc] initWithObjects:arrHeaderData forKeys:arrElemensKeyWords_V8];
    
    switch (version) {
        case 1:
        {
            [elementsDataDict removeObjectsForKeys:@[@"DCF",@"DCG",@"DDG",@"DDF",@"DDE",@"DCI",@"DCJ",@"DCK"]];
            
            [self replaceOldKeys:@[@"DCS",@"DAQ",@"DBN",@"DBG",@"DBS",@"DCU"] withKeys:@[@"DAB",@"DBJ",@"DBO",@"DBP",@"DBR",@"DBN"] inDictionary:elementsDataDict];
        }
            break;
        case 2:
        {
            [elementsDataDict removeObjectsForKeys:@[@"DCI",@"DCJ",@"DCK",@"DBS"]];
            [self replaceOldKeys:@[@"DAC"] withKeys:@[@"DCT"] inDictionary:elementsDataDict];
        }
            break;
        case 3:
        {
            [elementsDataDict removeObjectsForKeys:@[@"DDG",@"DDF",@"DDE"]];
            [self replaceOldKeys:@[@"DAC"] withKeys:@[@"DCT"] inDictionary:elementsDataDict];
        }
            break;
        case 4:
        case 5:
        case 6:
        case 7:
        case 8:
            break;
            
        default:
            break;
    }
    
    return elementsDataDict;
}


#pragma mark Helper Methods

+(void)replaceOldKeys:(NSArray*)oldKeys withKeys:(NSArray*)newKeys inDictionary:(NSMutableDictionary*)dataDict
{
    for (int i = 0; i < [oldKeys count]; i++) {
        
        NSString *oldKey = [oldKeys objectAtIndex:i];
        NSString *newKey = [oldKeys objectAtIndex:i];
        
        [dataDict setObject:[dataDict objectForKey:oldKey] forKey:newKey];
        [dataDict removeObjectForKey:oldKey];
    }
}

+(NSArray*) getSortedKeysArray:(NSArray*) keys
{
    NSSortDescriptor* desc = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES comparator:^(id obj1, id obj2) { return [obj1 compare:obj2 options:NSNumericSearch]; }];
    
    return [keys sortedArrayUsingDescriptors:[NSArray arrayWithObject:desc]];
}

/*
 1 - @"First Name",
 2 - @"Last Name",
 3 - @"Middle Name",
 4 - @"Expiration Date",
 5 - @"Issue Date",
 6 - @"Date of Birth",
 7 - @"Gender",
 8 - @"Eye Color",
 9 - @"Height",
 10 - @"Street Address",
 11 - @"City",
 12 - @"State",
 13 - @"Postal Code",
 14 - @"Customer ID",
 15 - @"Document ID",
 16 - @"Issuing Country",
 17 - @"Middle Name Truncation",
 18 - @"First Name Truncation",
 19 - @"Last Name Truncation",
 20 - @"Second Street Address",
 21 - @"Hair Color",
 22 - @"Place of Birth",
 23 - @"Audit Information",
 24 - @"Inventory Control",
 25 - @"Last Name Alias",
 26 - @"First Name Alias",
 27 - @"Suffix Alias",
 28 - @"Name Suffix"
 */

@end
