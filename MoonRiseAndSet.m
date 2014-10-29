//
//  MoonRiseAndSet.m
//  MoonRiseAndSet
//
//  Created by Larry on 14/10/28.
//  Copyright (c) 2014年 MAXMAX. All rights reserved.
//

#import "MoonRiseAndSet.h"
#import "Reachability.h"

@implementation MoonRiseAndSet


+ (void)getMoonWithLatitude:(double)latitude withLongitude:(double)longtitude
{
    NSString *year;
    NSString *month;
    NSString *day;
    NSString *latitudeStr;
    NSString *longtitudeStr;
    
    NSString *endYear;
    NSString *endMonth;
    
    NSData *moonData;
    
    
    NSMutableDictionary *daysDictionary = [[NSMutableDictionary alloc] init];

    if (latitude >= 0) {
        latitudeStr = [NSString stringWithFormat:@"%@%.2f", @"%2B",latitude];
    }else{
        latitudeStr = [NSString stringWithFormat:@"%.2f",latitude];
    }
    if (longtitude >= 0) {
        longtitudeStr = [NSString stringWithFormat:@"%@%.2f",@"%2B",longtitude];
    }else{
        longtitudeStr = [NSString stringWithFormat:@"%.2f",longtitude];
    }
    Reachability *internetReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [internetReachability currentReachabilityStatus];
    if (netStatus != NotReachable) {
        NSDate *  now=[NSDate date];
        NSCalendar  * cal=[NSCalendar  currentCalendar];
        NSUInteger  unitFlags=NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit;
        NSDateComponents *conponent= [cal components:unitFlags fromDate:now];
        year = [NSString stringWithFormat:@"%d",(int)[conponent year]];
        month = [NSString stringWithFormat:@"%.2i",(int)[conponent month]];
        day = [NSString stringWithFormat:@"%.2i",(int)[conponent day]];
        if ((int)[conponent month] == 12) {
            endYear = [NSString stringWithFormat:@"%d",(int)[conponent year] + 1];
            endMonth = @"1";
        }else{
            endYear = year;
            endMonth = [NSString stringWithFormat:@"%.2i",(int)[conponent month] + 1];
        }
        NSString *str1 = @"https://api.xmltime.com/astronomy?accesskey=T0UXxWshTH&secretkey=pQX9vB3cUMxYuk4D7aK9&out=js&object=moon&placeid=";
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@&startdt=%@-%@-%@&enddt=%@-%@-%@&types=all",str1,latitudeStr,longtitudeStr,year,month,day, endYear, endMonth, day]];
        NSLog(@"%@",url);
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        moonData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    }
    if (moonData) {
        //read the information of the moon and store in a NSMutableDictionary
        NSMutableDictionary *infoDic = [NSJSONSerialization JSONObjectWithData:moonData options:NSJSONReadingMutableLeaves  error:nil];
        NSLog(@"infoDic : %@",infoDic);
        
        NSArray *locationArray = [infoDic objectForKey:@"locations"];
        NSDictionary *locations = [locationArray objectAtIndex:0];
        NSDictionary *astronomy = [locations objectForKey:@"astronomy"];
        NSArray *objects = [astronomy objectForKey:@"objects"];
        NSDictionary *dayArray = [objects objectAtIndex:0];
        NSArray *days = [dayArray objectForKey:@"days"];
        //NSDictionary *eventArray = [days objectAtIndex:0];
        //NSArray *events = [eventArray objectForKey:@"events"];
        for(int j = 0; j < days.count; j++){
            
            NSString *moonrise;
            NSString *moonset;
            NSString *illuminated;
            NSString *moonphase;
            
            NSDictionary *eventArray = [days objectAtIndex:j];
            NSString *date = (NSString *)[eventArray objectForKey:@"date"];
            NSArray *events = [eventArray objectForKey:@"events"];
            for (int i = 0 ; i < events.count; i++) {
                NSString *type = [NSString stringWithFormat:@"%@",[[events objectAtIndex:i] objectForKey:@"type"]];
                if ([type isEqualToString:@"rise"]) {
                    int moonriseHourInt = 0;
                    int moonriseMinInt = 0;
                    moonriseHourInt = [[[events objectAtIndex:i] objectForKey:@"hour"] intValue];
                    moonriseMinInt  = [[[events objectAtIndex:i] objectForKey:@"min"] intValue];
                    moonrise = [NSString stringWithFormat:@"%.2i:%.2i",moonriseHourInt,moonriseMinInt];
                }
                if ([type isEqualToString:@"set"]) {
                    int moonSetHourInt = 0;
                    int moonSetMinInt = 0;
                    moonSetHourInt = [[[events objectAtIndex:i] objectForKey:@"hour"] intValue];
                    moonSetMinInt = [[[events objectAtIndex:i] objectForKey:@"min"] intValue];
                    moonset = [NSString stringWithFormat:@"%.2i:%.2i",moonSetHourInt,moonSetMinInt];
                }
                NSEnumerator *enumerator = [[events objectAtIndex:i] keyEnumerator];
                id key;
                while ((key = [enumerator nextObject])) {
                    if ([key isEqualToString:@"illuminated"]) {
                        illuminated = [NSString stringWithFormat:@"%@",[[events objectAtIndex:i] objectForKey:@"illuminated"]];
                    }
                }
            }
            moonphase = [NSString stringWithFormat:@"%@",[eventArray objectForKey:@"moonphase"]];
        
            if (!moonrise) {
                moonrise = @"--:--";
            }
            if (!moonset) {
                moonset = @"--:--";
            }
            if (!illuminated) {
                illuminated = @"100";
            }
            NSMutableDictionary *eventDictionary = [[NSMutableDictionary alloc] init];
            [eventDictionary setObject:moonrise forKey:@"moonrise"];
            [eventDictionary setObject:moonset forKey:@"moonset"];
            [eventDictionary setObject:illuminated forKey:@"illuminated"];
            [eventDictionary setObject:moonphase forKey:@"moonphase"];
            
            [daysDictionary setObject:eventDictionary forKey:date];
        }
    }
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if ([ud objectForKey:@"moon"]) {
        [ud removeObjectForKey:@"moon"];
        [ud setObject:daysDictionary forKey:@"moon"];
    }else{
        [ud setObject:daysDictionary forKey:@"moon"];
    }
    
}



@end
