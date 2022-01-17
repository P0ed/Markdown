# Markdown

Markdown converts markdown string into `NSAttributedString`.

## Installation

### SPM: 

In Xcode, `File -> Swift Packages -> Add Package Dependency` and add the GitHub URL. 

## How To Use Markdown

Read Markdown from a text string...

```swift
let md = Markdown()
md.attributedString("Heading\nMy *Markdown* string")
```

## Supported Markdown Features
    *italics* or _italics_
    **bold** or __bold__
    ~~Linethrough~~Strikethroughs. 
    `code`

    [Links](http://voyagetravelapps.com/)
		
Compound rules also work, for example:
		
	It recognises **[Bold Links](http://voyagetravelapps.com/)**
	
	Or [**Bold Links**](http://voyagetravelapps.com/)

On iOS, Specified font sizes will be adjusted relative to the the user's dynamic type settings.

### Advanced Customisation

Markdown uses a rules-based line processing and customisation engine that is no longer limited to Markdown. Rules are processed in order, from top to bottom. Character styles are applied based on the character rules.

For example, here's how a small subset of Markdown line tags are set up within Markdown:

The character styles all follow rules:

```swift
enum CharacterStyle: CharacterStyling {
	case link, bold, italic, code
}

static public var characterRules = [
    CharacterRule(primaryTag: CharacterRuleTag(tag: "[", type: .open), otherTags: [
			CharacterRuleTag(tag: "]", type: .close),
			CharacterRuleTag(tag: "[", type: .metadataOpen),
			CharacterRuleTag(tag: "]", type: .metadataClose)
	], styles: [1: CharacterStyle.link], metadataLookup: true, definesBoundary: true),
	CharacterRule(primaryTag: CharacterRuleTag(tag: "`", type: .repeating), otherTags: [], styles: [1: CharacterStyle.code], shouldCancelRemainingTags: true, balancedTags: true),
	CharacterRule(primaryTag: CharacterRuleTag(tag: "*", type: .repeating), otherTags: [], styles: [1: CharacterStyle.italic, 2: CharacterStyle.bold], minTags:1 , maxTags:2),
	CharacterRule(primaryTag: CharacterRuleTag(tag: "_", type: .repeating), otherTags: [], styles: [1: CharacterStyle.italic, 2: CharacterStyle.bold], minTags:1 , maxTags:2)
]
```

These Character Rules are defined by Markdown:

	public struct CharacterRule: CustomStringConvertible {

		public let primaryTag: CharacterRuleTag
		public let tags: [CharacterRuleTag]
		public let escapeCharacters: [Character]
		public let styles: [Int: CharacterStyling]
		public let minTags: Int
		public let maxTags: Int
		public var metadataLookup: Bool = false
		public var definesBoundary = false
		public var shouldCancelRemainingRules = false
		public var balancedTags = false
	}

1. `primaryTag`: Each rule must have at least one tag and it can be one of `repeating`, `open`, `close`, `metadataOpen`, or `metadataClose`. `repeating` tags are tags that have identical open and close characters (and often have more than 1 style depending on how many are in a group). For example, the `*` tag used in Markdown.
2. `tags`: An array of other tags that the rule can look for. This is where you would put the `close` tag for a custom rule, for example.
3. `escapeCharacters`: The characters that appear prior to any of the tag characters that tell the scanner to ignore the tag. 
4. `styles`: The styles that should be applied to every character between the opening and closing tags. 
5. `minTags`: The minimum number of repeating characters to be considered a successful match. For example, setting the `primaryTag` to `*` and the `minTag` to 2 would mean that `**foo**` would be a successful match wheras `*bar*` would not.
6. `maxTags`: The maximum number of repeating characters to be considered a successful match. 
7. `metadataLookup`: Used for Markdown reference links. Tells the scanner to try to look up the metadata from this dictionary, rather than from the inline result. 
8. `definesBoundary`: In order for open and close tags to be successful, the `boundaryCount` for a given location in the string needs to be the same. Setting this property to `true` means that this rule will increase the `boundaryCount` for every character between its opening and closing tags. For example, the `[` rule defines a boundary. After it is applied, the string `*foo[bar*]` becomes `*foobar*` with a boundaryCount `00001111`. Applying the `*` rule results in the output `*foobar*` because the opening `*` tag and the closing `*` tag now have different `boundaryCount` values. It's basically a way to fix the `**[should not be bold**](url)` problem in Markdown. 
9. `shouldCancelRemainingTags`: A successful match will mark every character between the opening and closing tags as complete, thereby preventing any further rules from being applied to those characters.
10. `balancedTags`: This flag requires that the opening and closing tags be of exactly equal length. E.g. If this is set to true,  `**foo*` would result in `**foo*`. If it was false, the output would be `*foo`.



#### Rule Subsets

If you want to only support a small subset of Markdown, it's now easy to do. 

This example would only process strings with `*` and `_` characters, ignoring links, images, code, and all line-level attributes (headings, blockquotes, etc.)
```swift
Markdown.lineRules = []

Markdown.characterRules = [
	CharacterRule(primaryTag: CharacterRuleTag(tag: "*", type: .repeating), otherTags: [], styles: [1: CharacterStyle.italic, 2: CharacterStyle.bold], minTags:1 , maxTags:2),
	CharacterRule(primaryTag: CharacterRuleTag(tag: "_", type: .repeating), otherTags: [], styles: [1: CharacterStyle.italic, 2: CharacterStyle.bold], minTags:1 , maxTags:2)
]
```
