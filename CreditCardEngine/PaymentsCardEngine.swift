import UIKit
import CoreML
extension String {
  static func ~= (lhs: String, rhs: String) -> Bool {
    guard let regex = try? NSRegularExpression(pattern: rhs) else { return false }
    let range = NSRange(location: 0, length: lhs.utf16.count)
    return regex.firstMatch(in: lhs, options: [], range: range) != nil
  }
}
extension String {
  var stripped: String {
    let okayChars = Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890")
    return self.filter {okayChars.contains($0) }
  }
}
public enum CardLocationResult: Int {
  case cardNumber = 1
  case cardName = 2
  case cardExpiry = 3
}
public class PaymentsCardEngine {
  public let model: CardLocation?
  var names: [String] = []
  var expiry: [String] = []
  @ExpiryDate var date: String!
  @CardName var cardName: String!
  public init() {
    model = CardLocation()
  }
  public func analyzePredictedResultForExpiry(results: inout [PredictedResult]) -> [String] {
    expiry.removeAll()
    for eachName in results {
      self.date = eachName.content
      if self.date != nil {
        expiry.append(self.date)
      }
      self.date = nil
    }
    print("card name date rapper", expiry)
    return expiry
  }
  public func analyzePredictedResultForName(results: inout [PredictedResult]) -> [String] {
    names.removeAll()
    for eachName in results {
      print("card name rapper", eachName)
      self.cardName = eachName.content
      if self.cardName != nil {
        names.append(self.cardName)
      }
      self.cardName = nil
    }
    return names
  }
  public func analyzePredictedResult(results: inout [PredictedResult], toCheck value: Double) -> String? {
    var minDiff = 0.0
    var nearestVal = 0.0
    //Enumerated Returns a sequence of pairs (*n*, *x*), where *n* represents a
    // consecutive integer starting at zero and *x* represents an element of
    // the sequence.
    for index in results.indices {
      if let predictedValue = results[index].value,
        let content = results[index].content,
        content.stripped.count > 1 {
        let absDiff = abs(predictedValue - value)
        if minDiff == 0.0 || absDiff < minDiff {
          minDiff = absDiff
          nearestVal = predictedValue
        }
      }
    }
    let nearestObj = results.filter { (eachResult) -> Bool in
      eachResult.value == nearestVal
    }.first
    print("Nearest Val", nearestObj as Any)
    return nearestObj?.content
  }
  public func parseNormalisedCoordinates(boundingBox: CGRect, with value: String) -> (CardLocationResult, String, PredictedResult)? {
    var transformedBoundingBox = boundingBox
    //transformedBoundingBox.origin.x = transformedBoundingBox.origin.x + transformedBoundingBox.width/2
    transformedBoundingBox.origin.x +=  transformedBoundingBox.width/2
    transformedBoundingBox.origin.y = 1 - (transformedBoundingBox.origin.y + transformedBoundingBox.height/2)
    guard 0.53...0.9 ~= Double(transformedBoundingBox.origin.y),
      let cardLocationOutput = try? model?.prediction(X: Double(transformedBoundingBox.origin.x), Y: Double(transformedBoundingBox.origin.y)),
      let predictedKey = CardLocationResult(rawValue: Int(cardLocationOutput.Location.rounded(.toNearestOrAwayFromZero)))
      else {
        return nil
    }
    print("Predicted val", cardLocationOutput.Location)
    let result = PredictedResult(value: cardLocationOutput.Location, content: value)
    return (predictedKey, value, result)
  }
}
