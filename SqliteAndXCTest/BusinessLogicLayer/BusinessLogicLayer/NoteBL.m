//
//  NoteBL.m
//  BusinessLogicLayer
//
//  Created by 关沛东 on 15/11/11.
//  Copyright (c) 2015年 关沛东. All rights reserved.
//

#import "NoteBL.h"

@implementation NoteBL

//插入Note方法
-(NSMutableArray*) createNote:(Note*)model
{
    NoteDAO *dao = [NoteDAO sharedManager];
    [dao create:model];
    
    return [dao findAll];
}

//删除Note方法
-(NSMutableArray*) remove:(Note*)model
{
    NoteDAO *dao = [NoteDAO sharedManager];
    [dao remove:model];
    
    return [dao findAll];
}

//查询所用数据方法
-(NSMutableArray*) findAll
{
    NoteDAO *dao = [NoteDAO sharedManager];
    return [dao findAll];
}



@end
