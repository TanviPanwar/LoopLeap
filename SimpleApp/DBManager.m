//
//  DBManager.m
//  SimpleApp
//
//  Created by IOS4 on 29/03/17.
//  Copyright © 2017 MAC. All rights reserved.
//

#import "DBManager.h"

static DBManager *sharedInstance = nil;
static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;
BOOL isSuccess = YES;
@implementation DBManager

+(DBManager*)getSharedInstance{
    if (!sharedInstance)
    {
        sharedInstance = [[super allocWithZone:NULL]init];
        [sharedInstance createDB];
    }
    return sharedInstance;
}
-(void)licensesTable
{
    char *errMsg;
    const char *sql_stmt = "create table if not exists licenses (license_name text , license_type text, max_categories integer, max_titles integer, password text , max_db integer)";
    if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg)
        != SQLITE_OK)
    {
        isSuccess = NO;
        NSLog(@"Failed to create table");
    }
    
}
-(void)MyDatabaseTable
{
    char *errMsg;
    const char *sql_stmt = "create table if not exists MyDatabase (DatabaseId integer , DBName varchar, Owner_Userid INTEGER, Catalog text, LastModified varchar , DBType text , StorageType varchar , Admin integer , LocationStatus integer , Latitude varchar , Longitude varchar)";
    if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg)
        != SQLITE_OK)
    {
        isSuccess = NO;
        NSLog(@"Failed to create table");
    }
    
}
-(void)SharedDatabasesTable
{
    char *errMsg;
    const char *sql_stmt = "create table if not exists SharedDatabases (DatabaseId integer, UserId integer, Admin text, importDBFlag integer, LocationStatus text)";
    if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg)
        != SQLITE_OK)
    {
        isSuccess = NO;
        NSLog(@"Failed to create table");
    }
    
}

-(void)usersTable
{
    char *errMsg;
    const char *sql_stmt = "create table if not exists users (username text, userid integer primary key, first_name text, last_name text, phone_number text, license_type text, date_created text ,catalog text, email_validation_key text, password text)";
    if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg)
        != SQLITE_OK)
    {
        isSuccess = NO;
        NSLog(@"Failed to create table");
    }
    
}
-(void)user_categoriesTable
{
    char *errMsg;
    const char *sql_stmt = "create table if not exists user_categories (userid integer, DatabaseId integer, category_name text, category_id integer primary key)";
    if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg)
        != SQLITE_OK)
    {
        isSuccess = NO;
        NSLog(@"Failed to create table");
    }
    
}
-(void)user_notesTable
{
    char *errMsg;
    const char *sql_stmt = "create table if not exists user_notes (Notes_id integer primary key, userid integer, DatabaseId integer, category_id integer, title text , note text , File_upload blob , imageData blob)";
    //   const char *sql_stmt = "create table if not exists user_notes (Notes_id integer primary key, userid integer, DatabaseId integer, category_id integer, title text , note text , File_upload blob)";
    if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg)
        != SQLITE_OK)
    {
        isSuccess = NO;
        NSLog(@"Failed to create table");
    }
    
}

-(BOOL)createDB
{
    NSString *docsDir;
    NSArray *dirPaths;
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString:
                    [docsDir stringByAppendingPathComponent: @"SimpleApp.db"]];
    NSLog(@"dbPath = %@", databasePath);
    isSuccess = YES;
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath: databasePath ] == NO)
    {
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK)
        {
            [self licensesTable];
            if (isSuccess == YES)
            {
                [self MyDatabaseTable];
            }
            if (isSuccess == YES)
            {
                [self SharedDatabasesTable];
            }
            if (isSuccess == YES)
            {
                [self usersTable];
            }
            if (isSuccess == YES)
            {
                [self user_categoriesTable];
            }
            if (isSuccess == YES)
            {
                [self user_notesTable];
            }
            
            sqlite3_reset(statement);
            sqlite3_finalize(statement);
            sqlite3_close(database);
            return  isSuccess;
        }
        else
        {
            isSuccess = NO;
            NSLog(@"Failed to open/create database");
        }
    }
    return isSuccess;
}

// Registration (SignUp)
-(BOOL) saveData_UserName:(NSString*)username userid:(NSString*)userid firstName:(NSString*)fName lastName:(NSString*)lName phone_number:(NSString*) phone_number license_type:(NSString*)license_type date_created:(NSString*)date_created catalog:(NSString*)catalog  email_validation_key:(NSString*)email_validation_key password:(NSString*)password
{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        
        
        NSString *insertSQL = [NSString stringWithFormat:@"insert into users (username, userid , first_name, last_name, phone_number, license_type, date_created, catalog, email_validation_key , password) values (\"%@\",\"%@\", \"%@\", \"%@\", \"%@\", \"%@\",\"%@\", \"%@\", \"%@\", \"%@\")", username, userid, fName, lName, phone_number, license_type, date_created, catalog, email_validation_key, password];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            return YES;
        }
        else
        {
            return NO;
        }
        
    }
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    sqlite3_close(database);
    
    return NO;
    
}
// Create New DB

-(BOOL) createNewDataBase_dataBaseId:(NSString*)dataBaseId dbName:(NSString*)dbName ownerUser_Id:(NSString*)ownerUser_Id cataLog:(NSString*)cataLog lastModified:(NSString*)lastModified dbType:(NSString*)dbType storageType:(NSString*)storageType admin:(NSString*)admin locationStatus:(NSString*)locationStatus  lattitude:(NSString*)lattitude  longitude:(NSString*)longitude
{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:@"insert into MyDatabase (DatabaseId, DBName , Owner_Userid, Catalog, LastModified , DBType , StorageType , Admin, LocationStatus, Latitude , Longitude) values (\"%d\",\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%d\", \"%d\", \"%@\", \"%@\")", [dataBaseId intValue], dbName, ownerUser_Id, cataLog, lastModified ,dbType , storageType , [admin intValue] , [locationStatus intValue] , lattitude , longitude];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            return YES;
        }
        else
        {
            return NO;
        }
        
    }
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    sqlite3_close(database);
    return NO;
    
}


-(BOOL)checkExistence :(NSString*)userId
{
    sqlite3_stmt *statemnt;
    
    const char *dbPath = [databasePath UTF8String];
    
    if(sqlite3_open(dbPath, &database)==SQLITE_OK){
        NSString *checkSQL = [NSString stringWithFormat:@"SELECT userid FROM users WHERE userid=\"%@\" ",userId];
        //email is a value for which i am checking if it already exists in sqlite database or not.
        
        const char *chkSQL = [checkSQL UTF8String];
        
        if(sqlite3_prepare_v2(database,chkSQL, -1,&statemnt,NULL)==SQLITE_OK){
            if(sqlite3_step(statemnt)==SQLITE_ROW)
            {
                
                sqlite3_reset(statemnt);
                sqlite3_finalize(statemnt);
                sqlite3_close(database);
                
                return YES;
                
            }else{
                sqlite3_reset(statemnt);
                sqlite3_finalize(statemnt);
                sqlite3_close(database);
                
                return NO;
            }
        }
    }
    return NO;
}

-(BOOL)checkExistenceDatabase :(NSString*)dbId
{
    sqlite3_stmt *statemnt;
    
    const char *dbPath = [databasePath UTF8String];
    
    if(sqlite3_open(dbPath, &database)==SQLITE_OK){
        NSString *checkSQL = [NSString stringWithFormat:@"SELECT DatabaseId FROM MyDatabase WHERE DatabaseId=\"%@\"",dbId];
        //email is a value for which i am checking if it already exists in sqlite database or not.
        
        const char *chkSQL = [checkSQL UTF8String];
        
        if(sqlite3_prepare_v2(database,chkSQL, -1,&statemnt,NULL)==SQLITE_OK){
            if(sqlite3_step(statemnt)==SQLITE_ROW)
            {
                
                sqlite3_reset(statemnt);
                sqlite3_finalize(statemnt);
                sqlite3_close(database);
                
                return YES;
                
            }else{
                sqlite3_reset(statemnt);
                sqlite3_finalize(statemnt);
                sqlite3_close(database);
                
                return NO;
            }
        }
    }
    return NO;
}


-(NSArray *)recordExistOrNot:(NSString *)query{
    BOOL recordExist=NO;
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    {
        
        NSMutableArray *resultArray = [[NSMutableArray alloc]init];
        if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, NULL)==SQLITE_OK)
        {
            if (sqlite3_step(statement)==SQLITE_ROW)
            {
                NSString *data = [[NSString alloc] initWithUTF8String:
                                  (const char *) sqlite3_column_text(statement, 0)];
                [resultArray addObject:data];
                
                recordExist=YES;
                sqlite3_reset(statement);
                sqlite3_finalize(statement);
                sqlite3_close(database);
                return resultArray;
            }
            else
            {
                //////NSLog(@"%s,",sqlite3_errmsg(database));
                
            }
            sqlite3_reset(statement);
            sqlite3_finalize(statement);
            sqlite3_close(database);
        }
    }
    return 0;
}

-(NSArray*) findByDbId:(NSString*)DbId
{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat: @"select DBName , Owner_Userid, Catalog, LastModified from MyDatabase where DatabaseId=\"%@\"",DbId];
        const char *query_stmt = [querySQL UTF8String];
        NSMutableArray *resultArray = [[NSMutableArray alloc]init];
        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *DBName = [[NSString alloc] initWithUTF8String:
                                    (const char *) sqlite3_column_text(statement, 0)];
                [resultArray addObject:DBName];
                NSString *Owner_Userid = [[NSString alloc] initWithUTF8String:
                                          (const char *) sqlite3_column_text(statement, 1)];
                [resultArray addObject:Owner_Userid];
                NSString *Catalog = [[NSString alloc]initWithUTF8String:
                                     (const char *) sqlite3_column_text(statement, 2)];
                [resultArray addObject:Catalog];
                
                NSString *LastModified = [[NSString alloc]initWithUTF8String:
                                          (const char *) sqlite3_column_text(statement, 3)];
                [resultArray addObject:LastModified];
                return resultArray;
            }
            else
            {
                NSLog(@"Not found");
                return nil;
            }
            
        }
        sqlite3_reset(statement);
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    return nil;
}


-(int) dbEmptyOrNot:(NSString*)query
{
    NSArray * data = [[NSArray alloc] init];
    data = [[DBManager getSharedInstance] recordExistOrNot:@"SELECT COUNT(*) FROM MyDatabase"];
    int count = [[data objectAtIndex:0] intValue];
    return count;
}

-(NSMutableArray *)getdata:(NSString *)query{
    BOOL recordExist=NO;
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    {
        
        NSMutableArray *resultArray = [[NSMutableArray alloc]init];
        if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, NULL)==SQLITE_OK)
        {
            
            while(sqlite3_step(statement) == SQLITE_ROW)
            {
                MyDataBaseObject *DbObj =  [[MyDataBaseObject alloc]init];
                NSString *dbID = [[NSString alloc] initWithUTF8String:
                                  (const char *) sqlite3_column_text(statement, 0)];
                DbObj.Databaseid = [dbID longLongValue];
                NSString *dbName = [[NSString alloc] initWithUTF8String:
                                    (const char *) sqlite3_column_text(statement, 1)];
                dbName = [dbName stringByReplacingOccurrencesOfString:@"~#~" withString:@"\""];
                dbName = [dbName stringByReplacingOccurrencesOfString:@"~!~" withString:@"\'"];
                
                DbObj .DBName = dbName;
                
                
                NSString *ownerID = [[NSString alloc] initWithUTF8String:
                                     (const char *) sqlite3_column_text(statement, 2)];
                DbObj .Owner_Userid = [ownerID longLongValue];
                
                NSString *catalog = [[NSString alloc] initWithUTF8String:
                                     (const char *) sqlite3_column_text(statement, 3)];
                DbObj .Catelog =  catalog ;
                
                NSString *lastModifiedDate = [[NSString alloc] initWithUTF8String:
                                              (const char *) sqlite3_column_text(statement, 4)];
                DbObj .LastModified =  lastModifiedDate;
                NSString * dbType;
                char *tmp = sqlite3_column_text(statement, 5);
                if (tmp == NULL)
                    dbType = nil;
                else
                    dbType = [[NSString alloc] initWithUTF8String:tmp];
                
                DbObj .DBType =  dbType;
                
                
                NSString * storageType;
                char *tmp1 = sqlite3_column_text(statement, 6);
                if (tmp1 == NULL)
                    storageType = nil;
                else
                    storageType = [[NSString alloc] initWithUTF8String:tmp1];
                
//
//                NSString *storageType = [[NSString alloc] initWithUTF8String:
//                                         (const char *) sqlite3_column_text(statement, 6)];
//                storageType = [storageType stringByReplacingOccurrencesOfString:@"~#~" withString:@"\""];
//                storageType = [storageType stringByReplacingOccurrencesOfString:@"~!~" withString:@"\'"];
                
                DbObj .StorageType = storageType;
                
                
                NSString *admin = [[NSString alloc] initWithUTF8String:
                                                 (const char *) sqlite3_column_text(statement, 7)];
                DbObj.Admin = [admin longLongValue];
                NSString *locationStatus = [[NSString alloc] initWithUTF8String:
                                                                (const char *) sqlite3_column_text(statement, 8)];
                DbObj.LocationStatus = [locationStatus longLongValue];
                NSString *latitude = [[NSString alloc] initWithUTF8String:
                (const char *) sqlite3_column_text(statement, 9)];
                DbObj.Latitude = latitude;
                NSString *longitude = [[NSString alloc] initWithUTF8String:
                (const char *) sqlite3_column_text(statement, 10)];
                DbObj.Longitude = longitude;
                
                [resultArray addObject:DbObj];
                
            }
            
            
            
            recordExist=YES;
            sqlite3_reset(statement);
            sqlite3_finalize(statement);
            sqlite3_close(database);
            return resultArray;
            
        }
    }
    return 0;
}


-(NSMutableArray *)getCategorydata:(NSString *)query{
    BOOL recordExist=NO;
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    {
        
        NSMutableArray *resultArray = [[NSMutableArray alloc]init];
        if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, NULL)==SQLITE_OK)
        {
            while(sqlite3_step(statement) == SQLITE_ROW)
            {
                NotesObject *noteObj =  [[NotesObject alloc]init];
                NSString *noteID = [[NSString alloc] initWithUTF8String:
                                    (const char *) sqlite3_column_text(statement, 0)];
                noteObj.NotesID = [noteID longLongValue];
                
                
                NSString *userID = [[NSString alloc] initWithUTF8String:
                                    (const char *) sqlite3_column_text(statement, 1)];
                noteObj.UserID = [userID longLongValue];
                
                
                NSString *dbID = [[NSString alloc] initWithUTF8String:
                                  (const char *) sqlite3_column_text(statement, 2)];
                noteObj.DatabaseID = [dbID longLongValue];
                
                NSString *cateID = [[NSString alloc] initWithUTF8String:
                                    (const char *) sqlite3_column_text(statement, 3)];
                noteObj.CategoryID = [cateID longLongValue];
                
                
                
                NSString *tittle = [[NSString alloc] initWithUTF8String:
                                    (const char *) sqlite3_column_text(statement, 4)];
                tittle = [tittle stringByReplacingOccurrencesOfString:@"~#~" withString:@"\""];
                tittle = [tittle stringByReplacingOccurrencesOfString:@"~!~" withString:@"\'"];
                noteObj .Title = tittle;
                
                NSString *notes = [[NSString alloc] initWithUTF8String:
                                   (const char *) sqlite3_column_text(statement, 5)];
                notes = [notes stringByReplacingOccurrencesOfString:@"~#~" withString:@"\""];
                notes = [notes stringByReplacingOccurrencesOfString:@"~!~" withString:@"\'"];
                noteObj .Note = notes;
                
                NSString *fileUpload = [[NSString alloc] initWithUTF8String:
                                    (const char *) sqlite3_column_text(statement, 6)];
                fileUpload = [fileUpload stringByReplacingOccurrencesOfString:@"~#~" withString:@"\""];
                fileUpload = [fileUpload stringByReplacingOccurrencesOfString:@"~!~" withString:@"\'"];
                noteObj .FileUpload = fileUpload;
                
                int length = sqlite3_column_bytes(statement, 7);
                NSData* data = [NSData dataWithBytes:sqlite3_column_blob(statement, 7) length:length];
                noteObj.imageData = data;
                
                noteObj.expandStatus =  0 ;
                
                [resultArray addObject:noteObj];
                
                
                
            }
            
            
            
            recordExist=YES;
            sqlite3_reset(statement);
            sqlite3_finalize(statement);
            sqlite3_close(database);
            return resultArray;
            
        }
    }
    return 0;
}


-(NSMutableArray*)getImportDataFromMyDataBase : (NSString*)ownerID {
    NSMutableArray * data = [[NSMutableArray alloc] init];
    data = [[DBManager getSharedInstance] getdata: [NSString stringWithFormat:@"SELECT mdb.*  FROM SharedDatabases as sdb LEFT JOIN MyDatabase as mdb on sdb.DatabaseId = mdb.DatabaseId WHERE  UserId =%d and Admin = 1",[ownerID intValue]]];
    return data;
}

-(NSMutableArray*)getDataFromMyDataBase : (NSString*)ownerID {
    NSMutableArray * data = [[NSMutableArray alloc] init];
    data = [[DBManager getSharedInstance] getdata: [NSString stringWithFormat:@"SELECT * FROM MyDatabase where Owner_Userid =\"%@\"",ownerID]];
    return data;
}


/* For All Databases*/

-(NSMutableArray*)getAllDataFromMyDataBase {
    NSMutableArray * data = [[NSMutableArray alloc] init];
    data = [[DBManager getSharedInstance] getdata: [NSString stringWithFormat:@"SELECT * FROM MyDatabase"]];
    return data;
}



-(NSMutableArray*)getCategoryNotes:(NSString *)categoryID {
    
    NSMutableArray * data = [[NSMutableArray alloc] init];
    data = [[DBManager getSharedInstance] getCategorydata: [NSString stringWithFormat:@"SELECT * FROM user_notes where category_id =\"%@\"",categoryID]];
    return data;
}


-(BOOL) saveCategoryInDatabase:(NSString*)username userid:(NSString*)userid firstName:(NSString*)fName lastName:(NSString*)lName phone_number:(NSString*) phone_number license_type:(NSString*)license_type date_created:(NSString*)date_created catalog:(NSString*)catalog  email_validation_key:(NSString*)email_validation_key password:(NSString*)password
{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:@"insert into users (username, userid , first_name, last_name, phone_number, license_type, date_created, catalog, email_validation_key , password) values (\"%@\",\"%@\", \"%@\", \"%@\", \"%@\", \"%@\",\"%@\", \"%@\", \"%@\", \"%@\")", username, userid, fName, lName, phone_number, license_type, date_created, catalog, email_validation_key, password];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            return YES;
        }
        else
        {
            return NO;
        }
        
    }
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    sqlite3_close(database);
    
    return NO;
    
}

-(void) importDBFromServer : (MyDataBaseObject*)obj {
    
    [self saveDataInMyDatabaseFromServer:obj];
    
}

-(void) getDatabaseIDFromShareDB : (NSString*)query
{
    
}

-(BOOL) saveDataInMyDatabaseFromServer:(MyDataBaseObject*)myDataObj
{
    
    
    
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:@"insert into MyDatabase (DatabaseId, DBName , Owner_Userid, Catalog, LastModified , DBType , StorageType, Admin, LocationStatus, Latitude, Longitude) values (\"%lld\",\"%@\", \"%lld\", \"%@\", \"%@\", \"%@\" , \"%@\",  \"%lld\",  \"%lld\", \"%@\", \"%@\")", myDataObj.Databaseid,myDataObj.DBName,myDataObj.Owner_Userid,myDataObj.Catelog,myDataObj.LastModified , myDataObj.DBType , myDataObj.StorageType , myDataObj.Admin , myDataObj.LocationStatus , myDataObj.Latitude, myDataObj.Longitude];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            
            return YES;
        }
        else
        {
            
            //  NSLog(@"Insert failed: %s", sqlite3_errmsg(database));
            
            return NO;
        }
        
    }
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    sqlite3_close(database);
    
    return NO;
    
}

-(void)executeQuery:(NSString*)_query
{
    
    const char *dbpath = [databasePath UTF8String];
    
    if(sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        
        const char *sql = [_query cStringUsingEncoding:NSUTF8StringEncoding];
        sqlite3_stmt *statement;
        if(sqlite3_prepare_v2(database, sql,-1, &statement, NULL) == SQLITE_OK)
        {
            if(sqlite3_step(statement) == SQLITE_DONE){
                NSLog(@"Delete Sucessfully");
            }else{
                NSLog(@"%s",sqlite3_errmsg(database));
                
            }
        }
        sqlite3_reset(statement);
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    
}


-(void) importCategoriesFromServer : (CategoryObject*)obj {
    
    [self saveDataInCategoryFromServer:obj];
    
}

-(BOOL) saveDataInCategoryFromServer:(CategoryObject*)categoryObj
{
    
    
    
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:@"insert into user_Categories (userid, Databaseid , category_name, category_id ) values (\"%lld\",\"%lld\", \"%@\", \"%lld\")",categoryObj.UserID,categoryObj.DatabaseID,categoryObj.CategoryName,categoryObj.CategoryID];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            return YES;
        }
        else
        {
            return NO;
        }
        
    }
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    sqlite3_close(database);
    
    return NO;
    
}

-(void)deleteCateGory:(NSString*)cateID{
    
    [self deleteCategoryFrom:cateID];
    [self deleteCategoryNoteTittleFrom:cateID];
    // [self renameCategoryName:cateID withDbID:DBID withNewName:NewName];
}

-(BOOL)deleteCategoryFrom :(NSString *)categoryID  {
    
    
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        
        
        
        NSString *deleteSQL = [NSString stringWithFormat:@"delete FROM user_categories where category_id = \"%@\""
                               ,categoryID];
        
        const char *insert_stmt = [deleteSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            return YES;
        }
        else
        {
            NSLog(@"Error is %s",sqlite3_errmsg(database));
            return NO;
        }
        
    }
    
    /**/
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    sqlite3_close(database);
    
    return NO;
}
-(void)deleteDatabaseFrom :(NSMutableArray *)dbIDArr  {
    
    
    for (int i = 0; i<dbIDArr.count ; i++) {
        
        NSMutableArray * arr = [self getcategoryListOfSelectedDB:[dbIDArr objectAtIndex:i]];
        for (int j = 0; j < arr.count;j++) {
            CategoryObject * obj = [arr objectAtIndex:j];
            [self deleteCateGory:[NSString stringWithFormat:@"%lld", obj.CategoryID]];
        }
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK)
        {
            NSString *deleteSQL = [NSString stringWithFormat:@"delete FROM MyDatabase where DatabaseId = \"%@\""
                                   , [dbIDArr objectAtIndex:i]];
            
            const char *insert_stmt = [deleteSQL UTF8String];
            sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
            if (sqlite3_step(statement) == SQLITE_DONE)
            {
                
            }
            else
            {
                NSLog(@"Error is %s",sqlite3_errmsg(database));
                
            }
            
        }
        
        /**/
        sqlite3_reset(statement);
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    
}


-(BOOL)deleteCategoryNoteTittleFrom :(NSString *)categoryID  {
    
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        
        
        
        NSString *deleteSQL = [NSString stringWithFormat:@"delete FROM  user_notes where category_id = \"%@\""
                               ,categoryID];
        
        const char *insert_stmt = [deleteSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            return YES;
        }
        else
        {
            NSLog(@"Error is %s",sqlite3_errmsg(database));
            return NO;
        }
        
    }
    
    /**/
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    sqlite3_close(database);
    
    return NO;
}





-(void) renameCategory :(NSString*)cateID  withDbID :(NSString*)DBID withNewName:(NSString*)NewName{
    
    [self renameCategoryName:cateID withDbID:DBID withNewName:NewName];
}

-(BOOL)renameCategoryName :(NSString *)cateID withDbID:(NSString *)DBID withNewName :(NSString*)NewName {
    
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        
        
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"update user_categories SET category_name = \"%@\" where category_id = \"%@\"  and DatabaseId=\"%@\""
                               ,NewName,cateID,DBID];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            return YES;
        }
        else
        {
            NSLog(@"Error is %s",sqlite3_errmsg(database));
            return NO;
        }
        
    }
    
    /**/
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    sqlite3_close(database);
    
    return NO;
}

-(BOOL)updateDbType :(NSString *)type withDbID:(NSString *)DBID  {
    
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        
        
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"update MyDatabase SET DBType = \"%@\" where  DatabaseId=\"%@\""
                               ,type,DBID];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            return YES;
        }
        else
        {
            NSLog(@"Error is %s",sqlite3_errmsg(database));
            return NO;
        }
        
    }
    
    /**/
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    sqlite3_close(database);
    
    return NO;
}


-(void) MoveNotesFromCategory:(NSString *)cateID withNoteID:(NSString *)NoteID withDbID:(NSString *)DBID{
    
    [self insertNotesFromAnotherCategory:(NSString *)cateID withNoteID:(NSString *)NoteID withDbID:(NSString *)DBID];
    
}


-(BOOL)insertNotesFromAnotherCategory :(NSString *)cateID withNoteID:(NSString *)NoteID withDbID:(NSString *)DBID {
    
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        
        
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"update user_notes SET category_id = \"%@\" where Notes_id = \"%@\"  and DatabaseId=\"%@\""
                               ,cateID,NoteID,DBID];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            return YES;
        }
        else
        {
            NSLog(@"Error is %s",sqlite3_errmsg(database));
            return NO;
        }
        
    }
    
    /**/
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    sqlite3_close(database);
    
    return NO;
}

-(BOOL) saveDataInNotesFromServer:(NotesObject*)noteObj
{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSLog(@"Notes ****** %@",noteObj.Note);
        //  NSString *insertSQL = [NSString stringWithFormat:@"insert into user_notes (Notes_id , userid , DatabaseId , category_id , title , note  , File_upload , imageData) values (\"%lld\",\"%lld\", \"%lld\", \"%lld\",\"%@\",\"%@\", \"%@\", \"?\")",noteObj.NotesID , noteObj.UserID,noteObj.DatabaseID,noteObj.CategoryID,noteObj.Title,noteObj.Note,noteObj.FileUpload,noteObj.imageData];
        const char* sqliteQuery =  "INSERT INTO user_notes (Notes_id , userid , DatabaseId , category_id , title , note  , File_upload , imageData) VALUES (?,?,?,?,?,?,?,?)";
        // const char *insert_stmt = [insertSQL UTF8String];
        // sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        if( sqlite3_prepare_v2(database, sqliteQuery, -1, &statement, NULL) == SQLITE_OK )
        {
            sqlite3_bind_int64(statement, 1, noteObj.NotesID);
            sqlite3_bind_int64(statement, 2, noteObj.UserID);
            sqlite3_bind_int64(statement, 3, noteObj.DatabaseID);
            sqlite3_bind_int64(statement, 4, noteObj.CategoryID);
            sqlite3_bind_text(statement, 5, [noteObj.Title UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 6, [noteObj.Note UTF8String], -1, SQLITE_TRANSIENT);
            
            
            
            
            
            
            sqlite3_bind_text(statement, 7, [noteObj.FileUpload UTF8String], -1, SQLITE_TRANSIENT);
            NSUInteger data;
            data = [noteObj.imageData length];
            sqlite3_bind_blob(statement, 8, [noteObj.imageData bytes], data, SQLITE_TRANSIENT);
            sqlite3_step(statement);
        }
        
        
        //        if (sqlite3_step(statement) == SQLITE_DONE){
        //            return YES;
        //        }
        else{
            NSLog(@"Error is %s",sqlite3_errmsg(database));
            return NO;
        }
        
    }
    
    /**/
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    sqlite3_close(database);
    
    return NO;
    
}

-(void) importNotesFromServer : (NotesObject*)obj {
    
    [self saveDataInNotesFromServer:obj];
    
}


-(NSMutableArray *)getCategoriesData:(NSString *)query{
    BOOL recordExist=NO;
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    {
        
        NSMutableArray *resultArray = [[NSMutableArray alloc]init];
        if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, NULL)==SQLITE_OK)
        {
            
            while(sqlite3_step(statement) == SQLITE_ROW)
            {
                CategoryObject *catObj =  [[CategoryObject alloc]init];
                NSString *userID = [[NSString alloc] initWithUTF8String:
                                    (const char *) sqlite3_column_text(statement, 0)];
                catObj.UserID = [userID longLongValue];
                NSString *DatabaseID = [[NSString alloc] initWithUTF8String:
                                        (const char *) sqlite3_column_text(statement, 1)];
                catObj .DatabaseID = [DatabaseID longLongValue];
                
                NSString *categoryName = [[NSString alloc] initWithUTF8String:
                                          (const char *) sqlite3_column_text(statement, 2)];
                categoryName = [categoryName stringByReplacingOccurrencesOfString:@"~#~" withString:@"\""];
                categoryName = [categoryName stringByReplacingOccurrencesOfString:@"~!~" withString:@"\'"];
                catObj .CategoryName = categoryName;
                
                NSString *catID = [[NSString alloc] initWithUTF8String:
                                   (const char *) sqlite3_column_text(statement, 3)];
                catObj.CategoryID = [catID longLongValue];
                
                
                [resultArray addObject:catObj];
                
            }
            
            
            
            recordExist=YES;
            sqlite3_reset(statement);
            sqlite3_finalize(statement);
            sqlite3_close(database);
            return resultArray;
            
        }
    }
    return 0;
}


-(NSMutableArray*)getDataFromUserCategories : (NSString*)databaseID {
    NSMutableArray * data = [[NSMutableArray alloc] init];
    data = [[DBManager getSharedInstance] getCategoriesData: [NSString stringWithFormat:@"SELECT * FROM user_categories where databaseid =\"%@\"",databaseID]];
    return data;
}

//-(NSMutableArray*)getNotesDataFromUserNotes: (NSString*)userID {
//    NSMutableArray * data = [[NSMutableArray alloc] init];
//    data = [[DBManager getSharedInstance] getNotesData: [NSString stringWithFormat:@"SELECT un.*, uc.category_name FROM user_notes as un LEFT JOIN user_categories as uc on un.category_id = uc.category_id  where un.userid =\"%@\"",userID]];
//    return data;
//}

-(NSMutableArray*)getDefaultDBData {
    NSMutableArray * data = [[NSMutableArray alloc] init];
    data = [[DBManager getSharedInstance] defaultDBData: [NSString stringWithFormat:@"select DatabaseId , DBName , StorageType from MyDatabase ORDER BY DatabaseId ASC LIMIT 1  where Owner_Userid =\"%@\"",[[NSUserDefaults standardUserDefaults] valueForKey:kLoogedInUserID]]];
    return data;
}


-(NSMutableArray*)getNotesDataFromUserNotes: (NSString*)userID {
    NSMutableArray * data = [[NSMutableArray alloc] init];
    data = [[DBManager getSharedInstance] getNotesData: [NSString stringWithFormat:@"SELECT un.*, uc.category_name FROM user_notes as un LEFT JOIN user_categories as uc on un.category_id = uc.category_id  where un.DatabaseId =\"%@\"",userID]];
    return data;
}

-(NSMutableArray*)getNotesDataUsingImportListFromUserNotes: (NSString*)userID {
    NSMutableArray * data = [[NSMutableArray alloc] init];
    data = [[DBManager getSharedInstance] getNotesData: [NSString stringWithFormat:@"SELECT un.*, uc.category_name  FROM SharedDatabases as sdb INNER JOIN MyDatabase as mdb ON sdb.DatabaseId = mdb.DatabaseId INNER JOIN user_categories as uc ON sdb.DatabaseId = uc.DatabaseId INNER JOIN user_notes as un ON sdb.DatabaseId = un.DatabaseId and un.category_id = uc.category_id WHERE sdb.UserId = \"%@\"",userID]];
    return data;
}

-(NSMutableArray *)defaultDBData:(NSString *)query{
    BOOL recordExist=NO;
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    {
        
        NSMutableArray *resultArray = [[NSMutableArray alloc]init];
        if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, NULL)==SQLITE_OK)
        {
            
            while(sqlite3_step(statement) == SQLITE_ROW)
            {
                DbObject *dbObj =  [[DbObject alloc]init];
                
                NSString *databaseID = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                dbObj.DatabaseID = [databaseID longLongValue  ];
                
                NSString *dbName = [[NSString alloc] initWithUTF8String:
                                    (const char *) sqlite3_column_text(statement, 1)];
                dbObj.DBName = dbName;
                
//                NSString *dbtype = [[NSString alloc] initWithUTF8String:
//                                    (const char *) sqlite3_column_text(statement, 5)];
//                dbObj.dbType = dbtype;
                
                
                NSString * storageType;
                char *tmp = sqlite3_column_text(statement, 2);
                if (tmp == NULL)
                    storageType = nil;
                else
                    storageType = [[NSString alloc] initWithUTF8String:tmp];
                
//                NSLog(@"%@", [[NSString alloc] initWithUTF8String:
//                              (const char *) sqlite3_column_text(statement, 6)]);
//                NSString *storageType = [[NSString alloc] initWithUTF8String:
//                                    (const char *) sqlite3_column_text(statement, 6)];
                dbObj.StorageType = storageType;
                
                [resultArray addObject:dbObj];
                
            }
            

            recordExist=YES;
            sqlite3_reset(statement);
            sqlite3_finalize(statement);
            sqlite3_close(database);
            return resultArray;
            
        }
    }
    return 0;
}


-(NSMutableArray *)getNotesData:(NSString *)query{
    BOOL recordExist=NO;
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    {
        
        NSMutableArray *resultArray = [[NSMutableArray alloc]init];
        if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, NULL)==SQLITE_OK)
        {
            
            while(sqlite3_step(statement) == SQLITE_ROW)
            {
                NotesObject *noteObj =  [[NotesObject alloc]init];
                NSString *noteID = [[NSString alloc] initWithUTF8String:
                                    (const char *) sqlite3_column_text(statement, 0)];
                noteObj.NotesID = [noteID longLongValue];
                
                NSString *userID = [[NSString alloc] initWithUTF8String:
                                    (const char *) sqlite3_column_text(statement, 1)];
                noteObj .UserID = [userID longLongValue];
                
                NSString *databaseID = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)];
                noteObj.DatabaseID = [databaseID longLongValue  ];
                
                NSString *categoryID = [[NSString alloc] initWithUTF8String:
                                        (const char *) sqlite3_column_text(statement, 3)];
                noteObj.CategoryID = [categoryID longLongValue];
                
                NSString *title = [[NSString alloc] initWithUTF8String:
                                   (const char *) sqlite3_column_text(statement, 4)];
                
                title = [title stringByReplacingOccurrencesOfString:@"~#~" withString:@"\""];
                title = [title stringByReplacingOccurrencesOfString:@"~!~" withString:@"\'"];
                noteObj.Title = title;
                
                NSString *note = [[NSString alloc] initWithUTF8String:
                                  (const char *) sqlite3_column_text(statement, 5)];
                note = [note stringByReplacingOccurrencesOfString:@"~#~" withString:@"\""];
                note = [note stringByReplacingOccurrencesOfString:@"~!~" withString:@"\'"];
                noteObj.Note = note;
                
                
                //NSString *categoryName = [[NSString alloc] initWithUTF8String:
                //    (const char *) sqlite3_column_text(statement, 7)];
                
                
                // noteObj.categoryName = categoryName;
                
                NSString *categoryName;
                char *tmp = sqlite3_column_text(statement, 8);
                if (tmp == NULL)
                    categoryName = nil;
                else
                    categoryName = [[NSString alloc] initWithUTF8String:tmp];
                
                categoryName = [categoryName stringByReplacingOccurrencesOfString:@"~#~" withString:@"\""];
                categoryName = [categoryName stringByReplacingOccurrencesOfString:@"~!~" withString:@"\'"];
                noteObj.categoryName = categoryName;
                
                int length = sqlite3_column_bytes(statement, 7);
                NSData* data = [NSData dataWithBytes:sqlite3_column_blob(statement, 7) length:length];
                noteObj.imageData = data;
                //                NSString *fileUpload = [[NSString alloc] initWithUTF8String:
                //                                      (const char *) sqlite3_column_text(statement, 6)];
                //                noteObj.FileUpload = fileUpload;
                
                [resultArray addObject:noteObj];
                
            }
            
            
            
            recordExist=YES;
            sqlite3_reset(statement);
            sqlite3_finalize(statement);
            sqlite3_close(database);
            return resultArray;
            
        }
    }
    return 0;
}

#pragma mark Import Users In DB


-(void) importUsersFromServer : (UserObject*)obj {
    
    [self saveDataInUsersTableFromServer:obj];
    
}

-(BOOL) saveDataInUsersTableFromServer:(UserObject*)userObj
{
    
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:@"insert into users (userid, first_name , last_name, phone_number) values (\"%lld\",\"%@\", \"%@\", \"%lld\")", userObj.UserID,userObj.FirstName,userObj.LastName,userObj.PhoneNo];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            
            return YES;
        }
        else
        {
            
            NSLog(@"Insert failed: %s", sqlite3_errmsg(database));
            
            return NO;
        }
        
    }
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    sqlite3_close(database);
    
    return NO;
    
}
#pragma mark  Import ShareDBUsers


-(void) importShareDBUsersFromServer : (ShareDBObject*)obj {
    
    [self saveDataInShareDBTableFromServer:obj];
    
}

-(BOOL) saveDataInShareDBTableFromServer:(ShareDBObject*)dbObj
{
    
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:@"insert into SharedDatabases (DatabaseId, UserId , Admin , LocationStatus ) values (\"%lld\",\"%lld\", \"%lld\" , \"%@\")", dbObj.DatabaseID,dbObj.UserID,dbObj.Admin, dbObj.Location_Status];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            
            return YES;
        }
        else
        {
            
            NSLog(@"Insert failed: %s", sqlite3_errmsg(database));
            
            return NO;
        }
        
    }
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    sqlite3_close(database);
    
    return NO;
    
}
//////

-(void) IdFromSource :(NSString*)querySQL
{
    
    NSString *DBID;
    NSMutableArray *idArray = [[NSMutableArray alloc]init];
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            
            
            while(sqlite3_step(statement) == SQLITE_ROW)
            {
                
                
                DBID = [[NSString alloc] initWithUTF8String:
                        (const char *) sqlite3_column_text(statement, 0)];
                [idArray addObject:DBID];
                
            }
            
        }
        sqlite3_reset(statement);
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    
    
    for (int i= 0 ; i < idArray.count; i++) {
        
        NSString *myDatabaseQuery = [NSString stringWithFormat:@"DELETE FROM MyDatabase WHERE DatabaseId  = %d", [[idArray objectAtIndex:i] intValue]];
        [self executeQuery:myDatabaseQuery];
        
        NSString *userCategoriesquery = [NSString stringWithFormat:@"DELETE FROM user_categories WHERE DatabaseId  = %d",[[idArray objectAtIndex:i] intValue]];
        [self executeQuery:userCategoriesquery];
        NSString *notesQuery = [NSString stringWithFormat:@"DELETE FROM user_notes      WHERE DatabaseId  = %d",[[idArray objectAtIndex:i] intValue]];
        [self executeQuery:notesQuery];
        
    }
    
    
}



-(BOOL)UpdatePassword : (NSString*)newPassword forUserID  :(NSString*)forUserID  {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"UPDATE users SET password = \"%@\" WHERE id = \"%@\"" ,
                               newPassword,forUserID];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            return YES;
        }
        else
        {
            return NO;
        }
        
    }
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    sqlite3_close(database);
    
    return NO;
}

-(BOOL)UpdateLocationStatus : (NSString*)locationStatus forDBID  :(NSString*)forDBID  {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"UPDATE MyDatabase SET LocationStatus =  \"%d\" WHERE DatabaseId = \"%d\"" ,
                               [locationStatus intValue],[forDBID intValue]];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            return YES;
        }
        else
        {
            return NO;
        }
        
    }
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    sqlite3_close(database);
    
    return NO;
}






-(NSMutableArray*)getShareUserList : (long)dbID{
    NSMutableArray * data = [[NSMutableArray alloc] init];
    data = [[DBManager getSharedInstance] getusersData: [NSString stringWithFormat:@"SELECT sdb.Admin, u.first_name,u.last_name,u.phone_number ,u.userid FROM SharedDatabases as sdb LEFT JOIN users as u on sdb.userid = u.UserId where sdb.DatabaseId =\"%ld\"",dbID]];
    return data;
}

-(NSMutableArray *)getusersData:(NSString *)query{
    BOOL recordExist=NO;
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    {
        
        NSMutableArray *resultArray = [[NSMutableArray alloc]init];
        if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, NULL)==SQLITE_OK)
        {
            
            while(sqlite3_step(statement) == SQLITE_ROW)
            {
                UserObject *shareObj =  [[UserObject alloc]init];
                NSString *adminFlag = [[NSString alloc] initWithUTF8String:
                                       (const char *) sqlite3_column_text(statement, 0)];
                shareObj.adminFlag = [adminFlag longLongValue];
                
                NSString *firstName = [[NSString alloc] initWithUTF8String:
                                       (const char *) sqlite3_column_text(statement, 1)];
                shareObj .FirstName = firstName;
                
                NSString *lastName = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)];
 
                NSString *phoneNumber = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 3)];
                shareObj.PhoneNo = [phoneNumber longLongValue];
                NSString *userID = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement,4)];
                shareObj.UserID = [userID longLongValue];
                
                
                
                [resultArray addObject:shareObj];
                
            }
            
            
            
            recordExist=YES;
            sqlite3_reset(statement);
            sqlite3_finalize(statement);
            sqlite3_close(database);
            return resultArray;
            
        }
    }
    return 0;
}


-(BOOL)deleteNotes : (NSString*)notesID forUserID  :(NSString*)DBID  {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"delete FROM user_notes where Notes_id = \"%@\"  and DatabaseId=\"%@\""
                               ,
                               notesID,DBID];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            return YES;
        }
        else
        {
            return NO;
        }
        
    }
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    sqlite3_close(database);
    
    return NO;
}
-(BOOL)updateNotes : (NSString*)notesID forUserID  :(NSString*)DBID notes:(NSString *)Note title :(NSString *)Title withImage :(NSData*)imgData withFileUpload :(NSString *)fileUpload  {
    
    
    //    const char *dbpath = [databasePath UTF8String];
    //    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    //    {
    //        NSString *insertSQL = [NSString stringWithFormat:
    //                               @"update user_notes SET title = \"%@\" , note = \"%@\"   where Notes_id = \"%@\"  and DatabaseId=\"%@\""
    //                               ,Title,Note,
    //                               notesID,DBID];
    //
    //        const char *insert_stmt = [insertSQL UTF8String];
    //        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
    //        if (sqlite3_step(statement) == SQLITE_DONE)
    //        {
    //            return YES;
    //        }
    //        else
    //        {
    //            return NO;
    //        }
    //
    //    }
    //    sqlite3_reset(statement);
    //    sqlite3_finalize(statement);
    //    sqlite3_close(database);
    //
    //    return NO;
    
    
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        const char *sqliteQuery = "update user_notes SET title = ?, note = ?, File_upload = ?, imageData = ?  where Notes_id =?  and DatabaseId= ?";
        
        //    ,Title,Note,
        //    notesID,DBID];
        
        
        if( sqlite3_prepare_v2(database, sqliteQuery, -1, &statement, NULL) == SQLITE_OK )
        {
            sqlite3_bind_text(statement, 1, [Title UTF8String], -1 ,SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 2,[Note UTF8String], -1 ,SQLITE_TRANSIENT);
            
            
            sqlite3_bind_text(statement, 5, [notesID UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 6, [DBID UTF8String], -1, SQLITE_TRANSIENT);
            
            
            sqlite3_bind_text(statement, 3, [fileUpload UTF8String], -1, SQLITE_TRANSIENT);
            NSUInteger data;
            data = [imgData length];
            sqlite3_bind_blob(statement, 4, [imgData bytes], data, SQLITE_TRANSIENT);
            
           
            
            
            sqlite3_step(statement);
        }
        
        
        //        if (sqlite3_step(statement) == SQLITE_DONE){
        //            return YES;
        //        }
        else{
            NSLog(@"Error is %s",sqlite3_errmsg(database));
            return NO;
        }
        
    }
    
    /**/
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    sqlite3_close(database);
    
    return NO;
}
-(NSMutableArray*)getcategoryListOfSelectedDB: (NSString*)SelectedDB{
    NSMutableArray * data = [[NSMutableArray alloc] init];
    data = [[DBManager getSharedInstance] getcategoryList: [NSString stringWithFormat:@"SELECT  * FROM user_categories where Databaseid =\"%@\"",SelectedDB]];
    return data;
    
}

-(NSMutableArray *)getcategoryList:(NSString *)query{
    BOOL recordExist=NO;
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    {
        NSMutableArray *resultArray = [[NSMutableArray alloc]init];
        if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, NULL)==SQLITE_OK)
        {
            while(sqlite3_step(statement) == SQLITE_ROW)
            {
                CategoryObject *catObj =  [[CategoryObject alloc]init];
                
                
                NSString *userID = [[NSString alloc] initWithUTF8String:
                                    (const char *) sqlite3_column_text(statement, 0)];
                catObj .UserID = [userID longLongValue];
                
                NSString *databaseID = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                catObj.DatabaseID = [databaseID longLongValue];
                NSString *categoryName = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)];
                
                categoryName = [categoryName stringByReplacingOccurrencesOfString:@"~#~" withString:@"\""];
                categoryName = [categoryName stringByReplacingOccurrencesOfString:@"~!~" withString:@"\'"];
                catObj.CategoryName = categoryName;
                
                NSString *categoryID = [[NSString alloc] initWithUTF8String:
                                        (const char *) sqlite3_column_text(statement, 3)];
                catObj.CategoryID = [categoryID longLongValue];
                
                
                
                [resultArray addObject:catObj];
                
            }
            recordExist=YES;
            sqlite3_reset(statement);
            sqlite3_finalize(statement);
            sqlite3_close(database);
            return resultArray;
            
        }
    }
    return 0;
}

@end
