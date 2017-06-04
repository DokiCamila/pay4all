//
//  PostCarteira.swift
//  Pay4All
//
//  Created by Carlos Doki on 03/06/17.
//  Copyright © 2017 Carlos Doki. All rights reserved.
//

import Foundation
import Firebase

class PostCarteira {
    private var _id : String!
    private var _idUser : String!
    private var _nome : String!
    private var _hashBlockChain : String!
    
    var id : String {
        return _id
    }
    
    var idUser: String {
        return _idUser
    }

    var nome: String {
        return _nome
    }
    
    var hashBlockChain: String {
        return _hashBlockChain
    }
    
    init(id: String, idUSer: String, nome: String, hashBlockChain: String) {
        self._id = id
        self._idUser = idUSer
        self._nome = nome
        self._hashBlockChain = hashBlockChain
    }
}

