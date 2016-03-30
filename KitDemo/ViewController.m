//
//  ViewController.m
//  KitDemo
//
//  Created by Tim on 16/3/9.
//  Copyright © 2016年 Timlee. All rights reserved.
//

#import "ViewController.h"
#import <HealthKit/HealthKit.h>
#import "KitData.h"
#import "KitTableViewCell.h"

@interface ViewController (){
    
    HKHealthStore *healthStore;
    NSMutableArray *dataArray;
    
}


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dataArray = [NSMutableArray array];
    
    if ([self isHealthKitAvaliable]) {
        [self loadHealthKitData];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)isHealthKitAvaliable{
    if ([HKHealthStore isHealthDataAvailable]) {
        NSLog(@"Health data is available!");
        return YES;
    }else{
        NSLog(@"Health data is nuavailable!");
        return NO;
    }
}

- (void)loadHealthKitData{
    
    healthStore = [[HKHealthStore alloc] init];
    
    //Build a set of the permissions for writing HealthKit items.
    NSSet *writeDataTypes = [self dataTypesToWrite];
    
    //Build a set of the permissions for reading HealthKit items
    NSSet *readDataTypes = [self dataTypesToRead];
    
    //Request the permissions
    [healthStore requestAuthorizationToShareTypes:writeDataTypes readTypes:readDataTypes completion:^(BOOL success, NSError *error) {
        if (!success) {
            NSLog(@"You didn't allow HealthKit to access these read/write data types. In your app, try to handle this error gracefully when a user decides not to provide access. The error was: %@. If you're using a simulator, try it on a device.", error);
            
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Update the user interface based on the current user's health information.
            [self updateUsersAge];
            [self updateUsersHeight];
            [self updateStepNumber];
        });
    }];
}

#pragma mark - HealthKit Permissions

// Returns the types of data that You wishes to write to HealthKit.
- (NSSet *)dataTypesToWrite {
    
    HKQuantityType *dietaryCalorieEnergyType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed];
    
    HKQuantityType *activeEnergyBurnType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    
    HKQuantityType *heightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    
    HKQuantityType *weightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    
    HKQuantityType *stepCountType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    HKQuantityType *distanceWalkingRunningType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    
    HKQuantityType *climbedType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierFlightsClimbed];
    
    return [NSSet setWithObjects:dietaryCalorieEnergyType, activeEnergyBurnType, heightType, weightType, stepCountType, distanceWalkingRunningType,climbedType, nil];
}

// Returns the types of data that You wishes to read from HealthKit.
- (NSSet *)dataTypesToRead {
    HKQuantityType *dietaryCalorieEnergyType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed];
    
    HKQuantityType *activeEnergyBurnType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    
    HKQuantityType *heightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    
    HKQuantityType *weightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    
    HKCharacteristicType *birthdayType = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth];
    
    HKCharacteristicType *biologicalSexType = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex];
    
    HKQuantityType *stepCountType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    HKQuantityType *distanceWalkingRunningType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    
    HKQuantityType *climbedType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierFlightsClimbed];
    
    return [NSSet setWithObjects:dietaryCalorieEnergyType, activeEnergyBurnType, heightType, weightType, birthdayType, biologicalSexType,stepCountType,distanceWalkingRunningType,climbedType, nil];
}

- (void)updateUsersAge {
    NSError *error;
    NSDate *dateOfBirth = [healthStore dateOfBirthWithError:&error];
    
    if (!dateOfBirth) {
        NSLog(@"Either an error occured fetching the user's age information or none has been stored yet. In your app, try to handle this gracefully.");
        
        NSString *warning = NSLocalizedString(@"Not available", nil);
        NSLog(@"age is %@",warning);
    }
    else {
        // Compute the age of the user.
        NSDate *now = [NSDate date];
        
        NSDateComponents *ageComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:dateOfBirth toDate:now options:NSCalendarWrapComponents];
        
        NSUInteger usersAge = [ageComponents year];
        
        NSString *age = [NSNumberFormatter localizedStringFromNumber:@(usersAge) numberStyle:NSNumberFormatterNoStyle];
        NSLog(@"computer age is %@",age);
        
        KitData *data = [[KitData alloc] init];
        data.name = @"Age";
        data.quantity = age;
        data.endDate = [self stringFromDate:dateOfBirth];
        NSArray *array = [[NSArray alloc] initWithObjects:data, nil];
        [dataArray addObject:array];
    }
}

- (NSString *)stringFromDate:(NSDate *)date{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    //zzz表示时区，zzz可以删除，这样返回的日期字符将不包含时区信息。
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    
    NSString *destDateString = [dateFormatter stringFromDate:date];
    
    return destDateString;
    
}

- (void)updateUsersHeight {
    // Fetch user's default height unit in inches.
    NSLengthFormatter *lengthFormatter = [[NSLengthFormatter alloc] init];
    lengthFormatter.unitStyle = NSFormattingUnitStyleLong;
    
    NSLengthFormatterUnit heightFormatterUnit = NSLengthFormatterUnitInch;
    NSString *heightUnitString = [lengthFormatter unitStringFromValue:10 unit:heightFormatterUnit];
    NSString *localizedHeightUnitDescriptionFormat = NSLocalizedString(@"Height (%@)", nil);
    
    NSString *string= [NSString stringWithFormat:localizedHeightUnitDescriptionFormat, heightUnitString];
    NSLog(@"%@",string);
    
    HKQuantityType *heightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    
    // Query to get the user's latest height, if it exists.
    [self aapl_mostRecentQuantitySampleOfType:heightType predicate:nil completion:^(HKQuantitySample *quantitySample,NSArray* resultArray, NSError *error) {
        if (!quantitySample.quantity) {
            NSLog(@"Either an error occured fetching the user's height information or none has been stored yet. In your app, try to handle this gracefully.");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *ss = NSLocalizedString(@"Not available", nil);
                NSLog(@"%@",ss);
            });
        }
        else {
            // Determine the height in the required unit.
            HKUnit *heightUnit = [HKUnit inchUnit];
            double usersHeight = [quantitySample.quantity doubleValueForUnit:heightUnit];
            
            // Update the user interface.
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *height = [NSNumberFormatter localizedStringFromNumber:@(usersHeight) numberStyle:NSNumberFormatterNoStyle];
                KitData *data = [[KitData alloc] init];
                data.name = @"height";
                data.quantity = [NSString stringWithFormat:@"%@ inch", height];
                data.endDate = [self stringFromDate:quantitySample.endDate];
                data.startDate = [self stringFromDate:quantitySample.startDate];
                data.deviceName = [NSString stringWithFormat:@"%@ %@",quantitySample.device.name, quantitySample.device.softwareVersion];
                NSArray *array = [[NSArray alloc] initWithObjects:data, nil];
                [dataArray addObject:array];
                
                [self.tableView reloadData];
            });
            

        }
    }];
}

- (void)updateStepNumber{
    HKQuantityType *stepType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    // Query to get the user's latest height, if it exists.
    [self aapl_mostRecentQuantitySampleOfType:stepType predicate:nil completion:^(HKQuantitySample *quantitySample, NSArray* resultArray, NSError *error) {
        if (!quantitySample.quantity) {
            NSLog(@"Either an error occured fetching the user's height information or none has been stored yet. In your app, try to handle this gracefully.");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *ss = NSLocalizedString(@"Not available", nil);
                NSLog(@"stepType: %@",ss);
            });
        }
        else {
            NSMutableArray *stepArray = [NSMutableArray array];
            // Determine the height in the required unit.
            HKUnit *countUnit = [HKUnit countUnit];
            
            long count = resultArray.count-1;
            for (long i =  count; i > count - 100; i --) {
                HKQuantitySample *sample = [resultArray objectAtIndex:i];
                double usersCount = [sample.quantity doubleValueForUnit:countUnit];
                NSString *count = [NSNumberFormatter localizedStringFromNumber:@(usersCount) numberStyle:NSNumberFormatterNoStyle];
                
                KitData *data = [[KitData alloc] init];
                data.name = @"step";
                data.quantity = [NSString stringWithFormat:@"%@ step", count];
                data.endDate = [self stringFromDate:quantitySample.endDate];
                data.startDate = [self stringFromDate:quantitySample.startDate];
                data.deviceName = [NSString stringWithFormat:@"%@ %@",quantitySample.device.name, quantitySample.device.softwareVersion];
                [stepArray addObject:data];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [dataArray addObject:stepArray];
                [self.tableView reloadData];
            });
        }
    }];
}

- (void)aapl_mostRecentQuantitySampleOfType:(HKQuantityType *)quantityType predicate:(NSPredicate *)predicate completion:(void (^)(HKQuantitySample *, NSArray*, NSError *))completion {
    NSSortDescriptor *timeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    
    // Since we are interested in retrieving the user's latest sample, we sort the samples in descending order, and set the limit to 1. We are not filtering the data, and so the predicate is set to nil.
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:quantityType predicate:nil limit:HKObjectQueryNoLimit sortDescriptors:@[timeSortDescriptor] resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
        if (!results) {
            if (completion) {
                completion(nil,nil, error);
            }
            
            return;
        }
        
        if (completion) {
            // If quantity isn't in the database, return nil in the completion block.
            HKQuantitySample *quantitySample = results.firstObject;
            //You can get device information
//            HKDevice *device = quantitySample.device;
            //You can get start time
//            NSData *startData = quantitySample.startDate;
            //You can get end time
//            NSData *endData = quantitySample.endDate;
//            HKQuantity *quantity = quantitySample.quantity;
            
            completion(quantitySample, results, error);
        }
    }];
    
    [healthStore executeQuery:query];
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *array = [dataArray objectAtIndex:section];
    return array.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"cell";
    KitTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = (KitTableViewCell *)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    NSArray *array = [dataArray objectAtIndex:indexPath.section];
    KitData *data = [array objectAtIndex:indexPath.row];
    
    cell.title.text = data.name;
    [cell.title sizeToFit];
    cell.secTitle.text = data.quantity;
    cell.details.text = data.endDate;
    cell.subDetails.text = data.deviceName;
    
    return cell;
}



@end
