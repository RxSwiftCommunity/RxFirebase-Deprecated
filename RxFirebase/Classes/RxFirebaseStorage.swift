//
//  RxFirebaseStorage.swift
//  Pods
//
//  Created by David Wong on 19/05/2016.
//
//

import FirebaseStorage
import RxSwift

public extension FIRStorageReference {
    // MARK: UPLOAD
    
    /**
     Asynchronously uploads data to the currently specified FIRStorageReference.
     This is not recommended for large files, and one should instead upload a file from disk.
     
     @param uploadData The NSData to upload.
     @param metadata FIRStorageMetaData containing additional information (MIME type, etc.) about the object being uploaded.
     
    */
    func rx_putData(data: NSData, metaData: FIRStorageMetadata? = nil) -> Observable<FIRStorageUploadTask> {
        return Observable.create { observer in
            observer.onNext(self.putData(data, metadata: metaData, completion: { (metadata, error) in }))
            return NopDisposable.instance
        }
    }
    
    /**
     Asynchronously upload data to the currently specified FIRStorageReference.
     This is not recommended for large files, and one should instead upload a file from disk.
     This method will output upload progress and success or failure states.
     
     @param uploadData The NSData to upload.
     @param metadata FIRStorageMetaData containing additional information (MIME type, etc.) about the object being uploaded.
    */
    func rx_putDataWithProgress(data: NSData, metaData: FIRStorageMetadata? = nil) -> Observable<(FIRStorageTaskSnapshot, FIRStorageTaskStatus)> {
        return rx_putData(data, metaData: metaData).rx_storageStatus()
    }
    
    /**
     Asynchronously uploads a file to the currently specified FIRStorageReference.
     
     @param fileURL A URL representing the system file path of the object to be uploaded.
     @param metadata FIRStorageMetadata containing additional information (MIME type, etc.) about the object being uploaded.
    */
    func rx_putFile(path: NSURL, metadata: FIRStorageMetadata? = nil) -> Observable<FIRStorageUploadTask> {
        return Observable.create { observer in
            let uploadTask = self.putFile(path, metadata: metadata, completion: { (metadata, error) in })
            observer.onNext(uploadTask)
            return AnonymousDisposable {
                uploadTask.cancel()
            }
        }
    }
    
    /**
     Asynchronously uploads a file to the currently specified FIRStorageReference.
     This method will output upload progress and success or failure states.
     
     @param fileURL A URL representing the system file path of the object to be uploaded.
     @param metadata FIRStorageMetadata containing additional information (MIME type, etc.) about the object being uploaded.
     */
    func rx_putFileWithProgress(path: NSURL, metaData: FIRStorageMetadata? = nil) -> Observable<(FIRStorageTaskSnapshot, FIRStorageTaskStatus)> {
        return rx_putFile(path).rx_storageStatus()
    }
    
    // MARK: DOWNLOAD
    
    /**
     Asynchronously downloads the object at the FIRStorageReference to an NSData Object in memory.
     An NSData of the provided max size will be allocated, so ensure that the device has enough free
     memory to complete the download. For downloading large files, writeToFile may be a better option.
     
     @param size The maximum size in bytes to download.  If the download exceeds this size the task will be cancelled and an error will be returned.
    */
    func rx_dataWithMaxSize(size: Int64) -> Observable<NSData?> {
        return Observable.create { observer in
            let download = self.dataWithMaxSize(size, completion: { (data, error) in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(data)
                    observer.onCompleted()
                }
            })
            return AnonymousDisposable {
                download.cancel()
            }
        }
    }
    /**
     Asynchronously downloads the object at the FIRStorageReference to an NSData Object in memory.
     An NSData of the provided max size will be allocated, so ensure that the device has enough free
     memory to complete the download. For downloading large files, writeToFile may be a better option.
     
     This method will output upload progress and success states.
     
     @param size The maximum size in bytes to download.  If the download exceeds this size the task will be cancelled and an error will be returned.
     */
    func rx_dataWithMaxSizeProgress(size: Int64) -> Observable<(NSData?, FIRStorageTaskSnapshot?, FIRStorageTaskStatus?)> {
        return Observable.create { observer in
            let download = self.dataWithMaxSize(size, completion: { (data, error) in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext((data, nil, .Success))
                    observer.onCompleted()
                }
            })
            
            download.observeStatus(.Progress, handler: { (snapshot: FIRStorageTaskSnapshot) in
                if let error = snapshot.error {
                    observer.onError(error)
                } else {
                    observer.onNext((nil, snapshot, .Progress))
                }
            })
            
            return AnonymousDisposable {
                download.cancel()
            }
        }
    }
    
    /**
     Asynchronously downloads the object at the current path to a specified system filepath.
     
     @param fileURL A file system URL representing the path the object should be downloaded to.
    */
    func rx_writeToFile(localURL: NSURL) -> Observable<NSURL?> {
        return Observable.create { observer in
            let download = self.writeToFile(localURL, completion: { (url, error) in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(url)
                    observer.onCompleted()
                }
            })
            return AnonymousDisposable {
                download.cancel()
            }
        }
    }
    
    /**
     Asynchronously downloads the object at the current path to a specified system filepath.
     
     This method will output upload progress and success states.
     
     @param fileURL A file system URL representing the path the object should be downloaded to.
     */
    func rx_writeToFileWithProgress(localURL: NSURL) -> Observable<(NSURL?, FIRStorageTaskSnapshot?, FIRStorageTaskStatus?)> {
        return Observable.create { observer in
            let download = self.writeToFile(localURL, completion: { (url, error) in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext((url, nil, .Success))
                    observer.onCompleted()
                }
            })
            
            download.observeStatus(.Progress, handler: { (snapshot: FIRStorageTaskSnapshot) in
                if let error = snapshot.error {
                    observer.onError(error)
                } else {
                    observer.onNext((nil, snapshot, .Progress))
                }
            })
            
            return AnonymousDisposable {
                download.cancel()
            }
        }
    }
    
    /**
     Asynchronously retrieves a long lived download URL with a revokable token.
     This can be used to share the file with others, but can be revoked by a developer
     in the Firebase Console if desired.
    */
    func rx_downloadURL() -> Observable<NSURL?> {
        return Observable.create { observable in
            self.downloadURLWithCompletion({ (url, error) in
                if let error = error {
                    observable.onError(error)
                } else {
                    observable.onNext(url)
                    observable.onCompleted()
                }
            })
            return NopDisposable.instance
        }
    }
    
    // MARK: DELETE
    /**
     Deletes the object at the current path.
    */
    func rx_delete() -> Observable<Void> {
        return Observable.create { observable in
            self.deleteWithCompletion({ error in
                if let error = error {
                    observable.onError(error)
                } else {
                    observable.onNext()
                    observable.onCompleted()
                }
            })
            return NopDisposable.instance
        }
    }
    
    // MARK: METADATA
    /**
     Retrieves metadata associated with an object at the current path.
    */
    func rx_metadata() -> Observable<FIRStorageMetadata?> {
        return Observable.create { observer in
            self.metadataWithCompletion({ (metadata, error) in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(metadata)
                    observer.onCompleted()
                }
            })
            return NopDisposable.instance
        }
    }
    
    /**
     Updates the metadata associated with an object at the current path.
     
     @param metadata An FIRStorageMetadata object with the metadata to update.
    */
    func rx_updateMetadata(metadata: FIRStorageMetadata) -> Observable<FIRStorageMetadata?> {
        return Observable.create { observer in
            self.updateMetadata(metadata, completion: { (metadata, error) in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(metadata)
                    observer.onCompleted()
                }
            })
            return NopDisposable.instance
        }
    }
    
}

extension FIRStorageUploadTask {
    func rx_observeStatus(status: FIRStorageTaskStatus) -> Observable<(FIRStorageTaskSnapshot, FIRStorageTaskStatus)> {
        return Observable.create { observer in
            let observeStatus = self.observeStatus(status, handler: { (snapshot: FIRStorageTaskSnapshot) in
                if let error = snapshot.error {
                    observer.onError(error)
                } else {
                    observer.onNext((snapshot, status))
                    if status == .Success {
                        observer.onCompleted()
                    }
                }
            })
            return AnonymousDisposable {
                self.removeObserverWithHandle(observeStatus)
            }
        }
    }
}

extension FIRStorageDownloadTask {
    func rx_observeStatus(status: FIRStorageTaskStatus) -> Observable<(FIRStorageTaskSnapshot, FIRStorageTaskStatus)> {
        return Observable.create { observer in
            let observeStatus = self.observeStatus(status, handler: { snapshot in
                if let error = snapshot.error {
                    observer.onError(error)
                } else {
                    observer.onNext((snapshot, status))
                    if status == .Success {
                        observer.onCompleted()
                    }
                }
            })
            return AnonymousDisposable {
                self.removeObserverWithHandle(observeStatus)
            }
        }
    }
}

extension ObservableType where E : FIRStorageUploadTask {
    func rx_storageStatus() -> Observable<(FIRStorageTaskSnapshot, FIRStorageTaskStatus)> {
        return self.flatMap { (uploadTask: FIRStorageUploadTask) -> Observable<(FIRStorageTaskSnapshot, FIRStorageTaskStatus)> in
            let progressStatus = uploadTask.rx_observeStatus(.Progress)
            let successStatus = uploadTask.rx_observeStatus(.Success)
            let failureStatus = uploadTask.rx_observeStatus(.Failure)
            
            let merged = Observable.of(progressStatus, successStatus, failureStatus).merge()
            return merged
        }
    }
}

extension ObservableType where E : FIRStorageDownloadTask {
    func rx_storageStatus() -> Observable<(FIRStorageTaskSnapshot, FIRStorageTaskStatus)> {
        return self.flatMap { (downloadTask: FIRStorageDownloadTask) -> Observable<(FIRStorageTaskSnapshot, FIRStorageTaskStatus)> in
            let progressStatus = downloadTask.rx_observeStatus(.Progress)
            let successStatus = downloadTask.rx_observeStatus(.Success)
            let failureStatus = downloadTask.rx_observeStatus(.Failure)
            
            let merged = Observable.of(progressStatus, successStatus, failureStatus).merge()
            return merged
        }
    }
}
