//
//  RxFirebaseAuth.swift
//  RxFirebase
//
//  Created by David Wong on 05/19/2016.
//  Copyright (c) 2016 David Wong. All rights reserved.
//

import FirebaseAnalytics
import FirebaseAuth
import RxSwift

public extension FIRAuth {
    /**
     Registers for an "auth state did change" observable. Invoked when:
     - Registered as a listener
     - The current user changes, or,
     - The current user's access token changes.
     */
    var rx_addAuthStateDidChangeListener: Observable<(FIRAuth, FIRUser?)> {
        get {
            return Observable.create { observer in
                let listener = self.addAuthStateDidChangeListener({ (auth, user) in
                    observer.onNext((auth, user))
                })
                return AnonymousDisposable {
                    self.removeAuthStateDidChangeListener(listener)
                }
            }
        }
    }
    
    /**
     Sign in with email address and password.
     @param email The user's email address.
     @param password The user's password.
    */
    func rx_signinWithEmail(email: String, password: String) -> Observable<FIRUser?> {
        return Observable.create { observer in
            
            self.signInWithEmail(email, password: password, completion: { (user, error) in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(user)
                    observer.onCompleted()
                }
            })
            
            return NopDisposable.instance
        }
    }
    
    /** 
        sign in anonymously
    */
    func rx_signInAnonymously() -> Observable<FIRUser?> {
        return Observable.create { observer in
            self.signInAnonymouslyWithCompletion({ (user, error) in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(user)
                    observer.onCompleted()
                }
            })
            
            return NopDisposable.instance
        }
    }
    
    /**
     Sign in with credential.
     @param credentials An instance of FIRAuthCredential (Facebook, Twitter, Github, Google)
    */
    func rx_signInWithCredentials(credentials: FIRAuthCredential) -> Observable<FIRUser?> {
        return Observable.create { observer in
            FIRAuth.auth()?.signInWithCredential(credentials, completion: { (user, error) in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(user)
                    observer.onCompleted()
                }
            })
            
            return NopDisposable.instance
        }
    }
    
    /**
     Sign in with custom token.
     @param A custom token. Please see Firebase's documentation on how to set this up.
    */
    func rx_signInWithCustomToken(token: String) -> Observable<FIRUser?> {
        return Observable.create { observer in
            self.signInWithCustomToken(token, completion: { (user, error) in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(user)
                    observer.onCompleted()
                }
            })
            
            return NopDisposable.instance
        }
    }
    
    /**
     Create and on success sign in a user with the given email address and password.
     @param email The user's email address.
     @param password The user's desired password
    */
    func rx_createUserWithEmail(email: String, password: String) -> Observable<FIRUser?> {
        return Observable.create { observer in
            self.createUserWithEmail(email, password: password, completion: { (user, error) in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(user)
                    observer.onCompleted()
                }
            })
            
            return NopDisposable.instance
        }
    }
    
}
