import Foundation

public enum TokenType {
	case repeatingTag
	case openTag
	case intermediateTag
	case closeTag
	case string
	case escape
	case replacement
}

public struct Token {
	public let id = UUID().uuidString
	public let type: TokenType
	public let inputString: String
	public var metadataStrings: [String] = []
	public internal(set) var group: Int = 0
	public internal(set) var characterStyles: [CharacterStyle] = []
	public internal(set) var count: Int = 0
	public internal(set) var shouldSkip: Bool = false
	public internal(set) var tokenIndex: Int = -1
	public internal(set) var isProcessed: Bool = false
	public var children: [Token] = []
	
	public var outputString: String {
		get {
			switch type {
			case .repeatingTag:
				if count <= 0 {
					return ""
				} else {
					let range = inputString.startIndex..<inputString.index(inputString.startIndex, offsetBy: count)
					return String(inputString[range])
				}
			case .openTag, .closeTag, .intermediateTag:
				return isProcessed ? "" : inputString
			case .escape, .string:
				return isProcessed ? "" : inputString
			case .replacement:
				return inputString
			}
		}
	}

	public init(type: TokenType, inputString: String, characterStyles: [CharacterStyle] = []) {
		self.type = type
		self.inputString = inputString
		self.characterStyles = characterStyles
		if type == .repeatingTag {
			self.count = inputString.count
		}
	}
}
