import Foundation
public struct PredictedResult: Codable {
  public var value: Double?
  public var content: String?
  public var isNearest: Bool?
  //Public init
  public init(value: Double? = nil, content: String? = nil, isNearest: Bool? = nil) {
    self.value = value
    self.content = content
    self.isNearest = isNearest
  }
}
