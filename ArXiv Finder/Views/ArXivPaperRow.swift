//
//  ArXivPaperRow.swift
//  ArXiv App
//
//  Created by Julián Hinojosa Gil on 2/7/25.
//

import SwiftUI

/// Reusable view that represents a single paper row in the list
/// Displays summary information about the paper with adaptive design
///
/// Features:
/// - Article title with intelligent truncation
/// - List of authors (hidden in compact mode)
/// - Formatted publication date
/// - Summary preview (optional)
/// - Article categories as badges
/// - Customizable settings via AppStorage
///
/// Supported settings:
/// - Font size adjustable
/// - Compact mode to show more elements
/// - Toggle to show/hide summary preview
struct ArXivPaperRow: View {
    /// The paper to display in this row
    let paper: ArXivPaper
    
    /// Controller to handle favorite logic
    let controller: ArXivController?
    
    // MARK: - Settings from AppStorage
    @AppStorage("fontSize") private var fontSize = 14.0
    @AppStorage("compactMode") private var compactMode = false
    @AppStorage("showPreview") private var showPreview = true
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: compactMode ? 8 : 12) {
                // Article title
                Text(paper.title)
                    .font(.system(size: fontSize, weight: .medium))
                    .lineLimit(compactMode ? 2 : 4)
                    .multilineTextAlignment(.leading)
                
                // Article authors (only if not in compact mode)
                if !compactMode {
                    Text(paper.authors)
                        .font(.system(size: fontSize - 2))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                // Article summary (only if preview is enabled)
                if showPreview {
                    Text(paper.summary)
                        .font(.system(size: fontSize - 4))
                        .foregroundColor(.secondary)
                        .lineLimit(compactMode ? 1 : 2)
                        .padding(.top, 2)
                }
                
                HStack {
                    // Paper dates
                    VStack(alignment: .leading, spacing: 2) {
                        // Publication date
                        Label(paper.publishedDate.formatted(date: .abbreviated, time: .omitted), 
                              systemImage: "calendar")
                            .font(.system(size: fontSize - 5))
                            .foregroundColor(.secondary)
                        
                        // Update date (if exists, is different and not in compact mode)
                        if !compactMode,
                           let updatedDate = paper.updatedDate,
                           abs(updatedDate.timeIntervalSince(paper.publishedDate)) > 3600 { // More than 1 hour difference
                            Label("Updated: \(updatedDate.formatted(date: .abbreviated, time: .omitted))", 
                                  systemImage: "arrow.clockwise")
                                .font(.system(size: fontSize - 5))
                                .foregroundColor(.orange)
                        }
                    }
                    
                    Spacer()
                    
                    // Article categories
                    if !compactMode && !paper.categories.isEmpty {
                        let categories = paper.categories.split(separator: " ").map(String.init)
                        HStack(spacing: 4) {
                            ForEach(categories.prefix(2), id: \.self) { category in
                                Text(category)
                                    .font(.system(size: fontSize - 5))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(6)
                            }
                        }
                    }
                }
            }
            
            // Favorite button (if controller is available)
            if let controller = controller {
                Button(action: {
                    controller.toggleFavorite(for: paper)
                }) {
                    Image(systemName: paper.isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(paper.isFavorite ? .red : .gray)
                        .font(.system(size: fontSize))
                }
                .buttonStyle(PlainButtonStyle())
                .help(paper.isFavorite ? "Remove from favorites" : "Add to favorites")
            }
        }
        .padding(.vertical, compactMode ? 12 : 16)
        #if os(macOS)
        .padding(.horizontal, 20)
        .background(Color.clear)
        .cornerRadius(12)
        .contentShape(Rectangle())
        #endif
    }
}

#Preview {
    ArXivPaperRow(
        paper: ArXivPaper(
            id: "2025.0001",
            title: "Example of ArXiv paper",
            summary: "This is an example summary of a scientific paper that shows how it would look in the application.",
            authors: "John Doe, Jane Smith",
            publishedDate: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date(),
            updatedDate: Date(),
            pdfURL: "https://arxiv.org/pdf/2025.0001.pdf",
            linkURL: "https://arxiv.org/abs/2025.0001",
            categories: "cs.AI cs.LG"
        ),
        controller: ArXivController()
    )
    .padding()
}
