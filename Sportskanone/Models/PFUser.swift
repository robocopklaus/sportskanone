//
//  PFUser.swift
//  Sportskanone
//
//  Created by Fabian Pahl on 01.04.17.
//  Copyright © 2017 21st digital GmbH. All rights reserved.
//

import Parse

extension PFUser: UserType {

  var name: String {
    return username ?? ""
  }

}

extension PFUser {

  var usernameQuery: PFQuery<PFObject> {
    guard let userQuery = PFUser.query(), let username = username else {
      fatalError("Query or username must not be nil")
    }
    return userQuery.whereKey("username", equalTo: username)
  }

}
