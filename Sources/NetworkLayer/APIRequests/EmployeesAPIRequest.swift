//
//  File.swift
//  
//
//  Created by Mohsen Qaysi on 19/04/2022.
//

import Foundation

public struct EmployeesAPIRequest: GetAPIRequest {
    public typealias ResponseType = Employees

    public var endpoint: String {
        return "/employees.json"
    }

    public init() {}
}
