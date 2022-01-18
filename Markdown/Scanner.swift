import Foundation

enum RepeatingTagType {
	case open
	case either
	case close
	case neither
}

struct TagGroup {
	let groupID  = UUID().uuidString
	var tagRanges: [ClosedRange<Int>]
	var tagType: RepeatingTagType = .open
	var count = 1
}

final class Scanner {
	var elements: [Element]
	let rule: CharacterRule

	var pointer: Int = 0
	
	var spaceAndNewLine = CharacterSet.whitespacesAndNewlines
	var tagGroups: [TagGroup] = []
	
	var isMetadataOpen = false
	var metadata: [String: String] = [:]
	
	enum Position {
		case forward(Int)
		case backward(Int)
	}
	
	init(elements: [Element], rule: CharacterRule) {
		self.elements = elements
		self.rule = rule
	}
	
	func elementsBetweenCurrentPosition(and newPosition: Position) -> [Element]? {
		let newIdx: Int
		var isForward = true
		switch newPosition {
		case .backward(let positions):
			isForward = false
			newIdx = pointer - positions
			if newIdx < 0 {
				return nil
			}
		case .forward(let positions):
			newIdx = pointer + positions
			if newIdx >= elements.count {
				return nil
			}
		}
		
		
		let range: ClosedRange<Int> = isForward ? pointer...newIdx : newIdx...pointer
		return Array(elements[range])
	}

	func element( for position: Position ) -> Element? {
		let newIdx: Int
		switch position {
		case .backward(let positions):
			newIdx = pointer - positions
			if newIdx < 0 {
				return nil
			}
		case .forward(let positions):
			newIdx = pointer + positions
			if newIdx >= elements.count {
				return nil
			}
		}
		return elements[newIdx]
	}

	func positionIsEqualTo( character: Character, direction: Position ) -> Bool {
		guard let validElement = element(for: direction) else {
			return false
		}
		return validElement.character == character
	}

	func positionContains( characters: [Character], direction: Position ) -> Bool {
		guard let validElement = element(for: direction) else {
			return false
		}
		return characters.contains(validElement.character)
	}
	
	func isEscaped() -> Bool {
		let isEscaped = positionContains(characters: rule.escapeCharacters, direction: .backward(1))
		if isEscaped {
			elements[pointer - 1].type = .escape
		}
		return isEscaped
	}
	
	func range( for tag: String? ) -> ClosedRange<Int>? {

		guard let tag = tag else {
			return nil
		}
		
		guard let openChar = tag.first else {
			return nil
		}
		
		if pointer == elements.count {
			return nil
		}
		
		if elements[pointer].character != openChar {
			return nil
		}
		
		if isEscaped() {
			return nil
		}
		
		let range: ClosedRange<Int>
		if tag.count > 1 {
			guard let elements = elementsBetweenCurrentPosition(and: .forward(tag.count - 1)) else {
				return nil
			}
			// If it's already a tag, then it should be ignored
			if elements.filter({ $0.type != .string }).count > 0 {
				return nil
			}
			if elements.map( { String($0.character) }).joined() != tag {
				return nil
			}
			let endIdx = (pointer + tag.count - 1)
			for i in pointer...endIdx {
				self.elements[i].type = .tag
			}
			range = pointer...endIdx
			pointer += tag.count
		} else {
			// If it's already a tag, then it should be ignored
			if elements[pointer].type != .string {
				return nil
			}
			elements[pointer].type = .tag
			range = pointer...pointer
			pointer += 1
		}
		return range
	}
	
	
	func resetTagGroup( withID id: String ) {
		if let idx = tagGroups.firstIndex(where: { $0.groupID == id }) {
			for range in tagGroups[idx].tagRanges {
				resetTag(in: range)
			}
			tagGroups.remove(at: idx)
		}
		isMetadataOpen = false
	}
	
	func resetTag( in range: ClosedRange<Int>) {
		for idx in range {
			elements[idx].type = .string
		}
	}
	
	func resetLastTag( for range: inout [ClosedRange<Int>]) {
		guard let last = range.last else {
			return
		}
		for idx in last {
			elements[idx].type = .string
		}
	}
	
	func closeTag( _ tag: String, withGroupID id: String ) {

		guard let tagIdx = tagGroups.firstIndex(where: { $0.groupID == id }) else {
			return
		}

		var metadataString = ""
		if isMetadataOpen {
			let metadataCloseRange = tagGroups[tagIdx].tagRanges.removeLast()
			let metadataOpenRange = tagGroups[tagIdx].tagRanges.removeLast()

			if metadataOpenRange.upperBound + 1 != metadataCloseRange.lowerBound {
				for idx in (metadataOpenRange.upperBound)...(metadataCloseRange.lowerBound) {
					elements[idx].type = .metadata
					if rule.definesBoundary {
						elements[idx].boundaryCount += 1
					}
				}

				let key = elements[metadataOpenRange.upperBound + 1..<metadataCloseRange.lowerBound].map( { String( $0.character )}).joined()
				metadataString = key
			}
		}

		let closeRange = tagGroups[tagIdx].tagRanges.removeLast()
		let openRange = tagGroups[tagIdx].tagRanges.removeLast()

		if rule.balancedTags && closeRange.count != openRange.count {
			tagGroups[tagIdx].tagRanges.append(openRange)
			tagGroups[tagIdx].tagRanges.append(closeRange)
			return
		}

		var shouldRemove = true
		var styles: [CharacterStyle] = []
		if openRange.upperBound + 1 != closeRange.lowerBound {
			var remainingTags = min(openRange.upperBound - openRange.lowerBound, closeRange.upperBound - closeRange.lowerBound) + 1
			while remainingTags > 0 {
				if remainingTags >= rule.maxTags {
					remainingTags -= rule.maxTags
					if let style = rule.styles[ rule.maxTags ] {
						if !styles.contains(style) {
							styles.append(style)
						}
					}
				}
				if let style = rule.styles[remainingTags] {
					remainingTags -= remainingTags
					if !styles.contains(style) {
						styles.append(style)
					}
				}
			}
			
			for idx in (openRange.upperBound)...(closeRange.lowerBound) {
				elements[idx].styles.append(contentsOf: styles)
				elements[idx].metadata.append(metadataString)
				if rule.definesBoundary {
					elements[idx].boundaryCount += 1
				}
				if rule.shouldCancelRemainingRules {
					elements[idx].boundaryCount = 1000
				}
			}
			
			if rule.isRepeatingTag {
				let difference = ( openRange.upperBound - openRange.lowerBound ) - (closeRange.upperBound - closeRange.lowerBound)
				switch difference {
				case 1...:
					shouldRemove = false
					tagGroups[tagIdx].count = difference
					tagGroups[tagIdx].tagRanges.append( openRange.upperBound - (abs(difference) - 1)...openRange.upperBound )
				case ...(-1):
					for idx in closeRange.upperBound - (abs(difference) - 1)...closeRange.upperBound {
						elements[idx].type = .string
					}
				default:
					break
				}
			}
			
		}
		if shouldRemove {
			tagGroups.removeAll(where: { $0.groupID == id })
		}
		isMetadataOpen = false
	}
	
	func emptyRanges( _ ranges: inout [ClosedRange<Int>] ) {
		while !ranges.isEmpty {
			resetLastTag(for: &ranges)
			ranges.removeLast()
		}
	}
	
	func scanNonRepeatingTags() {
		var groupID = ""
		let closeTag = rule.tag(for: .close)?.tag
		let metadataOpen = rule.tag(for: .metadataOpen)?.tag
		let metadataClose = rule.tag(for: .metadataClose)?.tag
		
		while pointer < elements.count {

			if let range = range(for: metadataClose) {
				if isMetadataOpen {
					guard let groupIdx = tagGroups.firstIndex(where: { $0.groupID == groupID }) else {
						pointer += 1
						continue
					}
					
					guard !tagGroups.isEmpty else {
						resetTagGroup(withID: groupID)
						continue
					}
				
					guard isMetadataOpen else {
						
						resetTagGroup(withID: groupID)
						continue
					}
					tagGroups[groupIdx].tagRanges.append(range)
					self.closeTag(closeTag!, withGroupID: groupID)
					isMetadataOpen = false
					continue
				} else {
					resetTag(in: range)
					pointer -= metadataClose!.count
				}

			}
			
			if let openRange = range(for: rule.primaryTag.tag) {
				if isMetadataOpen {
					resetTagGroup(withID: groupID)
				}
				
				let tagGroup = TagGroup(tagRanges: [openRange])
				groupID = tagGroup.groupID
				if rule.isRepeatingTag {
					
				}
				
				tagGroups.append(tagGroup)
				continue
			}
	
			if let range = range(for: closeTag) {
				guard !tagGroups.isEmpty else {
					resetTag(in: range)
					continue
				}
				tagGroups[tagGroups.count - 1].tagRanges.append(range)
				groupID = tagGroups[tagGroups.count - 1].groupID
				guard metadataOpen != nil else {
					self.closeTag(closeTag!, withGroupID: groupID)
					continue
				}
				
				guard pointer != elements.count else {
					continue
				}
				
				guard let range = self.range(for: metadataOpen) else {
					resetTagGroup(withID: groupID)
					continue
				}
				tagGroups[tagGroups.count - 1].tagRanges.append(range)
				isMetadataOpen = true
				continue
			}
			

			if let range = range(for: metadataOpen) {
				resetTag(in: range)
				resetTagGroup(withID: groupID)
				isMetadataOpen = false
				continue
			}
			pointer += 1
		}
	}
	
	func scanRepeatingTags() {
				
		var groupID = ""
		let escapeCharacters = "" //rule.escapeCharacters.map( { String( $0 ) }).joined()
		let unionSet = spaceAndNewLine.union(CharacterSet(charactersIn: escapeCharacters))
		while pointer < elements.count {

			if var openRange = range(for: rule.primaryTag.tag) {
				
				if elements[openRange].first?.boundaryCount == 1000 {
					resetTag(in: openRange)
					continue
				}
				
				var count = 1
				var tagType: RepeatingTagType = .open
				if let prevElement = element(for: .backward(rule.primaryTag.tag.count + 1))  {
					if !unionSet.containsUnicodeScalars(of: prevElement.character) {
						tagType = .either
					}
				} else {
					tagType = .open
				}
				
				while let nextRange = range(for: rule.primaryTag.tag)  {
					count += 1
					openRange = openRange.lowerBound...nextRange.upperBound
				}
				
				if rule.minTags > 1 {
					if (openRange.upperBound - openRange.lowerBound) + 1 < rule.minTags {
						resetTag(in: openRange)
						continue
					}
				}
				
				var validTagGroup = true
				if let nextElement = element(for: .forward(0)) {
					if unionSet.containsUnicodeScalars(of: nextElement.character) {
						if tagType == .either {
							tagType = .close
						} else {
							validTagGroup = tagType != .open
						}
					}
				} else {
					if tagType == .either {
						tagType = .close
					} else {
						validTagGroup = tagType != .open
					}
				}
				
				if !validTagGroup {
					resetTag(in: openRange)
					continue
				}
				
				if let idx = tagGroups.firstIndex(where: { $0.groupID == groupID }) {
					if tagType == .either {
						if tagGroups[idx].count == count {
							tagGroups[idx].tagRanges.append(openRange)
							closeTag(rule.primaryTag.tag, withGroupID: groupID)
							
							if let last = tagGroups.last {
								groupID = last.groupID
							}
							
							continue
						}
					} else {
						if let prevRange = tagGroups[idx].tagRanges.first {
							if elements[prevRange].first?.boundaryCount == elements[openRange].first?.boundaryCount {
								tagGroups[idx].tagRanges.append(openRange)
								closeTag(rule.primaryTag.tag, withGroupID: groupID)
							}
						}
						continue
					}
				}
				var tagGroup = TagGroup(tagRanges: [openRange])
				groupID = tagGroup.groupID
				tagGroup.tagType = tagType
				tagGroup.count = count
				
				tagGroups.append(tagGroup)
				continue
			}
	
			pointer += 1
		}
	}
	
	func scan() -> [Element] {
		
		guard elements.filter({ $0.type == .string }).map({ String($0.character) }).joined().contains(rule.primaryTag.tag) else {
			return elements
		}

		if rule.isRepeatingTag {
			scanRepeatingTags()
		} else {
			scanNonRepeatingTags()
		}
		
		for tagGroup in tagGroups {
			resetTagGroup(withID: tagGroup.groupID)
		}
		
		return elements
	}
}
