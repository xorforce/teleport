//
//  ExportState.swift
//  teleport-app
//
//  Created by Bhagat Singh on 07/01/26.
//

import Foundation
import Combine

class ExportState: ObservableObject {
    @Published var manifest: Manifest
    @Published var selectedCategories: Set<Category>
    @Published var isExporting: Bool = false
    @Published var exportProgress: Double = 0.0
    @Published var currentOperation: String = ""
    @Published var exportPath: URL?
    
    init() {
        self.manifest = Manifest()
        self.selectedCategories = Set(Category.allCases)
    }
    
    func toggleCategory(_ category: Category) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
    }
}

