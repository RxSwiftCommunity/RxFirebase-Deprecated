//
//  RxFirebaseStorage.swift
//  Pods
//
//  Created by David Wong on 19/05/2016.
//
//

import Firebase
import FirebaseStorage
import RxSwift

public extension FirebaseStorage.StorageReference {
    // MARK: UPLOAD
    
    /**
     Asynchronously uploads data to the currently specified FIRStorageReference.
     This is not recommended for large files, and one should instead upload a file from disk.
     
     @param uploadData The NSData to upload.
     @param metadata FirebaseStorage.StorageMetadata containing additional information (MIME type, etc.) about the object being uploaded.
     
    */
    func rx_putData(data: NSData, metaData: FirebaseStorage.StorageMetadata? = nil) -> Observable<FirebaseStorage.StorageUploadTask> {
        return Observable.create { observer in
            observer.onNext(self.putData(data as Data, metadata: metaData, completion: { (metadata, error) in }))
            return Disposables.create()
        }
    }
    
    /**
     Asynchronously upload data to the currently specified FIRStorageReference.
     This is not recommended for large files, and one should instead upload a file from disk.
     This method will output upload progress and success or failure states.
     
     @param uploadData The NSData to upload.
     @param metadata FirebaseStorage.StorageMetadata containing additional information (MIME type, etc.) about the object being uploaded.
    */
    func rx_putDataWithProgress(data: NSData, metaData: FirebaseStorage.StorageMetadata? = nil) -> Observable<(FirebaseStorage.StorageTaskSnapshot, FirebaseStorage.StorageTaskStatus)> {
        return rx_putData(data: data, metaData: metaData).rx_storageStatus()
    }
    
    /**
     Asynchronously uploads a file to the currently specified FIRStorageReference.
     
     @param fileURL A URL representing the system file path of the object to be uploaded.
     @param metadata FirebaseStorage.StorageMetadata containing additional information (MIME type, etc.) about the object being uploaded.
    */
    func rx_putFile(path: NSURL, metadata: FirebaseStorage.StorageMetadata? = nil) -> Observable<FirebaseStorage.StorageUploadTask> {
        return Observable.create { observer in
            let uploadTask = self.putFile(from: path as URL, metadata: metadata, completion: { (metadata, error) in })
            observer.onNext(uploadTask)
            return Disposables.create {
                uploadTask.cancel()
            }
        }
    }
    
    /**
     Asynchronously uploads a file to the currently specified FIRStorageReference.
     This method will output upload progress and success or failure states.
     
     @param fileURL A URL representing the system file path of the object to be uploaded.
     @param metadata FirebaseStorage.StorageMetadata containing additional information (MIME type, etc.) about the object being uploaded.
     */
    func rx_putFileWithProgress(path: NSURL, metaData: FirebaseStorage.StorageMetadata? = nil) -> Observable<(FirebaseStorage.StorageTaskSnapshot, FirebaseStorage.StorageTaskStatus)> {
        return rx_putFile(path: path).rx_storageStatus()
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
            let download = self.getData(maxSize: size, completion: { (data, error) in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(data! as NSData)
                    observer.onCompleted()
                }
            })
            return Disposables.create {
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
    func rx_dataWithMaxSizeProgress(size: Int64) -> Observable<(NSData?, FirebaseStorage.StorageTaskSnapshot?, FirebaseStorage.StorageTaskStatus?)> {
        return Observable.create { observer in
            let download = self.getData(maxSize: size, completion: { (data, error) in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext((data! as NSData, nil, .success))
                    observer.onCompleted()
                }
            })
            
            download.observe(.progress, handler: { (snapshot: FirebaseStorage.StorageTaskSnapshot) in
                if let error = snapshot.error {
                    observer.onError(error)
                } else {
                    observer.onNext((nil, snapshot, .progress))
                }
            })
            
            return Disposables.create {
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
            let download = self.write(toFile: localURL as URL, completion: { (url, error) in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(url! as NSURL)
                    observer.onCompleted()
                }
            })
            return Disposables.create {
                download.cancel()
            }
        }
    }
    
    /**
     Asynchronously downloads the object at the current path to a specified system filepath.
     
     This method will output upload progress and success states.
     
     @param fileURL A file system URL representing the path the object should be downloaded to.
     */
    func rx_writeToFileWithProgress(localURL: NSURL) -> Observable<(NSURL?, FirebaseStorage.StorageTaskSnapshot?, FirebaseStorage.StorageTaskStatus?)> {
        return Observable.create { observer in
            let download = self.write(toFile: localURL as URL, completion: { (url, error) in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext((url! as NSURL, nil, .success))
                    observer.onCompleted()
                }
            })
            
            download.observe(.progress, handler: { (snapshot: FirebaseStorage.StorageTaskSnapshot) in
                if let error = snapshot.error {
                    observer.onError(error)
                } else {
                    observer.onNext((nil, snapshot, .progress))
                }
            })
            
            return Disposables.create {
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
            self.downloadURL(completion: { (url, error) in
                if let error = error {
                    observable.onError(error)
                } else {
                    observable.onNext(url! as NSURL)
                    observable.onCompleted()
                }
            })
            return Disposables.create()
        }
    }
    
    // MARK: DELETE
    /**
     Deletes the object at the current path.
    */
    func rx_delete() -> Observable<Void> {
        return Observable.create { observable in
            self.delete(completion: { error in
                if let error = error {
                    observable.onError(error)
                } else {
                    observable.onNext()
                    observable.onCompleted()
                }
            })
            return Disposables.create()
        }
    }
    
    // MARK: METADATA
    /**
     Retrieves metadata associated with an object at the current path.
    */
    func rx_metadata() -> Observable<FirebaseStorage.StorageMetadata?> {
        return Observable.create { observer in
            self.getMetadata(completion: { (metadata, error) in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(metadata)
                    observer.onCompleted()
                }
            })
            return Disposables.create()
        }
    }
    
    /**
     Updates the metadata associated with an object at the current path.
     
     @param metadata An FirebaseStorage.StorageMetadata object with the metadata to update.
    */
    func rx_updateMetadata(metadata: FirebaseStorage.StorageMetadata) -> Observable<FirebaseStorage.StorageMetadata?> {
        return Observable.create { observer in
            self.updateMetadata(metadata, completion: { (metadata, error) in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(metadata)
                    observer.onCompleted()
                }
            })
            return Disposables.create()
        }
    }
    
}

extension FirebaseStorage.StorageUploadTask {
    func rx_observeStatus(status: FirebaseStorage.StorageTaskStatus) -> Observable<(FirebaseStorage.StorageTaskSnapshot, FirebaseStorage.StorageTaskStatus)> {
        return Observable.create { observer in
            let observeStatus = self.observe(status, handler: { (snapshot: FirebaseStorage.StorageTaskSnapshot) in
                if let error = snapshot.error {
                    observer.onError(error)
                } else {
                    observer.onNext((snapshot, status))
                    if status == .success {
                        observer.onCompleted()
                    }
                }
            })
            return Disposables.create {
                self.removeObserver(withHandle: observeStatus)
            }
        }
    }
}

extension FirebaseStorage.StorageDownloadTask {
    func rx_observeStatus(status: FirebaseStorage.StorageTaskStatus) -> Observable<(FirebaseStorage.StorageTaskSnapshot, FirebaseStorage.StorageTaskStatus)> {
        return Observable.create { observer in
            let observeStatus = self.observe(status, handler: { snapshot in
                if let error = snapshot.error {
                    observer.onError(error)
                } else {
                    observer.onNext((snapshot, status))
                    if status == .success {
                        observer.onCompleted()
                    }
                }
            })
            return Disposables.create {
                self.removeObserver(withHandle: observeStatus)
            }
        }
    }
}

extension ObservableType where E : FirebaseStorage.StorageUploadTask {
    func rx_storageStatus() -> Observable<(FirebaseStorage.StorageTaskSnapshot, FirebaseStorage.StorageTaskStatus)> {
        return self.flatMap { (uploadTask: FirebaseStorage.StorageUploadTask) -> Observable<(FirebaseStorage.StorageTaskSnapshot, FirebaseStorage.StorageTaskStatus)> in
            let progressStatus = uploadTask.rx_observeStatus(status: .progress)
            let successStatus = uploadTask.rx_observeStatus(status: .puccess)
            let failureStatus = uploadTask.rx_observeStatus(status: .failure)
            
            let merged = Observable.of(progressStatus, successStatus, failureStatus).merge()
            return merged
        }
    }
}

extension ObservableType where E : FirebaseStorage.StorageDownloadTask {
    func rx_storageStatus() -> Observable<(FirebaseStorage.StorageTaskSnapshot, FirebaseStorage.StorageTaskStatus)> {
        return self.flatMap { (downloadTask: FirebaseStorage.StorageDownloadTask) -> Observable<(FirebaseStorage.StorageTaskSnapshot, FirebaseStorage.StorageTaskStatus)> in
            let progressStatus = downloadTask.rx_observeStatus(status: .progress)
            let successStatus = downloadTask.rx_observeStatus(status: .success)
            let failureStatus = downloadTask.rx_observeStatus(status: .failure)
            
            let merged = Observable.of(progressStatus, successStatus, failureStatus).merge()
            return merged
        }
    }
}
