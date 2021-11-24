//
//  DBManager.swift
//  MYMECA
//
//  Created by Fetih Tunay on 18/02/21.
//  Copyright © Fetih Tunay. All rights reserved.
//

import UIKit
import FMDB

private  let _sharedAPIManager = DBManager()
let DBRowID = "id"

let DBRowLocalAdd = "LocalAdd"
let DBRowLocalDelete = "LocalAdd"
let DBRowOnline = "Online"

let DBTableAlbum = "tblAlbum"
let DBAlbumName = "Album_Name"
let DBAlbumID = "Album_ID"
let DBAlbumImage = "Album_Image"
let DBAlbumPassword = "Album_Password"


let DBTableGallery = "tblGallery"
let DBTimestamp = "timestamp"
let DBGalleryImageName = "GalleryImageName"
let DBVideoThumbName = "VideoThumbName"



class DBManager: NSObject {
    var database: FMDatabase?
    
    class var sharedInstance : DBManager {
        return _sharedAPIManager
    }
    
    
    override init () {
        super.init()
        self.createCopyOfDatabaseIfNeeded()
        database = FMDatabase.init(path: self.getDBPath())
    }
    
    // MARK: Check and Copy Database
    func createCopyOfDatabaseIfNeeded() {
        // First, test for existence.
        var success: Bool
        let fileManager = FileManager.default
        let _: Error? = nil
        //print("\(getDBPath())")
        success = fileManager.fileExists(atPath: getDBPath())
        if success {
            return
        }
        // The writable database does not exist, so copy the default to the appropriate location.
        let defaultDBPath: String = URL(fileURLWithPath: (Bundle.main.resourcePath)!).appendingPathComponent("db.sqlite").absoluteString
        success = ((try? fileManager.copyItem(atPath: defaultDBPath, toPath: getDBPath())) != nil)
        if !success {
            // print("Failed to create writable database file with message \(error?.localizedDescription)).")
        }
    }
    
    func getDBPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docsPath: String = paths[0]
        let dbPath: String = URL(fileURLWithPath: docsPath).appendingPathComponent("db.sqlite").absoluteString
        print(dbPath)
        return dbPath
    }
    
    // MARK: Create
    func createTable(withTableName tablename: String, withDictionary dicts: [String: Any]) {
        //  tblname = tablename;
        var dict = dicts
        dict[DBRowLocalAdd] = ""
        dict[DBRowLocalDelete] = ""
        dict[DBRowOnline] = ""
        
        var query = "create table if not exists \(tablename)"
        query += "("
        for key: String in dict.keys {
            if (key == "id") {
                query += " \(key) INTEGER PRIMARY KEY AUTOINCREMENT,"
            }
            else if (key == DBRowLocalAdd) || (key == DBRowLocalDelete) || (key == DBRowOnline) {
                query += " \(key) TEXT default 0,"
            }
            else {
                query += " \(key) TEXT,"
            }
        }
        if let subRange = Range<String.Index>(NSRange(location: (query.count ) - 1, length: 1), in: query) {
            query.replaceSubrange(subRange, with: "")
        }
        query += ")"
        database?.open()
        
        do {
            try database?.executeUpdate(query, values: [1])
        } catch {
        }
        
        database?.close()
    }
    // MARK: Drop table
    func dropTable(withTableName tablename: String) {
        database?.open()
        do {
            try database?.executeUpdate("DROP TABLE IF EXISTS \(tablename)", values: [1])
        } catch {
        }
        database?.close()
    }
    
    // MARK: Insert
    func insertDataInDB(withArray array: [[String : Any]], withTableName tableName: String,  callBack :  @escaping ((_ success : Bool)-> Void)) {
        let group = DispatchGroup()
        var success = false
        DispatchQueue.global(qos: .background).async {
            let queue = FMDatabaseQueue(path: self.getDBPath())
            queue?.inDatabase({(_ db: FMDatabase) -> Void in
                for dict in array{
                    group.enter()
                    let strKeys = (dict.compactMap(){ "'\($0.0)'" } as Array).joined(separator: ",")
                    let strValues = (dict.compactMap(){ "'\(CheckNullString(value: $0.1 as AnyObject))'"  } ).joined(separator: ",")
                    //print(strKeys)
                    //print(strValues)
                    //print("INSERT INTO \(tableName) \(strKeys) VALUES \(strValues)")
                    do {
                        try db.executeUpdate("INSERT OR REPLACE INTO \(tableName) (\(strKeys)) VALUES (\(strValues))", values: [4])
                        success = true
                        group.leave()
                    } catch {
                        success = false
                        group.leave()
                    }
                }
                group.notify(queue: .main) {
                    //  print(success)
                    callBack(success)
                }
            })
        }
    }
    
    
    func deleteRow(rowName : String, rowID : String, withTableName tableName: String, callBack : @escaping ((_ success : Bool)-> Void)){
        database?.open()
        let sqlDeleteQuery = "DELETE FROM \(tableName)  where \(rowName)=\(rowID)"
        // Query result
        do {
            try database?.executeUpdate(sqlDeleteQuery, values: [4])
            database?.close()
            callBack(true)
        } catch {
            callBack(false)
        }
    }
    
    // MARK: Get
    func getAllDataFromDB(withTableName tblName: String) -> [[String : Any]] {
        database?.open()
        let sqlSelectQuery = "SELECT * FROM \(tblName)"
        var arrResult = [[String : Any]]()
        
        // Query result
        do {
            let resultSet: FMResultSet? = try database?.executeQuery(sqlSelectQuery, values: [String]())
            while (resultSet?.next())! {
                //print("\(resultSet?.resultDictiony)")
                arrResult.append(resultSet?.resultDictionary! as! [String : Any])
            }
            database?.close()
            
        } catch {
        }
        return arrResult
    }
    
    
    
    func getDataFromDB(withTableName tblName: String, withFieldName fieldName: String, withFieldValue fieldValue: String) -> [[String : Any]] {
        database?.open()
        let sqlSelectQuery = "SELECT * FROM \(tblName) where \(fieldName) = \(fieldValue)"
        
        var arrResult = [[String : Any]]()
        
        // Query result
        do {
            let resultSet: FMResultSet? = try database?.executeQuery(sqlSelectQuery, values: [String]())
            while (resultSet?.next())! {
                //print("\(resultSet?.resultDictiony)")
                arrResult.append(resultSet?.resultDictionary! as! [String : Any])
            }
            database?.close()
            
        } catch {
        }
        return arrResult
    }
    
    func getDataFromDB(withTableName tblName: String,  fieldName: String, fieldValue: String, fieldName2: String, fieldValue2: String) -> [[String : Any]] {
        database?.open()
        let sqlSelectQuery = "SELECT * FROM \(tblName) where \(fieldName) = \(fieldValue) AND \(fieldName2) = \(fieldValue2)"
        
        var arrResult = [[String : Any]]()
        
        // Query result
        do {
            let resultSet: FMResultSet? = try database?.executeQuery(sqlSelectQuery, values: [String]())
            while (resultSet?.next())! {
                //print("\(resultSet?.resultDictiony)")
                arrResult.append(resultSet?.resultDictionary! as! [String : Any])
            }
            database?.close()
            
        } catch {
        }
        return arrResult
    }
    
    func updateMultipleRowValues(withTableName tblName: String, withParameter dict: [String : Any], rowID : String, rowName : String, callBack :  @escaping ((_ success : Bool)-> Void))  {
        database?.open()
        
        let paramString = (dict.compactMap({ (arg) -> String in
            let (key, value) = arg
            return "\(key)='\(CheckNullString(value: value as AnyObject))'"
        }) as Array).joined(separator: ",")
        
        let sqlSelectQuery = "UPDATE \(tblName) SET \(paramString) where \(rowName)=\(rowID)"
        do {
            try database?.executeUpdate(sqlSelectQuery, values: [4])
            database?.close()
            callBack(true)
        } catch {
            callBack(false)
        }
    }
    
    func updateRow(withTableName tblName: String,  fieldName: String, fieldValue: String, rowID : String, rowName : String) {
        database?.open()
        let sqlSelectQuery = "UPDATE \(tblName) SET \(fieldName)=\(fieldValue) where \(rowName)=\(rowID)"
        
        // Query result
        do {
            try database?.executeUpdate(sqlSelectQuery, values: [4])
            database?.close()
        } catch {
        }
    }
    
    func getDataFromDB(withTableName tblName: String,  fieldName: String,  fieldValue: String,  fieldName2: String,  fieldValue2: String, callBack :  ((_ result :[[String : Any]])-> Void)) {
        database?.open()
        let sqlSelectQuery = "SELECT * FROM \(tblName) where \(fieldName) = \(fieldValue) AND \(fieldName2) = \(fieldValue2)"
        
        var arrResult = [[String : Any]]()
        
        // Query result
        do {
            let resultSet: FMResultSet? = try database?.executeQuery(sqlSelectQuery, values: [String]())
            while (resultSet?.next())! {
                //print("\(resultSet?.resultDictiony)")
                arrResult.append(resultSet?.resultDictionary! as! [String : Any])
            }
            database?.close()
            
        } catch {
        }
        callBack(arrResult)
    }
    
    func searchDataFromDB(withTableName tblName: String, withFieldName fieldName: String, withFieldValue fieldValue: String) -> [[String : Any]] {
        database?.open()
        //let sqlSelectQuery = "SELECT * FROM \(tblName) where \(fieldName) = \(fieldValue)"
        let sqlSelectQuery = "SELECT * FROM \(tblName) where \(fieldName) LIKE '\(fieldValue)%'"
        
        var arrResult = [[String : Any]]()
        
        // Query result
        do {
            let resultSet: FMResultSet? = try database?.executeQuery(sqlSelectQuery, values: [String]())
            while (resultSet?.next())! {
                //print("\(resultSet?.resultDictiony)")
                arrResult.append(resultSet?.resultDictionary! as! [String : Any])
            }
            database?.close()
            
        } catch {
        }
        return arrResult
    }
    
    
}
