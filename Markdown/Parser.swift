import UIKit

public enum CharacterStyle: Equatable {
	case none
	case bold
	case italic
	case strikethrough
	case code
	case link
}

public enum FontStyle: Int {
	case normal
	case bold
	case italic
	case boldItalic
}

public protocol FontProperties {
	var fontName: String? { get set }
	var color: UIColor { get set }
	var fontSize: CGFloat { get set }
	var fontStyle: FontStyle { get set }
}

public protocol LineProperties {
	var alignment: NSTextAlignment { get set }
    var lineSpacing: CGFloat { get set }
    var paragraphSpacing: CGFloat { get set }
}


/**
A class defining the styles that can be applied to the parsed Markdown. The `fontName` property is optional, and if it's not set then the `fontName` property of the Body style will be applied.

If that is not set, then the system default will be used.
*/
public class BasicStyles: FontProperties {
	public var fontName: String?
	public var color = UIColor.black
	public var fontSize: CGFloat = 0.0
	public var fontStyle: FontStyle = .normal
}

public class LineStyles: FontProperties, LineProperties {
	public var fontName: String?
	public var color = UIColor.black
	public var fontSize: CGFloat = 0.0
	public var fontStyle: FontStyle = .normal
	public var alignment: NSTextAlignment = .left
    public var lineSpacing: CGFloat = 0.0
    public var paragraphSpacing: CGFloat = 0.0
}

public class LinkStyles: BasicStyles {
    public var underlineStyle: NSUnderlineStyle = .single
	public lazy var underlineColor = color
}

final class Parser {

	static public var characterRules = [
		CharacterRule(
			primaryTag: CharacterRuleTag(tag: "[", type: .open),
			otherTags: [
				CharacterRuleTag(tag: "]", type: .close),
				CharacterRuleTag(tag: "(", type: .metadataOpen),
				CharacterRuleTag(tag: ")", type: .metadataClose)
			],
			styles: [1: CharacterStyle.link],
			definesBoundary: true
		),
		CharacterRule(
			primaryTag: CharacterRuleTag(tag: "`", type: .repeating),
			styles: [1: .code],
			shouldCancelRemainingRules: true,
			balancedTags: true
		),
		CharacterRule(
			primaryTag:CharacterRuleTag(tag: "~", type: .repeating),
			styles: [2: .strikethrough],
			minTags:2, maxTags:2
		),
		CharacterRule(
			primaryTag: CharacterRuleTag(tag: "*", type: .repeating),
			styles: [1: .italic, 2: .bold],
			minTags:1,
			maxTags:2
		),
		CharacterRule(
			primaryTag: CharacterRuleTag(tag: "_", type: .repeating),
			styles: [1: .italic, 2: .bold],
			minTags:1 ,
			maxTags:2
		)
	]
	
	let tokeniser = Tokeniser(rules: Parser.characterRules)
	
	/// The default body styles. These are the base styles and will be used for e.g. headers if no other styles override them.
	public var body = LineStyles()
	
	/// The styles to apply to any blockquotes found in the Markdown
	public var blockquotes = LineStyles()
	
	/// The styles to apply to any links found in the Markdown
	public var link = LinkStyles()
	
	/// The styles to apply to any bold text found in the Markdown
	public var bold = BasicStyles()
	
	/// The styles to apply to any italic text found in the Markdown
	public var italic = BasicStyles()
	
	/// The styles to apply to any code blocks or inline code text found in the Markdown
	public var code = BasicStyles()
	
	public var strikethrough = BasicStyles()
	
	public var bullet: String = "・"
	
	public var underlineLinks: Bool = false

	var orderedListCount = 0
	var orderedListIndentFirstOrderCount = 0
	var orderedListIndentSecondOrderCount = 0

	var applyAttachments = true

	public func attributedString(_ string: String) -> NSAttributedString {
		return attributedString(tokens: tokeniser.process(string))
	}
}

extension Parser {
	
	func attributedString(tokens: [Token]) -> NSAttributedString {
		let finalAttributedString = NSMutableAttributedString()
		var attributes: [NSAttributedString.Key: AnyObject] = [:]

		orderedListCount = 0
		orderedListIndentFirstOrderCount = 0
		orderedListIndentSecondOrderCount = 0

		let lineProperties: LineProperties = body
		
        let paragraphStyle = attributes[.paragraphStyle] as? NSMutableParagraphStyle ?? NSMutableParagraphStyle()
		if lineProperties.alignment != .left {
			paragraphStyle.alignment = lineProperties.alignment
		}
        paragraphStyle.lineSpacing = lineProperties.lineSpacing
        paragraphStyle.paragraphSpacing = lineProperties.paragraphSpacing
        attributes[.paragraphStyle] = paragraphStyle

		for token in tokens {
			attributes[.font] = font(characterStyle: nil)
			attributes[.link] = nil
			attributes[.strikethroughStyle] = nil
			attributes[.foregroundColor] = body.color
            attributes[.underlineStyle] = nil

			let styles = token.characterStyles

			if styles.contains(.italic) {
				attributes[.font] = font(characterStyle: .italic)
				attributes[.foregroundColor] = italic.color
			}
			if styles.contains(.bold) {
				attributes[.font] = font(characterStyle: .bold)
				attributes[.foregroundColor] = bold.color
			}
			
            if let linkIdx = styles.firstIndex(of: .link), linkIdx < token.metadataStrings.count {
                attributes[.foregroundColor] = link.color
				attributes[.font] = font(characterStyle: .link)
                attributes[.link] = token.metadataStrings[linkIdx] as AnyObject
                
                if underlineLinks {
                    attributes[.underlineStyle] = link.underlineStyle.rawValue as AnyObject
                    attributes[.underlineColor] = link.underlineColor
                }
            }
						
			if styles.contains(.strikethrough) {
				attributes[.font] = font(characterStyle: .strikethrough)
				attributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue as AnyObject
				attributes[.foregroundColor] = strikethrough.color
			}

			if styles.contains(.code) {
				attributes[.foregroundColor] = code.color
				attributes[.font] = font(characterStyle: .code)
			} else {
				// Switch back to previous font
			}
			let str = NSAttributedString(string: token.outputString, attributes: attributes)
			finalAttributedString.append(str)
		}
	
		return finalAttributedString
	}
}
