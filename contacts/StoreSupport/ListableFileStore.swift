//
//  ListableFileStore.swift
//
//  Template created by Pete Maiser, July 2024 through July 2025
//      © Fast Five Products LLC, 2025
//      https://github.com/fastfiveproducts/template.ios
//      made available, and used here, per terms of the MIT License
//      changes should be rare; it is recommended changes are applied to the template
//      and the entire file compared-and-then-replaced here if/as appropriate
//
//      Template v0.1.2
//


import Foundation

@MainActor
class ListableFileStore<T: Listable>: ListableStore {
    
    @Published var list: Loadable<[T]> = .none
    
    private let filename: String
    private let fileManager = FileManager.default
    
    init(filename: String = "\(T.typeDescription).json") {
        self.filename = filename
    }

    // MARK: - Load previously-Saved items
    func load() {
        Task {
            list = .loading
            do {
                let url = fileURL()
                guard fileManager.fileExists(atPath: url.path) else {
                    list = .loaded([])
                    return
                }
                let data = try Data(contentsOf: url)
                let decoded = try JSONDecoder().decode([T].self, from: data)
                list = .loaded(decoded)
            } catch {
                list = .error(error)
            }
        }
    }

    // MARK: - Insert item and Save
    func insert(_ item: T) {
        Task {
            switch list {
            case .loaded(let currentItems):
                await replaceWithList([item] + currentItems)
            default:
                await replaceWithList([item])
            }
        }
    }
    
    // MARK: - Update item and Save
    func update(_ item: T) {
        Task {
            guard case .loaded(let currentItems) = list else { return }
            let updated = currentItems.map { $0.id == item.id ? item : $0 }
            await replaceWithList(updated)
        }
    }

    // MARK: - Delete item and Save
    func delete(_ item: T) {
        Task {
            guard case .loaded(let currentItems) = list else { return }
            let updated = currentItems.filter { $0.id != item.id }
            await replaceWithList(updated)
        }
    }

    // MARK: - Delete all items and Save
    func deleteAll() {
        Task {
            await replaceWithList([])
        }
    }

    // MARK: - private update stored list, save list to disk
    private func replaceWithList(_ items: [T]) async {
        do {
            try saveToDisk(items)
            list = .loaded(items)
        } catch {
            list = .error(error)
        }
    }

    private func saveToDisk(_ items: [T]) throws {
        let url = fileURL()
        let data = try JSONEncoder().encode(items)
        try data.write(to: url, options: .atomic)
    }

    private func fileURL() -> URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)
    }
}
