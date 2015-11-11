//
//  BusinessLogicLayerTests.m
//  BusinessLogicLayerTests
//
//  Created by 关沛东 on 15/11/11.
//  Copyright (c) 2015年 关沛东. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import <PersistenceLayer/Note.h>
#import <PersistenceLayer/NoteDAO.h>
#import "NoteBL.h"

@interface BusinessLogicLayerTests : XCTestCase

@property (nonatomic,strong) NSDateFormatter * dateFormatter;
@property (nonatomic,strong) NoteBL * bl;

@property (nonatomic,strong) NSString* theContent;
@property (nonatomic,strong) NSDate* theDate;

@end

@implementation BusinessLogicLayerTests

- (void)setUp
{
    [super setUp];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    self.bl = [[NoteBL alloc] init];
    
    self.theContent = @"welcome www.51work6.com";
    self.theDate = [self.dateFormatter dateFromString:@"2015-06-03 08:20:38"];
}

- (void)tearDown
{
    self.dateFormatter = nil;
    self.bl = nil;
    [super tearDown];
}

//测试 插入Note方法
-(void) testCreateNote
{
    //创建Note对象
    Note *note = [[Note alloc] init];
    note.date  = self.theDate;
    note.content = self.theContent;
    
    NSArray* list = [self.bl createNote:note];
    //断言 查询记录数为1
    XCTAssertEqual(list.count, 1);
}

//测试 查询所有数据方法
-(void) testFindAll
{
    NSArray* list =  [self.bl findAll];
    //断言 查询记录数为1
    XCTAssertEqual(list.count, 1);
    
    Note* note  = list[0];
    //断言 cdate=2015-06-03 08:20:38
    XCTAssertEqualObjects(self.theDate, note.date);
    //断言 content=welcome www.51work6.com
    XCTAssertEqualObjects(self.theContent, note.content);
}

//测试 删除数据方法
-(void) testRemove
{
    //创建Note对象
    Note *note = [[Note alloc] init];
    note.date  = self.theDate;
    
    NSArray* list = [self.bl remove:note];
    //断言 查询记录数为0
    XCTAssertEqual([list count], 0);
}
@end
