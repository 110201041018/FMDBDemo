//
//  ViewController.m
//  FMDBDemo
//
//  Created by jieliapp on 2017/10/11.
//  Copyright © 2017年 Zhuhia Jieli Technology. All rights reserved.
//

#import "ViewController.h"
#import "Car.h"
#import <FMDB/FMDB.h>

@interface ViewController ()

@property(nonatomic,strong) FMDatabase *db;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    path = [path stringByAppendingPathComponent:@"ezioDB.db"];
    _db = [FMDatabase databaseWithPath:path];
    [self createTable];

    [self installPersonData:@"Ezio" Age:18 Number:9527];
    [self installPersonData:@"Alen" Age:20 Number:45612];
    [self installPersonData:@"Dam" Age:16 Number:1234856];
    
    Car *car = [Car new];
    car.car_id = @123;
    car.price = 1456130;
    car.brand = @"Ben-Z";
//
    [self addCar:car toPersonID:1];
    [self addCar:car toPersonID:2];
    [self addCar:car toPersonID:3];
    
    NSLog(@"Person :%@",[self getAllPerson]);
    
}


-(void)createTable{
    
    if (![_db open]) {
        return;
    }
    
    NSString *personSql = @"CREATE TABLE 'person' ('id' INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL ,'person_id' VARCHAR(255),'person_name' VARCHAR(255),'person_age' VARCHAR(255),'person_number'VARCHAR(255)) ";
    NSString *carSql = @"CREATE TABLE 'car' ('id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'own_id' VARCHAR(255),'car_id' VARCHAR(255),'car_brand' VARCHAR(255),'car_price' VARCHAR(255))";

    [_db executeStatements:personSql];
    [_db executeStatements:carSql];
    
    
    [_db close];
    
}

-(void)installPersonData:(NSString *)name Age:(int)age Number:(int) num{
    
    [_db open];
    NSNumber *maxID = @(0);
    FMResultSet *res = [_db executeQuery:@"SELECT * FROM person"];
    //获取数据库最大ID
    while ([res next]) {
        if ([maxID integerValue] < [[res stringForColumn:@"person_id"] integerValue]) {
            maxID = @([[res stringForColumn:@"person_id"] integerValue]);
        }
    }
    
    maxID = @([maxID integerValue] + 1);
    
    [_db executeUpdate:@"INSERT INTO person(person_id,person_name,person_age,person_number)VALUES(?,?,?,?)",maxID,name,@(age),@(num)];
   
    [_db close];
    
}

-(void)deleteById:(int)personId{
    
    [_db open];
    
    [_db executeUpdate:@"DELETE FROM person WHERE person_id = ?",@(personId)];
    
    [_db close];
    
}

-(void)updatePerson:(NSString *)name Age:(int)age Number:(int) num PersonId:(int)personId{
    
    [_db open];
    
    [_db executeUpdate:@"UPDATE 'person' SET person_name = ? WHERE person_id = ?",name,@(personId)];
    [_db executeUpdate:@"UPDATE 'person' SET person_age = ? WHERE person_id = ?",@(age),@(personId)];
    [_db executeUpdate:@"UPDATE 'person' SET person_number = ? WHERE person_id = ?",@(num),@(personId)];
    
    [_db open];
}

-(NSMutableArray *)getAllPerson{
    
    [_db open];
    
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    FMResultSet *res = [_db executeQuery:@"SELECT * FROM person"];
    while ([res next]) {
        
        NSDictionary *dict =@{@"id":[res stringForColumn:@"person_id"],
                              @"name":[res stringForColumn:@"person_name"],
                              @"age":[res stringForColumn:@"person_age"],
                              @"number":[res stringForColumn:@"person_number"]
                              };
        
        [dataArray addObject:dict];
    }
    
    [_db close];
    
    return dataArray;
}

-(void)addCar:(Car *)car toPersonID:(int)personId{
    
    [_db open];
    NSNumber *maxID = @(0);
    FMResultSet *res = [_db executeQuery:[NSString stringWithFormat:@"SELECT * FROM car where own_id = %@",@(personId)]];
    while ([res next]) {
        if ([maxID integerValue] < [[res stringForColumn:@"car_id"] integerValue]) {
            maxID = @([[res stringForColumn:@"car_id"] integerValue]);
        }
    }
    
    maxID = @([maxID integerValue] + 1);
    [_db executeUpdate:@"INSERT INTO car(own_id,car_id,car_brand,car_price)VALUES(?,?,?,?)",@(personId),maxID,car.brand,@(car.price)];
    
    [_db close];
}

-(void)deleteCar:(Car *)car fromPersonId:(int)personId{
    
    [_db open];
    [_db executeUpdate:@"DELETE FROM car WHERE own_id = ? and car_id = ?",@(personId),car.car_id];
    [_db close];
}

-(NSArray *)getAllCarFromPersonid:(int)personId{
    
    [_db open];
    FMResultSet *res = [_db executeQuery:[NSString stringWithFormat:@"SELECT * FROM car WHERE own_id = %@",@(personId)]];
    
    NSMutableArray *carArray = [NSMutableArray array];

    while ([res next]) {
    
        Car *newCar = [[Car alloc] init];
        newCar.own_id = @([[res stringForColumn:@"own_id"] integerValue]);
        newCar.car_id = @([[res stringForColumn:@"car_id"] integerValue]);
        newCar.price = [[res stringForColumn:@"car_price"] integerValue];
        newCar.brand = [res stringForColumn:@"car_brand"];
        
        [carArray addObject:newCar];
    }
    
    [_db close];
    
    return carArray;
    
    
}

-(void)deleteAllCarForPerson:(int)personId{
    
    [_db open];
    [_db executeUpdate:@"DELETE FROM car WHERE own_id = ?",@(personId)];
    [_db close];
}












-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
