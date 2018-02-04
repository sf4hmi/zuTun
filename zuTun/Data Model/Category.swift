//
//  Category.swift
//  zuTun
//
//  Created by Fahmi Sulaiman on 04.02.18.
//  Copyright © 2018 Fahmi Sulaiman. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var toDelete: Bool = false
}
