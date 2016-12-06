//
//  RxFirebaseDatabase.swift
//  Pods
//
//  Created by David Wong on 19/05/2016.
//
//

import FirebaseDatabase
import RxSwift

public extension FIRDatabaseQuery {
    /**
     Listen for data changes at a particular location.
     This is the primary way to read data from the Firebase Database. The observers 
     will be triggered for the initial data and again whenever the data changes.
     
     @param eventType The type of event to listen for.
    */
    func rx_observe(eventType: FIRDataEventType) -> Observable<FIRDataSnapshot> {
        return Observable.create { observer in
            let handle = self.observeEventType(eventType) { (snapshot) in
                observer.onNext(snapshot)
            }
            return AnonymousDisposable {
                self.removeObserverWithHandle(handle)
            }
        }
    }
    /**
     Listen for data changes at a particular location. This is the primary way to read data from
     the Firebase Database. The observers will be triggered for the initial data and again 
     whenever the data changes. In addition, for FIRDataEventTypeChildAdded,FIRDataEventTypeChildMoved 
     and FIRDataEventTypeChildChanged, your block will be passed the key of the previous node by
     priority order.
     
     @param eventType The type of event to listen for.
    */
    func rx_observeWithSiblingKey(eventType: FIRDataEventType) -> Observable<(FIRDataSnapshot, String?)> {
        return Observable.create { observer in
            let handle = self.observeEventType(eventType, andPreviousSiblingKeyWithBlock: { (snapshot, siblingKey) in
                observer.onNext((snapshot, siblingKey))
            })
            return AnonymousDisposable {
                self.removeObserverWithHandle(handle)
            }
        }
    }
    
    /**
     This is equivalent to rx_observe(), except the observer is immediately canceled after the initial data is returned.
     
     @param eventType The type of event to listen for.
    */
    func rx_observeSingleEventOfType(eventType: FIRDataEventType) -> Observable<FIRDataSnapshot> {
        return Observable.create { observer in
            self.observeSingleEventOfType(eventType, withBlock: { (snapshot) in
                observer.onNext(snapshot)
                observer.onCompleted()
            })
            
            return NopDisposable.instance
        }
    }
    
    /**
     This is equivalent to rx_observeWithSiblingKey(), except the observer is immediately 
     canceled after the initial data is returned.
     
     @param eventType The type of event to listen for.
    */
    func rx_observeSingleEventOfTypeWithSiblingKey(eventType: FIRDataEventType) -> Observable<(FIRDataSnapshot, String?)> {
        return Observable.create { observer in
            self.observeSingleEventOfType(eventType, andPreviousSiblingKeyWithBlock: { (snapshot, string) in
                observer.onNext((snapshot, string))
                observer.onCompleted()
            })
            return NopDisposable.instance
        }
    }
}

public extension FIRDatabaseReference {
    /**
     Update changes the values at the specified paths in the dictionary without 
     overwriting other keys at this location
     
     @param values A dictionary of keys to change and their new values
    */
    func rx_updateChildValues(values: [String : AnyObject]) -> Observable<FIRDatabaseReference> {
        return Observable.create { observer in
            self.updateChildValues(values, withCompletionBlock: { (error, databaseReference) in
                if let error = error {
                    observer.onError(error)
                    return
                } else {
                    observer.onNext(databaseReference)
                    observer.onCompleted()
                }
            })
            
            return NopDisposable.instance
        }
    }
    
    /**
     Write data to this Firebase Database location.
     
     This will overwrite any data at this location and all child locations.
     
     Data types that can be set are:
     
     - String / NSString
     - NSNumber
     - Dictionary<String: AnyObject> / NSDictionary
     - Array<Above objects> / NSArray
     
     The effect of the write will be visible immediately and the correspoding 
     events will be triggered. Synchronization of the data to the Firebase Database 
     servers will also be started.
     
     Passing null for the new value is equivalent to calling remove()
     all data at this location or any child location will be deleted.
     
     Note that rx_setValue() will remove any priority stored at this location, 
     so if priority is meant to be preserved, you should use setValue(value:, priority:) instead.
     
     @param value The value to be written
     @param priority The Priority to be attached to the data.
    */
    func rx_setValue(value: AnyObject!, priority: AnyObject? = nil) -> Observable<FIRDatabaseReference> {
        return Observable.create { observer in
            self.setValue(value, andPriority: priority, withCompletionBlock: { (error, databaseReference) in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(databaseReference)
                    observer.onCompleted()
                }
            })
            return NopDisposable.instance
        }
    }
    
    /**
     Remove the data at this Firebase Database location. Any data at child locations will also be deleted.
     
     The effect of the delete will be visible immediately and the corresponding events
     will be triggered. Synchronization of the delete to the Firebase Database servers will 
     also be started.
    */
    func rx_removeValue() -> Observable<FIRDatabaseReference> {
        return Observable.create { observer in
            self.removeValueWithCompletionBlock({ (error, databaseReference) in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(databaseReference)
                    observer.onCompleted()
                }
            })
            return NopDisposable.instance
        }
    }
    /**
     Performs an optimistic-concurrency transactional update to the data at this location. Your block will be called with a FIRMutableData
     instance that contains the current data at this location. Your block should update this data to the value you
     wish to write to this location, and then return an instance of FIRTransactionResult with the new data.
     
     If, when the operation reaches the server, it turns out that this client had stale data, your block will be run again with the latest data from the server.
     
     When your block is run, you may decide to aport the traansaction by return FIRTransactionResult.abort()
     
     @param block This block receives the current data at this location and must return an instance of FIRTransactionResult
    */
    func rx_runTransactionBlock(block: ((FIRMutableData!) -> FIRTransactionResult)!) -> Observable<(isCommitted: Bool, snapshot: FIRDataSnapshot?)> {
        return Observable.create { observer in
            self.runTransactionBlock(block, andCompletionBlock: { (error, isCommitted, snapshot) in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext((isCommitted, snapshot))
                    observer.onCompleted()
                }
            })
            return NopDisposable.instance
        }
    }
    
    /**
     Set a priority for the data at this Firebase Database location.
     Priorities can be used to provide a custom ordering for the children at a location
     (if no priorities are specified, the children are ordered by key).
     
     You cannot set a priority on an empty location. For this reason
     setValue:andPriority: should be used when setting initial data with a specific priority
     and setPriority: should be used when updating the priority of existing data.
     
     Children are sorted based on this priority using the following rules:
     
     Children with no priority come first.
     Children with a number as their priority come next. They are sorted numerically by priority (small to large).
     Children with a string as their priority come last. They are sorted lexicographically by priority.
     Whenever two children have the same priority (including no priority), they are sorted by key. Numeric
     keys come first (sorted numerically), followed by the remaining keys (sorted lexicographically).
     
     Note that priorities are parsed and ordered as IEEE 754 double-precision floating-point numbers.
     Keys are always stored as strings and are treated as numbers only when they can be parsed as a
     32-bit integer
     
     @param priority The priority to set at the specified location.
     */
    func rx_setPriority(priority : AnyObject) -> Observable<FIRDatabaseReference> {
        return Observable.create { observer in
            self.setPriority(priority, withCompletionBlock: { (error, databaseReference) in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(databaseReference)
                    observer.onCompleted()
                }
            })
            return NopDisposable.instance
        }
    }
    
    /**
     Ensure the data at this location is set to the specified value when
     the client is disconnected (due to closing the browser, navigating
     to a new page, or network issues).
     
     onDisconnectSetValue() is especially useful for implementing "presence" systems,
     where a value should be changed or cleared when a user disconnects
     so that he appears "offline" to other users.
     
     @param value The value to be set after the connection is lost.
     @param priority The priority to be set after the connection is lost.
    */
    func rx_onDisconnectSetValue(value: AnyObject, priority: AnyObject? = nil) -> Observable<FIRDatabaseReference> {
        return Observable.create { observer in
            self.onDisconnectSetValue(value, andPriority: priority, withCompletionBlock: { (error, databaseReference) in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(databaseReference)
                    observer.onCompleted()
                }
            })
            return NopDisposable.instance
        }
    }
    
    /**
     Ensure the data has the specified child values updated when
     the client is disconnected (due to closing the browser, navigating 
     to a new page, or network issues).
     
     @param values A dictionary of child node keys and the values to set them to after the connection is lost.
    */
    func rx_onDisconnectUpdateChildValue(values: [String : AnyObject]) -> Observable<FIRDatabaseReference> {
        return Observable.create { observer in
            self.onDisconnectUpdateChildValues(values, withCompletionBlock: { (error, databaseReference) in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(databaseReference)
                    observer.onCompleted()
                }
            })
            return NopDisposable.instance
        }
    }
    /**
     Ensure the data t this location is removed when
     the client is disconnected (due to closing the app, navigating
     to a new page, or network issues
     
     rx_onDisconnectRemoveValue() is especially useful for implementing "presence systems.
    */
    func rx_onDisconnectRemoveValue() -> Observable<FIRDatabaseReference> {
        return Observable.create { observer in
            self.onDisconnectRemoveValueWithCompletionBlock({ (error, databaseReference) in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(databaseReference)
                    observer.onCompleted()
                }
            })
            return NopDisposable.instance
        }
    }
}


public extension ObservableType where E : FIRDataSnapshot {
    
    func rx_filterWhenNSNull() -> Observable<E> {
        return self.filter { (snapshot) -> Bool in
            return snapshot.value is NSNull
        }
    }
    
    func rx_filterWhenNotNSNull() -> Observable<E> {
        return self.filter { (snapshot) -> Bool in
            return !(snapshot.value is NSNull)
        }
    }
    
    func rx_children() -> Observable<FIRDataSnapshot> {
        return self.flatMap({ (snapshot) -> Observable<FIRDataSnapshot> in
            return Observable.create { observer in
                
                for snapChild in snapshot.children {
                    if let snapChild = snapChild as? FIRDataSnapshot {
                        observer.onNext(snapChild)
                    }
                }
                observer.onCompleted()
                
                return NopDisposable.instance
            }
        })
    }
    
    func rx_childrenAsArray() -> Observable<[FIRDataSnapshot]> {
        return self.flatMap({ (snapshot) -> Observable<[FIRDataSnapshot]> in
            return Observable.create { observer in
                if let array = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    observer.onNext(array)
                }
                observer.onCompleted()
                
                return NopDisposable.instance
            }
        })
    }
    
}