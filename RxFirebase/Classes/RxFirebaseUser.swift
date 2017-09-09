
import Foundation
import RxSwift
import Firebase

public extension Firebase.User {
    
    func rx_reload() -> Observable<Firebase.User> {
        return Observable.create { observer in
            self.reload(completion: { error in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(self)
                    observer.onCompleted()
                }
            })
            
            return Disposables.create()
        }
    }
    
    func rx_link(with credential: AuthCredential) -> Observable<Firebase.User?> {
        return Observable.create { observer in
            self.link(with: credential, completion: { user, error in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(user)
                    observer.onCompleted()
                }
            })
            
            return Disposables.create()
        }

    }
    
}
