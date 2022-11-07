//
//  Employees.swift
//  
//
//  Created by Mohsen Qaysi on 19/04/2022.
//

import Foundation

public struct Employees: Codable {
    public let employees: [Employee]
}

// MARK: - Employee
public struct Employee: Codable {
    public let uuid, fullName, phoneNumber, emailAddress: String
    public let biography: String
    public let photoURLSmall, photoURLLarge: String
    public let team: String
    public let employeeType: EmployeeType

    public init(uuid: String, fullName: String, phoneNumber: String, emailAddress: String, biography: String, photoURLSmall: String, photoURLLarge: String, team: String, employeeType: EmployeeType) {
        self.uuid = uuid
        self.fullName = fullName
        self.phoneNumber = phoneNumber
        self.emailAddress = emailAddress
        self.biography = biography
        self.photoURLSmall = photoURLSmall
        self.photoURLLarge = photoURLLarge
        self.team = team
        self.employeeType = employeeType
    }

    enum CodingKeys: String, CodingKey {
        case uuid
        case fullName = "full_name"
        case phoneNumber = "phone_number"
        case emailAddress = "email_address"
        case biography
        case photoURLSmall = "photo_url_small"
        case photoURLLarge = "photo_url_large"
        case team
        case employeeType = "employee_type"
    }
}

public enum EmployeeType: String, Codable {
    case contractor = "CONTRACTOR"
    case fullTime = "FULL_TIME"
    case partTime = "PART_TIME"
}

