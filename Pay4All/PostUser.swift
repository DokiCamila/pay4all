//
//  User.swift
//  Pay4All
//
//  Created by Carlos Doki on 03/06/17.
//  Copyright © 2017 Carlos Doki. All rights reserved.
//

import Foundation
import Firebase

class PostUser {
    private var _nome: String!
    private var _email: String!
    private var _ddd: String!
    private var _celular: String!
    private var _postKey: String!
    private var _postRef: FIRDatabaseReference!
    
    var nome: String {
        return _nome
    }
    
    var email: String {
        return _email
    }
    
    var ddd: String {
        return _ddd
    }
    
    var celular: String {
        return _celular
    }
    
    
    init(nome: String, ddd: String, email: String, celular: String) {
        self._nome = nome
        self._ddd = ddd
        self._email = email
        self._celular = celular
    }
    
    init(postKey: String, postData: Dictionary<String, AnyObject>) {
        self._postKey = postKey
        
        if let caption = postData["nome"] as? String {
            self._nome = nome
        }
        
        if let imageUrl = postData["email"] as? String {
            self._email = email
        }
        
        if let likes = postData["ddd"] as? Int {
            self._ddd = ddd
        }
        
        if let postedDate = postData["celular"] as? Double {
            self._celular = celular
        }
        
        _postRef = DataService.ds.REF_CARTEIRA.child(_postKey)
    }
    

}
