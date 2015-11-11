//
//  NoteDAO.h
//  PersistenceLayer
//
//  Created by 关沛东 on 15/11/10.
//  Copyright (c) 2015年 关沛东. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Note.h"
#import "sqlite3.h"

#define DBFILE_NAME @"NotesList.sqlite3"


@interface NoteDAO : NSObject
{
    sqlite3 *db;
}


+ (NoteDAO *)sharedManager;

- (NSString *)applicationDocumentsDirectoryFile;
- (void)createEditableCopyOfDatabaseIfNeeded;

//插入Note方法
- (int) create:(Note *)model;

//删除Note方法
- (int)remove:(Note *)model;

//修改Note方法
-(int) modify:(Note *)model;

//查询所有数据方法
- (NSMutableArray *)findAll;

//按照主键查询数据方法
-(Note *)findById:(Note *)model;








@end
