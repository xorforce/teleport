//
//  Category.swift
//  teleport-app
//
//  Created by Bhagat Singh on 07/01/26.
//

import Foundation

enum Category: String, CaseIterable, Identifiable {
    case homebrew = "Homebrew"
    case nodePackages = "Node Packages"
    case mise = "Mise"
    case dotfiles = "Dotfiles"
    case macSettings = "macOS Settings"
    case ide = "IDE Profiles"
    case fonts = "Fonts"
    case shellHistory = "Shell History"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .homebrew: return "cup.and.saucer.fill"
        case .nodePackages: return "cube.fill"
        case .mise: return "wrench.and.screwdriver.fill"
        case .dotfiles: return "doc.text.fill"
        case .macSettings: return "gearshape.fill"
        case .ide: return "applescript.fill"
        case .fonts: return "textformat"
        case .shellHistory: return "terminal.fill"
        }
    }
    
    var description: String {
        switch self {
        case .homebrew: return "Homebrew packages and casks"
        case .nodePackages: return "npm, bun, pnpm, and yarn packages"
        case .mise: return "Mise tool versions"
        case .dotfiles: return "Configuration files (.zshrc, .gitconfig, etc.)"
        case .macSettings: return "System preferences and settings"
        case .ide: return "VS Code, Cursor, and Xcode configurations"
        case .fonts: return "User-installed fonts"
        case .shellHistory: return "Shell command history"
        }
    }
}

