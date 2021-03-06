import Foundation

// DON'T EDIT THIS FILE: IT'S GENERATED BY BENDER SCRIPT

// API Version: 20210821124343

struct ItemsDto: Codable {
  let identifier: Int
  let name: String?
  let done: Bool?
  let todoId: Int
  let createdAt: Date
  let updatedAt: Date
  
  enum CodingKeys: String, CodingKey {
    case identifier = "id"
    case name = "name"
    case done = "done"
    case todoId = "todo_id"
    case createdAt = "created_at"
    case updatedAt = "updated_at"
  }
}
