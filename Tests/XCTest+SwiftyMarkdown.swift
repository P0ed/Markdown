import XCTest
@testable import SwiftyMarkdown

struct StringTest {
	let input: String
	let expectedOutput: String
	var acutalOutput: String = ""
}

struct TokenTest {
	let input: String
	let output: String
	let tokens: [Token]
}

struct ChallengeReturn {
	let tokens: [Token]
	let stringTokens: [Token]
	let links: [Token]
	let attributedString: NSAttributedString
	let foundStyles: [[CharacterStyle]]
	let expectedStyles: [[CharacterStyle]]
}

enum Rule {
	case asterisks
	case backticks
	case underscores
	case links
	case tildes
	
	func asCharacterRule() -> CharacterRule {
		switch self {
		case .links:
			return Parser.characterRules.filter({ $0.primaryTag.tag == "[" }).first!
		case .backticks:
			return Parser.characterRules.filter({ $0.primaryTag.tag == "`" }).first!
		case .tildes:
			return Parser.characterRules.filter({ $0.primaryTag.tag == "~" }).first!
		case .asterisks:
			return Parser.characterRules.filter({ $0.primaryTag.tag == "*" }).first!
		case .underscores:
			return Parser.characterRules.filter({ $0.primaryTag.tag == "_" }).first!
		}
	}
}

class SwiftyMarkdownCharacterTests: XCTestCase {
	let defaultRules = Parser.characterRules
	
	var challenge: TokenTest!
	var results: ChallengeReturn!
	
	func attempt( _ challenge: TokenTest, rules: [Rule]? = nil ) -> ChallengeReturn {
		if let validRules = rules {
			Parser.characterRules = validRules.map({ $0.asCharacterRule() })
		} else {
			Parser.characterRules = defaultRules
		}
		
		let md = Parser()
		md.applyAttachments = false
		let attributedString = md.attributedString(challenge.input)
		let tokens: [Token] = md.tokeniser.process(challenge.input)
		let stringTokens = tokens.filter({ $0.type == .string })
		
		let existentTokenStyles = stringTokens.compactMap({ $0.characterStyles })
		let expectedStyles = challenge.tokens.compactMap({ $0.characterStyles })
		
		let linkTokens = tokens.filter({ $0.type == .string && $0.characterStyles.contains(.link) })
		
		return ChallengeReturn(tokens: tokens, stringTokens: stringTokens, links: linkTokens, attributedString:  attributedString, foundStyles: existentTokenStyles, expectedStyles: expectedStyles)
	}
}


extension XCTestCase {
	
	func resourceURL(for filename: String ) -> URL {
		let thisSourceFile = URL(fileURLWithPath: #file)
		let thisDirectory = thisSourceFile.deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
		return thisDirectory.appendingPathComponent("Resources", isDirectory: true).appendingPathComponent(filename)
	}
	

}


