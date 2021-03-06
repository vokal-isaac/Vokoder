//
//  UIViewController+VOKConvenience.m
//  Vokoder Sample Project
//
//  Copyright © 2015 Vokal.
//

#import "UIViewController+VOKConvenience.h"
#import "VOKCoreDataManager.h"
#import "VOKPerson.h"

@implementation UIViewController (VOKConvenience)

- (void)layoutNavBarButtons
{
    UIBarButtonItem *reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                  target:self
                                                                                  action:@selector(reloadData)];
    UIBarButtonItem *reloadInBackgroundButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize
                                                                                              target:self
                                                                                              action:@selector(reloadDataInBackground)];
    UIBarButtonItem *deleteSomeStuffButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                                                           target:self
                                                                                           action:@selector(deleteDataInBackground)];

    self.navigationItem.rightBarButtonItems = @[reloadButton, reloadInBackgroundButton, deleteSomeStuffButton];
}

- (void)setupCustomMapper
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd' 'LLL' 'yy' 'HH:mm"];
    [df setTimeZone:[NSTimeZone localTimeZone]];

    NSArray *maps = @[VOK_MAP_FOREIGN_TO_LOCAL(@"first", firstName),
                      VOK_MAP_FOREIGN_TO_LOCAL(@"last", lastName),
                      [VOKManagedObjectMap mapWithForeignKeyPath:@"date_of_birth" coreDataKey:VOK_CDSELECTOR(birthDay) dateFormatter:df],
                      VOK_MAP_FOREIGN_TO_LOCAL(@"cat_num", numberOfCats),
                      VOK_MAP_FOREIGN_TO_LOCAL(@"CR_PREF", lovesCoolRanch)];

    VOKManagedObjectMapper *mapper = [VOKManagedObjectMapper mapperWithUniqueKey:VOK_CDSELECTOR(lastName) andMaps:maps];
    [[VOKCoreDataManager sharedInstance] setObjectMapper:mapper forClass:[VOKPerson class]];
}

- (Class)demoClassToLoad
{
    return VOKPerson.class;
}

- (NSArray *)sortDescriptors
{
    return @[
             [NSSortDescriptor sortDescriptorWithKey:VOK_CDSELECTOR(numberOfCats) ascending:NO],
             [NSSortDescriptor sortDescriptorWithKey:VOK_CDSELECTOR(lastName) ascending:YES],
             ];
}

- (void)reloadData
{
    //nil context is treated as main context
    [self loadDataWithContext:nil];
}

- (void)reloadDataInBackground
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSManagedObjectContext *backgroundContext = [[VOKCoreDataManager sharedInstance] temporaryContext];
        [self loadDataWithContext:backgroundContext];
        [[VOKCoreDataManager sharedInstance] saveAndMergeWithMainContext:backgroundContext];
    });
}

- (void)deleteDataInBackground
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSManagedObjectContext *backgroundContext = [[VOKCoreDataManager sharedInstance] temporaryContext];

        NSPredicate *pred = [NSPredicate predicateWithFormat:@"lovesCoolRanch == YES"];
        NSArray *personArray = [VOKPerson vok_fetchAllForPredicate:pred forManagedObjectContext:backgroundContext];
        [personArray enumerateObjectsUsingBlock:^(VOKPerson *obj, NSUInteger idx, BOOL *stop) {
            [backgroundContext deleteObject:obj];
        }];
        [[VOKCoreDataManager sharedInstance] saveAndMergeWithMainContext:backgroundContext];
    });
}

- (void)loadDataWithContext:(NSManagedObjectContext *)context
{
    //MAKE 20 PEOPLE WITH A CUSTOM MAPPER
    int j = 0;
    while (j < 21 ) {
        NSLog(@"%@", [VOKPerson vok_addWithDictionary:[self dictForCustomMapper] forManagedObjectContext:context]);
        j++;
    }
}

#pragma mark - Fake Data Makers

- (NSDictionary *)dictForCustomMapper
{
    return @{
             @"first" :  [self randomString],
             @"last" : [self randomString],
             @"date_of_birth" : @"24 Jul 83 14:16",
             @"cat_num" : [self randomNumber],
             @"CR_PREF" : [self randomCoolRanchPreference],
             };
}

- (NSNumber *)randomCoolRanchPreference
{
    NSUInteger number = arc4random_uniform(2);
    return @(number);
}

- (NSNumber *)randomNumber
{
    return @(arc4random_uniform(30));
}

- (NSString *)randomString
{
    NSInteger numberOfChars = 7;
    char data[numberOfChars];
    for (int x = 0; x < numberOfChars; data[x++] = (char)('A' + (arc4random_uniform(26))));
    return [[NSString alloc] initWithBytes:data length:numberOfChars encoding:NSUTF8StringEncoding];
}

@end
