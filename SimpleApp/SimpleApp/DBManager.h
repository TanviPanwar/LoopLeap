//
//  DBManager.h
//  SimpleApp
//
//  Created by IOS4 on 29/03/17.
//  Copyright © 2017 MAC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "AddCategories.h"
#import "MyDataBaseObject.h"
#import "CategoryObject.h"
#import "NotesObject.h"
#import "UserObject.h"
#import "Constant.h"
#import "ShareDBObject.h"
#import "DbObject.h"

@interface DBManager : NSObject
{
    NSString *databasePath;
}

+(DBManager*)getSharedInstance;

-(BOOL)createDB;

-(BOOL) saveData_UserName:(NSString*)username userid:(NSString*)userid firstName:(NSString*)fName lastName:(NSString*)lName phone_number:(NSString*)phone_number license_type:(NSString*)license_type date_created:(NSString*)date_created catalog:(NSString*)catalog  email_validation_key:(NSString*)email_validation_key password:(NSString*)password;
-(BOOL) createNewDataBase_dataBaseId:(NSString*)dataBaseId dbName:(NSString*)dbName ownerUser_Id:(NSString*)ownerUser_Id cataLog:(NSString*)cataLog lastModified:(NSString*)lastModified dbType:(NSString*)dbType storageType:(NSString*)storageType;
//-(BOOL) createNewDataBase_dataBaseId:(NSString*)dataBaseId dbName:(NSString*)dbName ownerUser_Id:(NSString*)ownerUser_Id cataLog:(NSString*)cataLog lastModified:(NSString*)lastModified dbType:(NSString*)dbType;
-(BOOL)updateDbType :(NSString *)type withDbID:(NSString *)DBID;
-(BOOL)checkExistence :(NSString*)userId;
-(BOOL)checkExistenceDatabase :(NSString*)dbId;
-(NSArray*) findByDbId:(NSString*)DbId;
-(NSArray *)recordExistOrNot:(NSString *)query;
 
-(int) dbEmptyOrNot:(NSString*)query;
-(NSMutableArray*)getDataFromMyDataBase : (NSString*)ownerID;
-(NSMutableArray*)getDataFromUserCategories : (NSString*)ownerID;
-(NSMutableArray*)getNotesDataFromUserNotes: (NSString*)userID;

-(NSMutableArray*)getcategoryListOfSelectedDB: (NSString*)SelectedDB;

-(void) importDBFromServer : (MyDataBaseObject*)obj ;
-(void) importCategoriesFromServer : (CategoryObject*)obj;
-(void) importNotesFromServer : (NotesObject*)obj ;
-(BOOL) saveDataInNotesFromServer:(NotesObject*)noteObj;
-(void) importUsersFromServer : (UserObject*)obj;
-(void) importShareDBUsersFromServer : (ShareDBObject*)obj;
-(NSMutableArray*)getNotesDataUsingImportListFromUserNotes: (NSString*)userID;
-(NSMutableArray*)getImportDataFromMyDataBase : (NSString*)ownerID;
-(BOOL)UpdatePassword : (NSString*)newPassword forUserID  :(NSString*)forUserID;
-(void) IdFromSource :(NSString*)querySQL;

-(void)executeQuery:(NSString*)_query;
-(BOOL)updateNotes : (NSString*)notesID forUserID  :(NSString*)DBID notes:(NSString *)Note title :(NSString *)Title withImage :(NSData*)imgData;
-(NSMutableArray*)getShareUserList : (long)dbID;
-(BOOL)deleteNotes : (NSString*)notesID forUserID  :(NSString*)DBID;

-(NSMutableArray*)getCategoryNotes : (NSString*)categoryID ;

-(NSMutableArray*)getDefaultDBData;

-(void) MoveNotesFromCategory : (NSString*)cateID withNoteID : (NSString*)NoteID withDbID :(NSString*)DBID;
-(void) renameCategory :(NSString*)cateID  withDbID :(NSString*)DBID withNewName:(NSString*)NewName;

-(void) deleteCateGory:(NSString*)cateID;
-(void)deleteDatabaseFrom :(NSMutableArray *)dbIDArr;
@end
