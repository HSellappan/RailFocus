//
//  Collection+Extensions.swift
//  RailFocus
//
//  Collection and Array extensions
//

import Foundation

extension Collection {
    /// Safe subscript that returns nil if index is out of bounds
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }

    /// Returns true if collection is not empty
    var isNotEmpty: Bool {
        !isEmpty
    }
}

extension Array {
    /// Split array into chunks of specified size
    func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return [] }
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }

    /// Remove duplicates while preserving order
    func uniqued<T: Hashable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        var seen = Set<T>()
        return filter { element in
            let key = element[keyPath: keyPath]
            if seen.contains(key) {
                return false
            }
            seen.insert(key)
            return true
        }
    }
}

extension Array where Element: Identifiable {
    /// Find element by ID
    func find(id: Element.ID) -> Element? {
        first { $0.id == id }
    }

    /// Find index of element by ID
    func findIndex(id: Element.ID) -> Int? {
        firstIndex { $0.id == id }
    }

    /// Remove element by ID
    mutating func remove(id: Element.ID) {
        removeAll { $0.id == id }
    }

    /// Update element by ID
    mutating func update(_ element: Element) {
        if let index = findIndex(id: element.id) {
            self[index] = element
        }
    }
}

extension Sequence {
    /// Group elements by a key
    func grouped<Key: Hashable>(by keyPath: KeyPath<Element, Key>) -> [Key: [Element]] {
        Dictionary(grouping: self) { $0[keyPath: keyPath] }
    }

    /// Sort by key path
    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>, ascending: Bool = true) -> [Element] {
        sorted { a, b in
            let aVal = a[keyPath: keyPath]
            let bVal = b[keyPath: keyPath]
            return ascending ? aVal < bVal : aVal > bVal
        }
    }
}

// MARK: - Optional Extensions

extension Optional {
    /// Returns true if the optional is nil
    var isNil: Bool {
        self == nil
    }

    /// Returns true if the optional has a value
    var hasValue: Bool {
        self != nil
    }

    /// Unwrap or throw an error
    func unwrap(or error: Error) throws -> Wrapped {
        guard let value = self else {
            throw error
        }
        return value
    }
}

extension Optional where Wrapped: Collection {
    /// Returns true if nil or empty
    var isNilOrEmpty: Bool {
        self?.isEmpty ?? true
    }

    /// Returns true if has value and not empty
    var isNotEmpty: Bool {
        self?.isNotEmpty ?? false
    }
}
