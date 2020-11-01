import Foundation
enum DateRegex: String, CaseIterable {
  case regex1 = "[0-9][0-9]/[0-9][0-9]"
  case regex2 = "[0-9][0-9]/[0-9][0-9][0-9][0-9]"
  case regex3 = "[0-9][0-9]-[0-9][0-9]"
  case regex4 = "[0-9][0-9]-[0-9][0-9][0-9][0-9]"
  case regex5 = "[0-9][0-9]/[0-9][0-9]/[0-9][0-9]"
  //case Regex5 = "[0-9][0-9][0-9][0-9]"
}
@propertyWrapper
struct ExpiryDate<T: StringProtocol> {
  var value: T?
  var wrappedValue: T? {
    get {
      return validateText(value)
    } set {
      value = newValue
    }
  }
  init(wrappedValue value: T?) {
      self.value = value
  }
  private func validateText (_ date: T?) -> T? {
    guard let date = date as? String else { return nil }
    var resultDate: String?
    for regex in DateRegex.allCases {
      if let result = matches(for: regex.rawValue, in: date) {
        resultDate = result
        break
      }
    }
    return resultDate as? T
  }
  private func matches(for regex: String, in text: String) -> String? {
    do {
      let regex = try NSRegularExpression(pattern: regex)
      guard let results = regex.firstMatch(in: text,
                                           range: NSRange(text.startIndex..., in: text)),
        let range = Range(results.range, in: text)
        else { return nil }
      return String(text[range])
    } catch let error {
      print("invalid regex: \(error.localizedDescription)")
      return nil
    }
  }
}
