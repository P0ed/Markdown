import Foundation

public class Tokeniser {
	let rules: [CharacterRule]
	var replacements: [String: [Token]] = [:]
	
	let newlines = CharacterSet.newlines
	let spaces = CharacterSet.whitespaces

	
	public init(rules: [CharacterRule]) {
		self.rules = rules
	}
	
	/// This goes through every CharacterRule in order and applies it to the input string, tokenising the string
	/// if there are any matches.
	///
	/// The for loop in the while loop (yeah, I know) is there to separate strings from within tags to
	/// those outside them.
	///
	/// e.g. "A string with a \[link\]\(url\) tag" would have the "link" text tokenised separately.
	///
	/// This is to prevent situations like **\[link**\](url) from returing a bold string.
	///
	/// - Parameter inputString: A string to have the CharacterRules in `self.rules` applied to
	public func process(_ inputString: String) -> [Token] {
		guard rules.count > 0, !inputString.isEmpty else { return [Token(type: .string, inputString: inputString)] }

		var mutableRules = self.rules

		var elementArray: [Element] = []
		for char in inputString {
			if newlines.containsUnicodeScalars(of: char) {
				let element = Element(character: char, type: .newline)
				elementArray.append(element)
				continue
			}
			if spaces.containsUnicodeScalars(of: char) {
				let element = Element(character: char, type: .space)
				elementArray.append(element)
				continue
			}
			let element = Element(character: char, type: .string)
			elementArray.append(element)
		}

		while !mutableRules.isEmpty {
			let nextRule = mutableRules.removeFirst()

			let scanner = Scanner(elements: elementArray, rule: nextRule)
			elementArray = scanner.scan()
		}
		
		var output: [Token] = []
		var lastElement = elementArray.first!
		
		func empty( _ string: inout String, into tokens: inout [Token] )  {
			guard !string.isEmpty else {
				return
			}
			var token = Token(type: .string, inputString: string)
			token.metadataStrings.append(contentsOf: lastElement.metadata) 
			token.characterStyles = lastElement.styles
			string.removeAll()
			tokens.append(token)
		}
		
		var accumulatedString = ""
		for element in elementArray {
			guard element.type != .escape else { continue }
			
			if element.type == .string || element.type == .space || element.type == .newline {
				if lastElement.styles != element.styles {
					empty(&accumulatedString, into: &output)
				}
				accumulatedString.append(element.character)
				lastElement = element
			} else {
				empty(&accumulatedString, into: &output)
			}
		}
		empty(&accumulatedString, into: &output)
		
		return output
	}
}
