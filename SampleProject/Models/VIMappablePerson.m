//
//  VIMappablePerson.m
//  SampleProject
//
//  Created by Isaac Greenspan on 8/31/15.
//  Copyright © 2015 Vokal. All rights reserved.
//

#import "VIMappablePerson.h"

#import <VOKMappableModel.h>

@interface VIMappablePerson () <VOKMappableModel>

@end

@implementation VIMappablePerson

#pragma mark - VOKMappableModel

+ (NSArray *)coreDataMaps
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd' 'LLL' 'yy' 'HH:mm"];
    [df setTimeZone:[NSTimeZone localTimeZone]];
    return @[
             VOK_MAP_FOREIGN_TO_LOCAL(@"first", firstName),
             VOK_MAP_FOREIGN_TO_LOCAL(@"last", lastName),
             [VOKManagedObjectMap mapWithForeignKeyPath:@"date_of_birth"
                                            coreDataKey:VOK_CDSELECTOR(birthDay)
                                          dateFormatter:df],
             VOK_MAP_FOREIGN_TO_LOCAL(@"cat_num", numberOfCats),
             VOK_MAP_FOREIGN_TO_LOCAL(@"CR_PREF", lovesCoolRanch),
             ];
}

+ (NSString *)uniqueKey
{
    return nil;
}

@end
