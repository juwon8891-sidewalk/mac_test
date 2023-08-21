// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? JSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation

// MARK: - Welcome
struct VerifivateVersionDataModel: Codable {
    let statusCode: Int
    let message: String
    let data: VerifivateVersionData
}

// MARK: - DataClass
struct VerifivateVersionData: Codable {
    let version, versionPath: String
    let isMaintenance: Bool
    let maintenanceTitle, maintenanceContent, maintenanceLink: String?
}
