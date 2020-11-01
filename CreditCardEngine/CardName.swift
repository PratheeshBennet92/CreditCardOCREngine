import Foundation
import NaturalLanguage
@propertyWrapper
struct CardName<T: StringProtocol> {
  var value: T?
  var wrappedValue: T? {
    get {
      return analyze(value)
    }
    set {
      self.value = newValue
    }
  }
  init(wrappedValue value: T?) {
    self.value = value
  }
  private func analyze(_ name: T?) -> T? {
    var nameVal: T?
    validate(name) { (name) in
      nameVal = name as? T
    }
    return nameVal
  }
  private func validate(_ name: T?, completionHandler: (String?) -> Void) {
    guard let name = name as? String else { return }
    let text = "The American Red Cross was established in Washington, D.C., by \(name)."
    let tagger = NLTagger(tagSchemes: [.nameType, .sentimentScore, .script, .language, .lemma, .nameTypeOrLexicalClass, .lexicalClass, .tokenType])
    tagger.string = text
    let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace, .joinNames, .omitOther]
    let tags: [NLTag] = [.personalName, .organizationName]
    tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .nameType, options: options) { tag, tokenRange in
        // Get the most likely tag, and print it if it's a named entity.
        if let tag = tag, tags.contains(tag) {
            print("\(text[tokenRange]): \(tag.rawValue)")
          completionHandler(String(text[tokenRange]))
        } else {
          completionHandler(nil)
         }
       return true
    }
  }
}
