import Foundation

@available(iOS 18.1, *)
struct IngredientGroupMatcher {
    
    /// Cleans a string by removing punctuation and keeping only alphanumeric words.
    private static func clean(_ str: String) -> String {
        return str.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
    
    /// Groups a list of parsed JSON-LD ingredients based on headers found in the raw webpage text.
    static func group(ingredients: [String], from rawText: String) -> [ArticleIngredientGroup] {
        guard !ingredients.isEmpty else { return [] }
        
        let cleanedIngredients = ingredients.map { clean($0) }
        
        let lines = rawText.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        var currentGroupName = ""
        var groupDict: [String: [String]] = [:]
        var orderedGroupNames: [String] = []
        var matchedIndices = Set<Int>()
        
        for line in lines {
            // Ignore long paragraphs to prevent matching ingredients mentioned in the story
            guard line.count < 300 else { continue }
            
            let cleanLine = clean(line)
            guard !cleanLine.isEmpty else { continue }
            
            // Try to match this line with an unmatched JSON-LD ingredient using Word Overlap
            var matchedIdx: Int? = nil
            var bestScore = 0.0
            
            for (idx, cleanIng) in cleanedIngredients.enumerated() {
                if !matchedIndices.contains(idx) {
                    let lineWords = Set(cleanLine.components(separatedBy: " "))
                    let ingWords = Set(cleanIng.components(separatedBy: " "))
                    
                    let intersection = lineWords.intersection(ingWords)
                    
                    // Ratio of ingredient words found in the line
                    let overlapIng = Double(intersection.count) / Double(max(1, ingWords.count))
                    // Ratio of line words that belong to the ingredient
                    let overlapLine = Double(intersection.count) / Double(max(1, lineWords.count))
                    
                    // High confidence match
                    if overlapIng >= 0.8 && overlapLine >= 0.4 {
                        let combinedScore = overlapIng * overlapLine
                        if combinedScore > bestScore {
                            bestScore = combinedScore
                            matchedIdx = idx
                        }
                    }
                }
            }
            
            if let idx = matchedIdx {
                // Found an ingredient
                if !orderedGroupNames.contains(currentGroupName) {
                    orderedGroupNames.append(currentGroupName)
                }
                groupDict[currentGroupName, default: []].append(ingredients[idx])
                matchedIndices.insert(idx)
            } else {
                // Not an ingredient. Is it a group header?
                if line.count >= 3 && line.count <= 40 {
                    let headerCandidate = line
                        .replacingOccurrences(of: "•", with: "")
                        .replacingOccurrences(of: "*", with: "")
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    // Headers rarely start with numbers (unlike ingredients like "2 tbsp")
                    if let first = headerCandidate.first, !first.isNumber {
                        currentGroupName = headerCandidate
                    }
                }
            }
        }
        
        // Put any unmatched ingredients into the last active group
        let unmatchedIndices = Set(0..<ingredients.count).subtracting(matchedIndices)
        if !unmatchedIndices.isEmpty {
            let defaultGroupName = orderedGroupNames.last ?? ""
            if !orderedGroupNames.contains(defaultGroupName) {
                orderedGroupNames.append(defaultGroupName)
            }
            for idx in unmatchedIndices.sorted() {
                groupDict[defaultGroupName, default: []].append(ingredients[idx])
            }
        }
        
        // Filter out bad group names
        var finalGroups: [ArticleIngredientGroup] = []
        let exactBadKeywords = ["bahan-bahan", "ingredients", "bahan", "bumbu", "cara membuat", "instructions"]
        let containsBadKeywords = ["porsi", "jam", "menit", "servings", "hours", "minutes", "orang"]
        
        for name in orderedGroupNames {
            if let items = groupDict[name] {
                let lowerName = name.lowercased()
                let isBadName = exactBadKeywords.contains(lowerName) || containsBadKeywords.contains(where: { lowerName.contains($0) })
                let finalName = isBadName ? "" : name
                finalGroups.append(ArticleIngredientGroup(groupName: finalName, ingredients: items))
            }
        }
        
        var mergedGroups: [String: [String]] = [:]
        var mergedOrderedNames: [String] = []
        
        for group in finalGroups {
            if !mergedOrderedNames.contains(group.groupName) {
                mergedOrderedNames.append(group.groupName)
            }
            mergedGroups[group.groupName, default: []].append(contentsOf: group.ingredients)
        }
        
        if mergedOrderedNames.count == 1 {
            let onlyGroup = mergedOrderedNames[0]
            return [ArticleIngredientGroup(groupName: "", ingredients: mergedGroups[onlyGroup]!)]
        }
        
        return mergedOrderedNames.map { ArticleIngredientGroup(groupName: $0, ingredients: mergedGroups[$0]!) }
    }
}
