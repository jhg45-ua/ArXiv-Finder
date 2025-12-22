//
//  PaperDetailView.swift
//  ArXiv App
//
//  Created by Julián Hinojosa Gil on 2/7/25.
//

import SwiftUI

/// Detailed view that shows all the information of a scientific paper
/// Destination screen when the user selects a paper from the list
///
/// Information displayed:
/// - Full title of the article
/// - Complete list of authors
/// - Publication and update dates
/// - Complete summary/abstract of the paper
/// - Scientific categories as badges
/// - Links to open the PDF and the article's web page
/// - Share actions (iOS) or contextual menus (macOS)
///
/// Navigation:
/// - iOS: Modal or push navigation with back button
/// - macOS: Detail panel in NavigationSplitView
/// - Action buttons adaptive to the platform
struct PaperDetailView: View {
    /// The article to display in detail
    let paper: ArXivPaper
    
    /// Controller to handle favorite logic
    let controller: ArXivController?
    
    /// Optional callback to return to the list (used in some navigation flows)
    let onBackToList: (() -> Void)?
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Paper title
                Text(paper.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom, 8)
                
                // Author and date information
                VStack(alignment: .leading, spacing: 8) {
                    Label(paper.authors, systemImage: "person.2")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Label(paper.publishedDate.formatted(date: .abbreviated, time: .omitted), 
                          systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // Update date (if exists and is different)
                    if let updatedDate = paper.updatedDate,
                       abs(updatedDate.timeIntervalSince(paper.publishedDate)) > 3600 { // More than 1 hour difference
                        Label("Updated: \(updatedDate.formatted(date: .abbreviated, time: .omitted))", 
                              systemImage: "arrow.clockwise")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
                Divider()
                
                // Paper categories
                if !paper.categories.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Categories")
                            .font(.headline)
                        
                        Text(paper.categories)
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                    }
                    
                    Divider()
                }
                
                // Paper summary
                VStack(alignment: .leading, spacing: 8) {
                    Text("Summary")
                        .font(.headline)
                    
                    Text(paper.summary)
                        .font(.body)
                        .lineSpacing(4)
                }
                
                Divider()
                
                // Access links
                VStack(alignment: .leading, spacing: 12) {
                    Text("Links")
                        .font(.headline)
                    
                    HStack(spacing: 16) {
                        if !paper.pdfURL.isEmpty {
                            Link(destination: URL(string: paper.pdfURL)!) {
                                HStack {
                                    Image(systemName: "doc.fill")
                                    Text("View PDF")
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.red)
                                .cornerRadius(8)
                            }
                        }
                        
                        if !paper.linkURL.isEmpty {
                            Link(destination: URL(string: paper.linkURL)!) {
                                HStack {
                                    Image(systemName: "link")
                                    Text("View in ArXiv")
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.blue)
                                .cornerRadius(8)
                            }
                        }
                    }
                }
                
                Spacer(minLength: 50)
            }
            .padding()
        }
        .navigationTitle("Paper Detail")
        #if os(macOS)
        .navigationSubtitle(paper.authors)
        .frame(minWidth: 400, minHeight: 300)
        #else
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItemGroup(placement: toolbarPlacement) {
                // Favorite button for both platforms
                if let controller = controller {
                    Button(action: {
                        controller.toggleFavorite(for: paper)
                    }) {
                        Image(systemName: paper.isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(paper.isFavorite ? .red : .primary)
                    }
                    .help(paper.isFavorite ? "Remove from favorites" : "Add to favorites")
                }
                
                #if os(macOS)
                // Share functionality for macOS
                Button("Share") {
                }
                #endif
            }
        }
    }
    
    /// Determine the toolbar location according to the platform
    private var toolbarPlacement: ToolbarItemPlacement {
        #if os(macOS)
        return .automatic
        #else
        return .navigationBarTrailing
        #endif
    }
}

#Preview {
    NavigationView {
        PaperDetailView(
            paper: ArXivPaper(
                id: "2025.0001",
                title: "Example of ArXiv paper for Detail View",
                summary: "This is a more extensive example of a scientific paper that shows how it would look in the detail view of the application. It includes detailed technical information and multiple paragraphs to demonstrate the format.",
                authors: "John Doe, Jane Smith, Carlos López",
                publishedDate: Date(),
                updatedDate: Date(),
                pdfURL: "https://arxiv.org/pdf/2025.0001.pdf",
                linkURL: "https://arxiv.org/abs/2025.0001",
                categories: "cs.AI cs.LG stat.ML"
            ),
            controller: nil,
            onBackToList: nil
        )
    }
}
