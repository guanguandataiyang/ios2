//
//  NoteDAO.m
//  PersistenceLayer
//
//  Created by 关沛东 on 15/11/10.
//  Copyright (c) 2015年 关沛东. All rights reserved.
//

#import "NoteDAO.h"

@implementation NoteDAO


static NoteDAO *sharedManager = nil;

+ (NoteDAO*)sharedManager
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        
        sharedManager = [[self alloc] init];
        [sharedManager createEditableCopyOfDatabaseIfNeeded];
    });
    return sharedManager;
}


- (void)createEditableCopyOfDatabaseIfNeeded {
    
    NSString *writableDBPath = [self applicationDocumentsDirectoryFile];
    
    if (sqlite3_open([writableDBPath UTF8String], &db) != SQLITE_OK) {
        sqlite3_close(db);
        NSAssert(NO,@"数据库打开失败。");
    } else {
        char *err;
        NSString *createSQL = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS Note (cdate TEXT PRIMARY KEY, content TEXT);"];
        if (sqlite3_exec(db,[createSQL UTF8String],NULL,NULL,&err) != SQLITE_OK) {
            sqlite3_close(db);
            NSAssert1(NO, @"建表失败, %s", err);
        }
        sqlite3_close(db);
    }
}

- (NSString *)applicationDocumentsDirectoryFile {
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [documentDirectory stringByAppendingPathComponent:DBFILE_NAME];
    
    NSLog(@"%@", path);
    
    return path;
}


//插入Note方法
-(int) create:(Note*)model
{
    
    NSString *path = [self applicationDocumentsDirectoryFile];
    
    if (sqlite3_open([path UTF8String], &db) != SQLITE_OK) {
        sqlite3_close(db);
        NSAssert(NO,@"数据库打开失败。");
    } else {
        
        NSString *sqlStr = @"INSERT OR REPLACE INTO note (cdate, content) VALUES (?,?)";
        
        sqlite3_stmt *statement;
        //预处理过程
        if (sqlite3_prepare_v2(db, [sqlStr UTF8String], -1, &statement, NULL) == SQLITE_OK) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString *nsdate = [dateFormatter stringFromDate:model.date];
            
            //绑定参数开始
            sqlite3_bind_text(statement, 1, [nsdate UTF8String], -1, NULL);
            sqlite3_bind_text(statement, 2, [model.content UTF8String], -1, NULL);
            
            //执行插入
            if (sqlite3_step(statement) != SQLITE_DONE) {
                NSAssert(NO, @"插入数据失败。");
            }
        }
        
        sqlite3_finalize(statement);
        sqlite3_close(db);
    }
    
    return 0;
}

//删除Note方法
-(int) remove:(Note*)model
{
    NSString *path = [self applicationDocumentsDirectoryFile];
    
    if (sqlite3_open([path UTF8String], &db) != SQLITE_OK) {
        sqlite3_close(db);
        NSAssert(NO,@"数据库打开失败。");
    } else {
        
        NSString *sqlStr = @"DELETE  from note where cdate =?";
        
        sqlite3_stmt *statement;
        //预处理过程
        if (sqlite3_prepare_v2(db, [sqlStr UTF8String], -1, &statement, NULL) == SQLITE_OK) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString *nsdate = [dateFormatter stringFromDate:model.date];
            
            //绑定参数开始
            sqlite3_bind_text(statement, 1, [nsdate UTF8String], -1, NULL);
            //执行
            if (sqlite3_step(statement) != SQLITE_DONE) {
                NSAssert(NO, @"删除数据失败。");
            }
        }
        
        sqlite3_finalize(statement);
        sqlite3_close(db);
    }
    
    return 0;
}

//修改Note方法
-(int) modify:(Note*)model
{
    
    NSString *path = [self applicationDocumentsDirectoryFile];
    
    if (sqlite3_open([path UTF8String], &db) != SQLITE_OK) {
        sqlite3_close(db);
        NSAssert(NO,@"数据库打开失败。");
    } else {
        
        NSString *sqlStr = @"UPDATE note set content=? where cdate =?";
        
        sqlite3_stmt *statement;
        //预处理过程
        if (sqlite3_prepare_v2(db, [sqlStr UTF8String], -1, &statement, NULL) == SQLITE_OK) {
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString *nsdate = [dateFormatter stringFromDate:model.date];
            
            //绑定参数开始
            sqlite3_bind_text(statement, 1, [model.content UTF8String], -1, NULL);
            sqlite3_bind_text(statement, 2, [nsdate UTF8String], -1, NULL);
            //执行
            if (sqlite3_step(statement) != SQLITE_DONE) {
                NSAssert(NO, @"修改数据失败。");
            }
        }
        
        sqlite3_finalize(statement);
        sqlite3_close(db);
    }
    return 0;
}

//查询所有数据方法
-(NSMutableArray*) findAll
{
    
    NSString *path = [self applicationDocumentsDirectoryFile];
    NSMutableArray *listData = [[NSMutableArray alloc] init];
    
    if (sqlite3_open([path UTF8String], &db) != SQLITE_OK) {
        sqlite3_close(db);
        NSAssert(NO,@"数据库打开失败。");
    } else {
        
        NSString *qsql = @"SELECT cdate,content FROM Note";
        
        sqlite3_stmt *statement;
        //预处理过程
        if (sqlite3_prepare_v2(db, [qsql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            
            //执行
            while (sqlite3_step(statement) == SQLITE_ROW) {
                char *cdate = (char *) sqlite3_column_text(statement, 0);
                NSString *nscdate = [[NSString alloc] initWithUTF8String: cdate];
                
                char *content = (char *) sqlite3_column_text(statement, 1);
                NSString * nscontent = [[NSString alloc] initWithUTF8String: content];
                
                Note* note = [[Note alloc] init];
                note.date = [dateFormatter dateFromString:nscdate];
                note.content = nscontent;
                
                [listData addObject:note];
                
            }
        }
        
        sqlite3_finalize(statement);
        sqlite3_close(db);
        
    }
    return listData;
}

//按照主键查询数据方法
-(Note*) findById:(Note*)model
{
    
    NSString *path = [self applicationDocumentsDirectoryFile];
    
    if (sqlite3_open([path UTF8String], &db) != SQLITE_OK) {
        sqlite3_close(db);
        NSAssert(NO,@"数据库打开失败。");
    } else {
        
        NSString *qsql = @"SELECT cdate,content FROM Note where cdate =?";
        
        sqlite3_stmt *statement;
        //预处理过程
        if (sqlite3_prepare_v2(db, [qsql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
            //准备参数
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString *nsdate = [dateFormatter stringFromDate:model.date];
            //绑定参数开始
            sqlite3_bind_text(statement, 1, [nsdate UTF8String], -1, NULL);
            
            //执行
            if (sqlite3_step(statement) == SQLITE_ROW) {
                char *cdate = (char *) sqlite3_column_text(statement, 0);
                NSString *nscdate = [[NSString alloc] initWithUTF8String: cdate];
                
                char *content = (char *) sqlite3_column_text(statement, 1);
                NSString * nscontent = [[NSString alloc] initWithUTF8String: content];
                
                Note* note = [[Note alloc] init];
                note.date = [dateFormatter dateFromString:nscdate];
                note.content = nscontent;
                
                sqlite3_finalize(statement);
                sqlite3_close(db);
                
                return note;
            }
        }
        
        sqlite3_finalize(statement);
        sqlite3_close(db);
        
    }
    return nil;
}









@end
