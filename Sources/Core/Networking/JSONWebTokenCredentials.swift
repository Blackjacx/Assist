//
//  JSONWebTokenCredentials.swift
//  Core
//
//  Created by Stefan Herold on 11.08.20.
//


import Foundation

public struct JSONWebTokenCredentials {

  var keyPath: String
  var keyId: String
  var issuerId: String

  public init(keyPath: String, keyId: String, issuerId: String) {
    self.keyPath = keyPath
    self.keyId = keyId
    self.issuerId = issuerId
  }
}