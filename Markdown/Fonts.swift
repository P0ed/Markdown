import Foundation
import UIKit

extension Parser {
	
	func font(characterStyle: CharacterStyle? = nil) -> UIFont {
		let style = body
		let textStyle = UIFont.TextStyle.body
		var fontName: String?
		var fontSize: CGFloat?
		
		var globalBold = false
		var globalItalic = false

		fontName = style.fontName
		fontSize = style.fontSize
		switch style.fontStyle {
		case .bold:
			globalBold = true
		case .italic:
			globalItalic = true
		case .boldItalic:
			globalItalic = true
			globalBold = true
		case .normal:
			break
		}

		if fontName == nil {
			fontName = body.fontName
		}
		
		if let characterStyle = characterStyle {
			switch characterStyle {
			case .code:
				fontName = code.fontName ?? fontName
				fontSize = code.fontSize
			case .link:
				fontName = link.fontName ?? fontName
				fontSize = link.fontSize
			case .bold:
				fontName = bold.fontName ?? fontName
				fontSize = bold.fontSize
				globalBold = true
			case .italic:
				fontName = italic.fontName ?? fontName
				fontSize = italic.fontSize
				globalItalic = true
			case .strikethrough:
				fontName = strikethrough.fontName ?? fontName
				fontSize = strikethrough.fontSize
			default:
				break
			}
		}
		
		fontSize = fontSize == 0.0 ? nil : fontSize
		var font: UIFont
		if let existentFontName = fontName {
			font = UIFont.preferredFont(forTextStyle: textStyle)
			let finalSize: CGFloat
			if let existentFontSize = fontSize {
				finalSize = existentFontSize
			} else {
				let styleDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: textStyle)
				finalSize = styleDescriptor.fontAttributes[.size] as? CGFloat ?? CGFloat(14)
			}
			
			if let customFont = UIFont(name: existentFontName, size: finalSize)  {
				let fontMetrics = UIFontMetrics(forTextStyle: textStyle)
				font = fontMetrics.scaledFont(for: customFont)
			} else {
				font = UIFont.preferredFont(forTextStyle: textStyle)
			}
		} else {
			font = UIFont.preferredFont(forTextStyle: textStyle)
		}
		
		if globalItalic, let italicDescriptor = font.fontDescriptor.withSymbolicTraits(.traitItalic) {
			font = UIFont(descriptor: italicDescriptor, size: fontSize ?? 0)
		}
		if globalBold, let boldDescriptor = font.fontDescriptor.withSymbolicTraits(.traitBold) {
			font = UIFont(descriptor: boldDescriptor, size: fontSize ?? 0)
		}
		
		return font
	}
}
