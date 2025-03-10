//
//  FirebaseData.swift
//  ParkItIOS
//
//  Created by Hadar Pur on 03/04/2019.
//  Copyright © 2019 Hadar Pur. All rights reserved.
//

import Foundation
import FirebaseDatabase
import UIKit

class FirebaseData {
    
    let NUM_OF_HOURS : Int = 3
    let mHoursOfTheDay = ["morning","night","noon"]
    
    var cloudData: Array<Array<Street>> = Array()
    var mDatabaseReferenceArray : Array<DatabaseReference> = Array()

    var mDayOfWeek: String!
    var mRef : DatabaseReference!

    public func cofig(callback: @escaping () -> ()) {
        let numOfDay = Date().dayNumberOfWeek()
        print("numOfDay = \(numOfDay ?? 0)")
        
        switch numOfDay {
        case 7: // saturday
            mDayOfWeek = "Suterday"
            break
        case 6: // friday
            mDayOfWeek = "weekends"
            break
        default: // working days
            mDayOfWeek = "working days"
            break
        }
        
        print("mDayOfWeek = \(mDayOfWeek ?? "")")
        
        self.mRef = Database.database().reference(withPath: mDayOfWeek)
        self.mRef.observeSingleEvent(of: .value, with: { (snapshot) in
            let iterator = snapshot.children
            while let child = iterator.nextObject() as? DataSnapshot {
                var array: Array<Street> = Array()
                let miniIterator = child.children
                while let miniChild = miniIterator.nextObject() as? DataSnapshot {
                    guard let value = miniChild.value as? [String: Any] else { return }
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: value, options: [])
                        let streetItem = try JSONDecoder().decode(Street.self, from: jsonData)
                        
                        array.append(streetItem)
                    } catch let error {
                        print(error)
                    }
                }
                
                print("hour: \(child.key)")
                self.cloudData.append(array)
            }
            callback()
            }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    public func getCloudDataAllArrays() -> Array<Array<Street>> {
        return cloudData
    }
    
    public func getCloudDataArray(index: Int) -> Array<Street> {
        return cloudData[index]
    }
}
