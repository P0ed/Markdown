@testable import SwiftyMarkdown
import XCTest

class SwiftyMarkdownLinkTests: SwiftyMarkdownCharacterTests {
	
	func testSingleLinkPositions() {
		challenge = TokenTest(input: "[a](b)", output: "a", tokens: [
			Token(type: .string, inputString: "a", characterStyles: [CharacterStyle.link])
		])
		results = self.attempt(challenge, rules: [.links])
		if results.stringTokens.count == challenge.tokens.count {
			for (idx, token) in results.stringTokens.enumerated() {
				XCTAssertEqual(token.inputString, challenge.tokens[idx].inputString)
				XCTAssertEqual(token.characterStyles, challenge.tokens[idx].characterStyles)
			}
		} else {
			XCTAssertEqual(results.stringTokens.count, challenge.tokens.count)
		}
		XCTAssertEqual(results.foundStyles, results.expectedStyles)
		XCTAssertEqual(results.attributedString.string, challenge.output)
		if let existentOpen = results.tokens.filter({ $0.type == .string && $0.characterStyles.contains(.link) }).first {
			XCTAssertEqual(existentOpen.metadataStrings.first, "b")
		} else {
			XCTFail("Failed to find an open link tag")
		}
		
		challenge = TokenTest(input: "[Link at](http://voyagetravelapps.com/) start", output: "Link at start", tokens: [
			Token(type: .string, inputString: "Link at", characterStyles: [CharacterStyle.link]),
			Token(type: .string, inputString: " start")
		])
		results = self.attempt(challenge)
		if results.stringTokens.count == challenge.tokens.count {
			for (idx, token) in results.stringTokens.enumerated() {
				XCTAssertEqual(token.inputString, challenge.tokens[idx].inputString)
				XCTAssertEqual(token.characterStyles, challenge.tokens[idx].characterStyles)
			}
		} else {
			XCTAssertEqual(results.stringTokens.count, challenge.tokens.count)
		}
		XCTAssertEqual(results.foundStyles, results.expectedStyles)
		XCTAssertEqual(results.attributedString.string, challenge.output)
		if let existentOpen = results.tokens.filter({ $0.type == .string && $0.characterStyles.contains(.link) }).first {
			XCTAssertEqual(existentOpen.metadataStrings.first, "http://voyagetravelapps.com/")
		} else {
			XCTFail("Failed to find an open link tag")
		}
		
		challenge = TokenTest(input: "A [link at end](http://voyagetravelapps.com/)", output: "A link at end", tokens: [
			Token(type: .string, inputString: "A ", characterStyles: []),
			Token(type: .string, inputString: "link at end", characterStyles: [CharacterStyle.link])
		])
		results = self.attempt(challenge)
		if results.stringTokens.count == challenge.tokens.count {
			for (idx, token) in results.stringTokens.enumerated() {
				XCTAssertEqual(token.inputString, challenge.tokens[idx].inputString)
				XCTAssertEqual(token.characterStyles, challenge.tokens[idx].characterStyles)
			}
		} else {
			XCTAssertEqual(results.stringTokens.count, challenge.tokens.count)
		}
		XCTAssertEqual(results.foundStyles, results.expectedStyles)
		XCTAssertEqual(results.attributedString.string, challenge.output)
		
		challenge = TokenTest(input: "A [link in the](http://voyagetravelapps.com/) middle", output: "A link in the middle", tokens: [
			Token(type: .string, inputString: "A ", characterStyles: []),
			Token(type: .string, inputString: "link in the", characterStyles: [CharacterStyle.link]),
			Token(type: .string, inputString: " middle", characterStyles: [])
		])
		results = self.attempt(challenge)
		if results.stringTokens.count == challenge.tokens.count {
			for (idx, token) in results.stringTokens.enumerated() {
				XCTAssertEqual(token.inputString, challenge.tokens[idx].inputString)
				XCTAssertEqual(token.characterStyles, challenge.tokens[idx].characterStyles)
			}
		} else {
			XCTAssertEqual(results.stringTokens.count, challenge.tokens.count)
		}
		XCTAssertEqual(results.foundStyles, results.expectedStyles)
		XCTAssertEqual(results.attributedString.string, challenge.output)
	}
	
	func testEscapedLinks() {
		challenge = TokenTest(input: "\\[a](b)", output: "[a](b)", tokens: [
			Token(type: .string, inputString: "[a](b)", characterStyles: [])
		])
		results = attempt(challenge, rules: [.links])
		if results.stringTokens.count == challenge.tokens.count {
			for (idx, token) in results.stringTokens.enumerated() {
				XCTAssertEqual(token.inputString, challenge.tokens[idx].inputString)
				XCTAssertEqual(token.characterStyles, challenge.tokens[idx].characterStyles)
			}
		} else {
			XCTAssertEqual(results.stringTokens.count, challenge.tokens.count)
		}
		XCTAssertEqual(results.foundStyles, results.expectedStyles)
		XCTAssertEqual(results.attributedString.string, challenge.output)
		
		challenge = TokenTest(input: "![a](b)", output: "!a", tokens: [
			Token(type: .string, inputString: "!", characterStyles: []),
			Token(type: .string, inputString: "a", characterStyles: [CharacterStyle.link])
		])
		results = self.attempt(challenge, rules: [.links])
		if results.stringTokens.count == challenge.tokens.count {
			for (idx, token) in results.stringTokens.enumerated() {
				XCTAssertEqual(token.inputString, challenge.tokens[idx].inputString)
				XCTAssertEqual(token.characterStyles, challenge.tokens[idx].characterStyles)
			}
		} else {
			XCTAssertEqual(results.stringTokens.count, challenge.tokens.count)
		}
		XCTAssertEqual(results.foundStyles, results.expectedStyles)
		XCTAssertEqual(results.attributedString.string, challenge.output)
	}
	
	func testMultipleLinkPositions() {
		
		challenge = TokenTest(input: "[Link 1](http://voyagetravelapps.com/)[Link 2](https://www.neverendingvoyage.com/)", output: "Link 1Link 2", tokens: [
			Token(type: .string, inputString: "Link 1", characterStyles: [CharacterStyle.link]),
			Token(type: .string, inputString: "Link 2", characterStyles: [CharacterStyle.link])
		])
		
		results = self.attempt(challenge)
		if results.stringTokens.count == challenge.tokens.count {
			for (idx, token) in results.stringTokens.enumerated() {
				XCTAssertEqual(token.inputString, challenge.tokens[idx].inputString)
				XCTAssertEqual(token.characterStyles, challenge.tokens[idx].characterStyles)
			}
		} else {
			XCTAssertEqual(results.stringTokens.count, challenge.tokens.count)
		}
		XCTAssertEqual(results.foundStyles, results.expectedStyles)
		XCTAssertEqual(results.attributedString.string, challenge.output)
		var links = results.tokens.filter({ $0.type == .string && $0.characterStyles.contains(.link) })
		if links.count == 2 {
			XCTAssertEqual(links[0].metadataStrings.first, "http://voyagetravelapps.com/")
			XCTAssertEqual(links[1].metadataStrings.first, "https://www.neverendingvoyage.com/")
		} else {
			XCTFail("Incorrect number of links found. Expecting 2, found \(links.count)")
		}
		
		challenge = TokenTest(input: "[Link 1](http://voyagetravelapps.com/), [Link 2](https://www.neverendingvoyage.com/)", output: "Link 1, Link 2", tokens: [
			Token(type: .string, inputString: "Link 1", characterStyles: [CharacterStyle.link]),
			Token(type: .string, inputString: ", ", characterStyles: []),
			Token(type: .string, inputString: "Link 2", characterStyles: [CharacterStyle.link])
		])
		
		results = self.attempt(challenge)
		if results.stringTokens.count == challenge.tokens.count {
			for (idx, token) in results.stringTokens.enumerated() {
				XCTAssertEqual(token.inputString, challenge.tokens[idx].inputString)
				XCTAssertEqual(token.characterStyles, challenge.tokens[idx].characterStyles)
			}
		} else {
			XCTAssertEqual(results.stringTokens.count, challenge.tokens.count)
		}
		XCTAssertEqual(results.foundStyles, results.expectedStyles)
		XCTAssertEqual(results.attributedString.string, challenge.output)
		links = results.tokens.filter({ $0.type == .string && $0.characterStyles.contains(.link) })
		if links.count == 2 {
			XCTAssertEqual(links[0].metadataStrings.first, "http://voyagetravelapps.com/")
			XCTAssertEqual(links[1].metadataStrings.first, "https://www.neverendingvoyage.com/")
		} else {
			XCTFail("Incorrect number of links found. Expecting 2, found \(links.count)")
		}
		
		challenge = TokenTest(input: "String at start [Link 1](http://voyagetravelapps.com/), [Link 2](https://www.neverendingvoyage.com/)", output: "String at start Link 1, Link 2", tokens: [
			Token(type: .string, inputString: "String at start ", characterStyles: []),
			Token(type: .string, inputString: "Link 1", characterStyles: [CharacterStyle.link]),
			Token(type: .string, inputString: ", ", characterStyles: []),
			Token(type: .string, inputString: "Link 2", characterStyles: [CharacterStyle.link])
		])
		
		results = self.attempt(challenge)
		if results.stringTokens.count == challenge.tokens.count {
			for (idx, token) in results.stringTokens.enumerated() {
				XCTAssertEqual(token.inputString, challenge.tokens[idx].inputString)
				XCTAssertEqual(token.characterStyles, challenge.tokens[idx].characterStyles)
			}
		} else {
			XCTAssertEqual(results.stringTokens.count, challenge.tokens.count)
		}
		XCTAssertEqual(results.foundStyles, results.expectedStyles)
		XCTAssertEqual(results.attributedString.string, challenge.output)
		links = results.tokens.filter({ $0.type == .string && $0.characterStyles.contains(.link) })
		if links.count == 2 {
			XCTAssertEqual(links[0].metadataStrings.first, "http://voyagetravelapps.com/")
			XCTAssertEqual(links[1].metadataStrings.first, "https://www.neverendingvoyage.com/")
		} else {
			XCTFail("Incorrect number of links found. Expecting 2, found \(links.count)")
		}
		
		challenge = TokenTest(input: "String at start [Link 1](http://voyagetravelapps.com/)[Link 2](https://www.neverendingvoyage.com/)", output: "String at start Link 1Link 2", tokens: [
			Token(type: .string, inputString: "String at start ", characterStyles: []),
			Token(type: .string, inputString: "Link 1", characterStyles: [CharacterStyle.link]),
			Token(type: .string, inputString: "Link 2", characterStyles: [CharacterStyle.link])
		])
		
		results = self.attempt(challenge)
		if results.stringTokens.count == challenge.tokens.count {
			for (idx, token) in results.stringTokens.enumerated() {
				XCTAssertEqual(token.inputString, challenge.tokens[idx].inputString)
				XCTAssertEqual(token.characterStyles, challenge.tokens[idx].characterStyles)
			}
		} else {
			XCTAssertEqual(results.stringTokens.count, challenge.tokens.count)
		}
		XCTAssertEqual(results.foundStyles, results.expectedStyles)
		XCTAssertEqual(results.attributedString.string, challenge.output)
		links = results.tokens.filter({ $0.type == .string && $0.characterStyles.contains(.link) })
		if links.count == 2 {
			XCTAssertEqual(links[0].metadataStrings.first, "http://voyagetravelapps.com/")
			XCTAssertEqual(links[1].metadataStrings.first, "https://www.neverendingvoyage.com/")
		} else {
			XCTFail("Incorrect number of links found. Expecting 2, found \(links.count)")
		}
		
	}
	
	
	func testForAlternativeURLs() {
		
		
		challenge = TokenTest(input: "Email us at [simon@voyagetravelapps.com](mailto:simon@voyagetravelapps.com) Twitter [@VoyageTravelApp](twitter://user?screen_name=VoyageTravelApp)", output: "Email us at simon@voyagetravelapps.com Twitter @VoyageTravelApp", tokens: [
			Token(type: .string, inputString: "Email us at ", characterStyles: []),
			Token(type: .string, inputString: "simon@voyagetravelapps.com", characterStyles: [CharacterStyle.link]),
			Token(type: .string, inputString: " Twitter ", characterStyles: []),
			Token(type: .string, inputString: "@VoyageTravelApp", characterStyles: [CharacterStyle.link])
		])
		
		results = self.attempt(challenge)
		if results.stringTokens.count == challenge.tokens.count {
			for (idx, token) in results.stringTokens.enumerated() {
				XCTAssertEqual(token.inputString, challenge.tokens[idx].inputString)
				XCTAssertEqual(token.characterStyles, challenge.tokens[idx].characterStyles)
			}
		} else {
			XCTAssertEqual(results.stringTokens.count, challenge.tokens.count)
		}
		XCTAssertEqual(results.foundStyles, results.expectedStyles)
		XCTAssertEqual(results.attributedString.string, challenge.output)
		let links = results.tokens.filter({ $0.type == .string && $0.characterStyles.contains(.link) })
		if links.count == 2 {
			XCTAssertEqual(links[0].metadataStrings.first, "mailto:simon@voyagetravelapps.com")
			XCTAssertEqual(links[1].metadataStrings.first, "twitter://user?screen_name=VoyageTravelApp")
		} else {
			XCTFail("Incorrect number of links found. Expecting 2, found \(links.count)")
		}
	}
		
	func testForLinksMixedWithTokenCharacters() {
		
		challenge = TokenTest(input: "Link ([Surrounded by parentheses](https://www.neverendingvoyage.com/))", output: "Link (Surrounded by parentheses)", tokens: [
			Token(type: .string, inputString: "Link (", characterStyles: []),
			Token(type: .string, inputString: "Surrounded by parentheses", characterStyles: [CharacterStyle.link]),
			Token(type: .string, inputString: ")", characterStyles: [])
		])
		results = self.attempt(challenge)
		if results.stringTokens.count == challenge.tokens.count {
			for (idx, token) in results.stringTokens.enumerated() {
				XCTAssertEqual(token.inputString, challenge.tokens[idx].inputString)
				XCTAssertEqual(token.characterStyles, challenge.tokens[idx].characterStyles)
			}
		} else {
			XCTAssertEqual(results.stringTokens.count, challenge.tokens.count)
		}
		XCTAssertEqual(results.foundStyles, results.expectedStyles)
		XCTAssertEqual(results.attributedString.string, challenge.output)
		var links = results.tokens.filter({ $0.type == .string && $0.characterStyles.contains(.link) })
		if links.count == 1 {
			XCTAssertEqual(links[0].metadataStrings.first, "https://www.neverendingvoyage.com/")
		} else {
			XCTFail("Incorrect number of links found. Expecting 2, found \(links.count)")
		}
		
		challenge = TokenTest(input: "[[Surrounded by square brackets](https://www.neverendingvoyage.com/)]", output: "[Surrounded by square brackets]", tokens: [
			Token(type: .string, inputString: "[", characterStyles: []),
			Token(type: .string, inputString: "Surrounded by square brackets", characterStyles: [CharacterStyle.link]),
			Token(type: .string, inputString: "]", characterStyles: [])
		])
		results = self.attempt(challenge)
		if results.stringTokens.count == challenge.tokens.count {
			for (idx, token) in results.stringTokens.enumerated() {
				XCTAssertEqual(token.inputString, challenge.tokens[idx].inputString)
				XCTAssertEqual(token.characterStyles, challenge.tokens[idx].characterStyles)
			}
		} else {
			XCTAssertEqual(results.stringTokens.count, challenge.tokens.count)
		}
		XCTAssertEqual(results.foundStyles, results.expectedStyles)
		XCTAssertEqual(results.attributedString.string, challenge.output)
		links = results.tokens.filter({ $0.type == .string && $0.characterStyles.contains(.link) })
		if links.count == 1 {
			XCTAssertEqual(links[0].metadataStrings.first, "https://www.neverendingvoyage.com/")
		} else {
			XCTFail("Incorrect number of links found. Expecting 2, found \(links.count)")
		}
		
	}
	
	func testMalformedLinks() {
		
		challenge = TokenTest(input: "[Link with missing parenthesis](http://voyagetravelapps.com/", output: "[Link with missing parenthesis](http://voyagetravelapps.com/", tokens: [
			Token(type: .string, inputString: "[Link with missing parenthesis](http://voyagetravelapps.com/", characterStyles: [])
		])
		results = self.attempt(challenge)
		XCTAssertEqual(results.stringTokens.count, challenge.tokens.count )
		XCTAssertEqual(results.foundStyles, results.expectedStyles)
		XCTAssertEqual(results.attributedString.string, challenge.output)
		
		challenge = TokenTest(input: "A [Link](http://voyagetravelapps.com/", output: "A [Link](http://voyagetravelapps.com/", tokens: [
			Token(type: .string, inputString: "A [Link](http://voyagetravelapps.com/", characterStyles: [])
		])
		results = self.attempt(challenge)
		if results.stringTokens.count == challenge.tokens.count {
			for (idx, token) in results.stringTokens.enumerated() {
				XCTAssertEqual(token.inputString, challenge.tokens[idx].inputString)
				XCTAssertEqual(token.characterStyles, challenge.tokens[idx].characterStyles)
			}
		} else {
			XCTAssertEqual(results.stringTokens.count, challenge.tokens.count)
		}
		XCTAssertEqual(results.foundStyles, results.expectedStyles)
		XCTAssertEqual(results.attributedString.string, challenge.output)
		
		challenge = TokenTest(input: "[A link](((url)", output: "[A link](((url)", tokens: [
			Token(type: .string, inputString: "[A link](((url)", characterStyles: [])
		])
		results = self.attempt(challenge, rules: [.links])
		if results.stringTokens.count == challenge.tokens.count {
			for (idx, token) in results.stringTokens.enumerated() {
				XCTAssertEqual(token.inputString, challenge.tokens[idx].inputString)
				XCTAssertEqual(token.characterStyles, challenge.tokens[idx].characterStyles)
			}
		} else {
			XCTAssertEqual(results.stringTokens.count, challenge.tokens.count)
		}
		XCTAssertEqual(results.foundStyles, results.expectedStyles)
		XCTAssertEqual(results.attributedString.string, challenge.output)
		XCTAssertEqual(results.links.count, 0)
		
		challenge = TokenTest(input: "[[a](((b)](c)", output: "[a](((b)", tokens: [
			Token(type: .string, inputString: "[a](((b)", characterStyles: [CharacterStyle.link])
		])
		results = self.attempt(challenge, rules: [.links])
		if results.stringTokens.count == challenge.tokens.count {
			for (idx, token) in results.stringTokens.enumerated() {
				XCTAssertEqual(token.inputString, challenge.tokens[idx].inputString)
				XCTAssertEqual(token.characterStyles, challenge.tokens[idx].characterStyles)
			}
		} else {
			XCTAssertEqual(results.stringTokens.count, challenge.tokens.count)
		}
		XCTAssertEqual(results.foundStyles, results.expectedStyles)
		XCTAssertEqual(results.attributedString.string, challenge.output)
		XCTAssertEqual(results.links.count, 1)
		if results.links.count == 1 {
			XCTAssertEqual(results.links[0].metadataStrings.first, "c")
		} else {
			XCTFail("Incorrect link count. Expecting 1, found \(results.links.count)")
		}
		
		
		
		challenge = TokenTest(input: "[Link with missing square(http://voyagetravelapps.com/)", output: "[Link with missing square(http://voyagetravelapps.com/)", tokens: [
			Token(type: .string, inputString: "[Link with missing square(http://voyagetravelapps.com/)", characterStyles: [])
		])
		results = self.attempt(challenge)
		if results.stringTokens.count == challenge.tokens.count {
			for (idx, token) in results.stringTokens.enumerated() {
				XCTAssertEqual(token.inputString, challenge.tokens[idx].inputString)
				XCTAssertEqual(token.characterStyles, challenge.tokens[idx].characterStyles)
			}
		} else {
			XCTAssertEqual(results.stringTokens.count, challenge.tokens.count)
		}
		XCTAssertEqual(results.foundStyles, results.expectedStyles)
		XCTAssertEqual(results.attributedString.string, challenge.output)
		
		challenge = TokenTest(input: "[Link with [second opening](http://voyagetravelapps.com/)", output: "[Link with second opening", tokens: [
			Token(type: .string, inputString: "[Link with ", characterStyles: []),
			Token(type: .string, inputString: "second opening", characterStyles: [CharacterStyle.link])
		])
		results = self.attempt(challenge)
		if results.stringTokens.count == challenge.tokens.count {
			for (idx, token) in results.stringTokens.enumerated() {
				XCTAssertEqual(token.inputString, challenge.tokens[idx].inputString)
				XCTAssertEqual(token.characterStyles, challenge.tokens[idx].characterStyles)
			}
		} else {
			XCTAssertEqual(results.stringTokens.count, challenge.tokens.count)
		}
		XCTAssertEqual(results.foundStyles, results.expectedStyles)
		XCTAssertEqual(results.attributedString.string, challenge.output)
		XCTAssertEqual(results.links.count, 1)
		if results.links.count == 1 {
			XCTAssertEqual(results.links[0].metadataStrings.first, "http://voyagetravelapps.com/")
		} else {
			XCTFail("Incorrect link count. Expecting 1, found \(results.links.count)")
		}
		
		challenge = TokenTest(input: "A [Link(http://voyagetravelapps.com/)", output: "A [Link(http://voyagetravelapps.com/)", tokens: [
			Token(type: .string, inputString: "A [Link(http://voyagetravelapps.com/)", characterStyles: [])
		])
		results = self.attempt(challenge)
		if results.stringTokens.count == challenge.tokens.count {
			for (idx, token) in results.stringTokens.enumerated() {
				XCTAssertEqual(token.inputString, challenge.tokens[idx].inputString)
				XCTAssertEqual(token.characterStyles, challenge.tokens[idx].characterStyles)
			}
		} else {
			XCTAssertEqual(results.stringTokens.count, challenge.tokens.count)
		}
		XCTAssertEqual(results.foundStyles, results.expectedStyles)
		XCTAssertEqual(results.attributedString.string, challenge.output)
		
		
	}
	
	func testMalformedLinksWithValidLinks() {
		
		challenge = TokenTest(input: "[Link with missing parenthesis](http://voyagetravelapps.com/ followed by a [valid link](http://voyagetravelapps.com/)", output: "[Link with missing parenthesis](http://voyagetravelapps.com/ followed by a valid link", tokens: [
			Token(type: .string, inputString: "[Link with missing parenthesis](http://voyagetravelapps.com/ followed by a ", characterStyles: []),
			Token(type: .string, inputString: "valid link", characterStyles: [CharacterStyle.link])
		])
		results = self.attempt(challenge)
		XCTAssertEqual(results.stringTokens.count, challenge.tokens.count )
		XCTAssertEqual(results.foundStyles, results.expectedStyles)
		XCTAssertEqual(results.attributedString.string, challenge.output)
		XCTAssertEqual(results.links.count, 1)
		if results.links.count == 1 {
			XCTAssertEqual(results.links[0].metadataStrings.first, "http://voyagetravelapps.com/")
		} else {
			XCTFail("Incorrect link count. Expecting 1, found \(results.links.count)")
		}
		
		challenge = TokenTest(input: "A [Link](http://voyagetravelapps.com/ followed by a [valid link](http://voyagetravelapps.com/)", output: "A [Link](http://voyagetravelapps.com/ followed by a valid link", tokens: [
			Token(type: .string, inputString: "A [Link](http://voyagetravelapps.com/ followed by a ", characterStyles: []),
			Token(type: .string, inputString: "valid link", characterStyles: [CharacterStyle.link])
		])
		results = self.attempt(challenge)
		if results.stringTokens.count == challenge.tokens.count {
			for (idx, token) in results.stringTokens.enumerated() {
				XCTAssertEqual(token.inputString, challenge.tokens[idx].inputString)
				XCTAssertEqual(token.characterStyles, challenge.tokens[idx].characterStyles)
			}
		} else {
			XCTAssertEqual(results.stringTokens.count, challenge.tokens.count)
		}
		XCTAssertEqual(results.foundStyles, results.expectedStyles)
		XCTAssertEqual(results.attributedString.string, challenge.output)
		XCTAssertEqual(results.links.count, 1)
		if results.links.count == 1 {
			XCTAssertEqual(results.links[0].metadataStrings.first, "http://voyagetravelapps.com/")
		} else {
			XCTFail("Incorrect link count. Expecting 1, found \(results.links.count)")
		}
		
		challenge = TokenTest(input: "[Link with missing square(http://voyagetravelapps.com/) followed by a [valid link](http://voyagetravelapps.com/)", output: "[Link with missing square(http://voyagetravelapps.com/) followed by a valid link", tokens: [
			Token(type: .string, inputString: "[Link with missing square(http://voyagetravelapps.com/) followed by a ", characterStyles: []),
			Token(type: .string, inputString: "valid link", characterStyles: [CharacterStyle.link])
		])
		results = self.attempt(challenge)
		if results.stringTokens.count == challenge.tokens.count {
			for (idx, token) in results.stringTokens.enumerated() {
				XCTAssertEqual(token.inputString, challenge.tokens[idx].inputString)
				XCTAssertEqual(token.characterStyles, challenge.tokens[idx].characterStyles)
			}
		} else {
			XCTAssertEqual(results.stringTokens.count, challenge.tokens.count)
		}
		XCTAssertEqual(results.foundStyles, results.expectedStyles)
		XCTAssertEqual(results.attributedString.string, challenge.output)
		XCTAssertEqual(results.links.count, 1)
		if results.links.count == 1 {
			XCTAssertEqual(results.links[0].metadataStrings.first, "http://voyagetravelapps.com/")
		} else {
			XCTFail("Incorrect link count. Expecting 1, found \(results.links.count)")
		}
		
		challenge = TokenTest(input: "A [Link(http://voyagetravelapps.com/) followed by a [valid link](http://voyagetravelapps.com/)", output: "A [Link(http://voyagetravelapps.com/) followed by a valid link", tokens: [
			Token(type: .string, inputString: "A [Link(http://voyagetravelapps.com/) followed by a ", characterStyles: []),
			Token(type: .string, inputString: "valid link", characterStyles: [CharacterStyle.link])
		])
		results = self.attempt(challenge)
		if results.stringTokens.count == challenge.tokens.count {
			for (idx, token) in results.stringTokens.enumerated() {
				XCTAssertEqual(token.inputString, challenge.tokens[idx].inputString)
				XCTAssertEqual(token.characterStyles, challenge.tokens[idx].characterStyles)
			}
		} else {
			XCTAssertEqual(results.stringTokens.count, challenge.tokens.count)
		}
		XCTAssertEqual(results.foundStyles, results.expectedStyles)
		XCTAssertEqual(results.attributedString.string, challenge.output)
		
		
	}
	
	func testLinksWithOtherStyles() {
		challenge = TokenTest(input: "A **Bold [Link](http://voyagetravelapps.com/)**", output: "A Bold Link", tokens: [
			Token(type: .string, inputString: "A ", characterStyles: []),
			Token(type: .string, inputString: "Bold ", characterStyles: [CharacterStyle.bold]),
			Token(type: .string, inputString: "Link", characterStyles: [CharacterStyle.link, CharacterStyle.bold])
		])
		results = self.attempt(challenge)
		if results.stringTokens.count == challenge.tokens.count {
			for (idx, token) in results.stringTokens.enumerated() {
				XCTAssertEqual(token.inputString, challenge.tokens[idx].inputString)
				XCTAssertEqual(token.characterStyles, challenge.tokens[idx].characterStyles)
			}
		} else {
			XCTAssertEqual(results.stringTokens.count, challenge.tokens.count)
		}
		XCTAssertEqual(results.foundStyles, results.expectedStyles)
		XCTAssertEqual(results.links.count, 1)
		if results.links.count == 1 {
			XCTAssertEqual(results.links[0].metadataStrings.first, "http://voyagetravelapps.com/")
		} else {
			XCTFail("Incorrect link count. Expecting 1, found \(results.links.count)")
		}
		
		challenge = TokenTest(input: "A Bold [**Link**](http://voyagetravelapps.com/)", output: "A Bold Link", tokens: [
			Token(type: .string, inputString: "A Bold ", characterStyles: []),
			Token(type: .string, inputString: "Link", characterStyles: [ CharacterStyle.link, CharacterStyle.bold])
		])
		results = self.attempt(challenge)
		if results.stringTokens.count == challenge.tokens.count {
			for (idx, token) in results.stringTokens.enumerated() {
				XCTAssertEqual(token.inputString, challenge.tokens[idx].inputString)
				XCTAssertEqual(token.characterStyles, challenge.tokens[idx].characterStyles)
			}
		} else {
			XCTAssertEqual(results.stringTokens.count, challenge.tokens.count)
		}
		XCTAssertEqual(results.foundStyles, results.expectedStyles)
		XCTAssertEqual(results.attributedString.string, challenge.output)
		XCTAssertEqual(results.links.count, 1)
		if results.links.count == 1 {
			XCTAssertEqual(results.links[0].metadataStrings.first, "http://voyagetravelapps.com/")
		} else {
			XCTFail("Incorrect link count. Expecting 1, found \(results.links.count)")
		}
		
		challenge = TokenTest(input: "[Link1](http://voyagetravelapps.com/) **bold** [Link2](http://voyagetravelapps.com/)", output: "Link1 bold Link2",  tokens: [
			Token(type: .string, inputString: "Link1", characterStyles: [CharacterStyle.link]),
			Token(type: .string, inputString: " ", characterStyles: []),
			Token(type: .string, inputString: "bold", characterStyles: [CharacterStyle.bold]),
			Token(type: .string, inputString: " ", characterStyles: []),
			Token(type: .string, inputString: "Link2", characterStyles: [CharacterStyle.link])
		])
		results = self.attempt(challenge)
		if results.stringTokens.count == challenge.tokens.count {
			for (idx, token) in results.stringTokens.enumerated() {
				XCTAssertEqual(token.inputString, challenge.tokens[idx].inputString)
				XCTAssertEqual(token.characterStyles, challenge.tokens[idx].characterStyles)
			}
		} else {
			XCTAssertEqual(results.stringTokens.count, challenge.tokens.count)
		}
		XCTAssertEqual(results.foundStyles, results.expectedStyles)
		XCTAssertEqual(results.attributedString.string, challenge.output)
	}
}
