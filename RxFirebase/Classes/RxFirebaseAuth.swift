//
//  RxFirebaseAuth.swift
//  RxFirebase
//
//  Created by David Wong on 05/19/2016.
//  Copyright (c) 2016 David Wong. All rights reserved.
//

import Firebase
import FirebaseAnalytics
import FirebaseAuth
import RxSwift

public extension Firebase.Auth {
    /**
     Registers for an "auth state did change" observable. Invoked when:
     - Registered as a listener
     - The current user changes, or,
     - The current user's access token changes.
     */
    var rx_addAuthStateDidChangeListener: Observable<(Firebase.Auth, Firebase.User?)> {
        get {
            return Observable.create { observer in
                let listener = self.addStateDidChangeListener({ (auth, user) in
                    observer.onNext((auth, user))
                })
                return Disposables.create {
                    self.removeStateDidChangeListener(listener)
                }
            }
        }
    }
    
    /**
     Sign in with email address and password.
     @param email The user's email address.
     @param password The user's password.
    */
    func rx_signinWithEmail(email: String, password: String) -> Observable<Firebase.User> {
        return Observable.create { observer in
            
            self.signIn(withEmail: email, password: password, completion: { (user, error) in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(user!)
                    observer.onCompleted()
                }
            })
            
            return Disposables.create()
        }
    }
    
    /** 
        sign in anonymously
    */
    func rx_signInAnonymously() -> Observable<Firebase.User> {
        return Observable.create { observer in
            self.signInAnonymously(completion: { (user, error) in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(user!)
                    observer.onCompleted()
                }
            })
            
            return Disposables.create()
        }
    }
    
    /**
     Sign in with credential.
     @param credentials An instance of AuthCredential (Facebook, Twitter, Github, Google)
    */
    func rx_signInWithCredentials(credentials: Firebase.AuthCredential) -> Observable<Firebase.User> {
        return Observable.create { observer in
            Firebase.Auth.auth().signIn(with: credentials, completion: { (user, error) in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(user!)
                    observer.onCompleted()
                }
            })
            
            return Disposables.create()
        }
    }
    
    /**
     Sign in with custom token.
     @param A custom token. Please see Firebase's documentation on how to set this up.
    */
    func rx_signInWithCustomToken(token: String) -> Observable<Firebase.User> {
        return Observable.create { observer in
            self.signIn(withCustomToken: token, completion: { (user, error) in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(user!)
                    observer.onCompleted()
                }
            })
            
            return Disposables.create()
        }
    }
    
    /**
     Create and on success sign in a user with the given email address and password.
     @param email The user's email address.
     @param password The user's desired password
    */
    func rx_createUserWithEmail(email: String, password: String) -> Observable<Firebase.User> {
        return Observable.create { observer in
            self.createUser(withEmail: email, password: password, completion: { (user, error) in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(user!)
                    observer.onCompleted()
                }
            })
            
            return Disposables.create()
        }
    }
    
}
