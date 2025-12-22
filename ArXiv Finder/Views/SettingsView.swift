//
//  SettingsView.swift
//  ArXiv App
//
//  Created by Julián Hinojosa Gil on 3/7/25.
//

import SwiftUI
import UserNotifications
#if os(macOS)
import AppKit
#endif

/// Simplified settings view for the ArXiv Finder app
/// Provides essential options with immediate application of changes
#if os(macOS)
struct SettingsView: View {
    
    // MARK: - Settings Properties
    @AppStorage("refreshInterval") private var refreshInterval = 30
    @AppStorage("maxPapers") private var maxPapers = 10
    @AppStorage("defaultCategory") private var defaultCategory = "latest"
    @AppStorage("autoRefresh") private var autoRefresh = false
    @AppStorage("showNotifications") private var showNotifications = true
    @AppStorage("compactMode") private var compactMode = false
    @AppStorage("showPreview") private var showPreview = true
    @AppStorage("fontSize") private var fontSize = 14.0
    
    // MARK: - State Properties
    @State private var showingResetAlert = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Image(systemName: "gear")
                    .font(.title2)
                    .foregroundColor(.blue)
                Text("Settings")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.bottom, 10)
            
            Divider()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Content Settings
                    settingsSection(title: "Content", icon: "doc.text") {
                        VStack(spacing: 12) {
                            settingRow(title: "Maximum papers", value: "\(maxPapers)") {
                                Stepper("", value: $maxPapers, in: 5...50, step: 5)
                                    .labelsHidden()
                            }
                            
                            settingRow(title: "Default category", value: categoryDisplayName) {
                                Picker("", selection: $defaultCategory) {
                                    Text("Latest").tag("latest")
                                    Text("Computer Science").tag("cs")
                                    Text("Mathematics").tag("math")
                                    Text("Physics").tag("physics")
                                    Text("Statistics").tag("stat")
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(width: 150)
                            }
                        }
                    }
                    
                    // Interface Settings
                    settingsSection(title: "Interface", icon: "paintbrush") {
                        VStack(spacing: 12) {
                            settingRow(title: "Compact mode", value: compactMode ? "On" : "Off") {
                                Toggle("", isOn: $compactMode)
                                    .labelsHidden()
                            }
                            
                            settingRow(title: "Show preview", value: showPreview ? "On" : "Off") {
                                Toggle("", isOn: $showPreview)
                                    .labelsHidden()
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Font size")
                                        .fontWeight(.medium)
                                    Spacer()
                                    Text("\(Int(fontSize))pt")
                                        .foregroundColor(.blue)
                                        .fontWeight(.semibold)
                                }
                                
                                Slider(value: $fontSize, in: 10...20, step: 1)
                                    .tint(.blue)
                            }
                        }
                    }
                    
                    // Update Settings
                    settingsSection(title: "Updates", icon: "arrow.clockwise") {
                        VStack(spacing: 12) {
                            settingRow(title: "Auto refresh", value: autoRefresh ? "On" : "Off") {
                                Toggle("", isOn: $autoRefresh)
                                    .labelsHidden()
                            }
                            
                            if autoRefresh {
                                settingRow(title: "Interval", value: "\(refreshInterval) min") {
                                    Stepper("", value: $refreshInterval, in: 5...120, step: 5)
                                        .labelsHidden()
                                }
                            }
                        }
                    }
                    
                    // Notifications
                    settingsSection(title: "Notifications", icon: "bell") {
                        settingRow(title: "Show notifications", value: showNotifications ? "On" : "Off") {
                            Toggle("", isOn: $showNotifications)
                                .labelsHidden()
                        }
                    }
                    
                    // Actions
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                            Text("About")
                                .font(.headline)
                            Spacer()
                        }
                        
                        VStack(spacing: 8) {
                            HStack {
                                Text("Version")
                                Spacer()
                                Text("1.0.0")
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack {
                                Text("Developer")
                                Spacer()
                                Text("Julián Hinojosa Gil")
                                    .foregroundColor(.secondary)
                            }
                            
                            Button("Reset Settings") {
                                showingResetAlert = true
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        }
                        .padding(.leading, 20)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(20)
        .frame(width: 500, height: 650)
        .alert("Reset Settings", isPresented: $showingResetAlert) {
            Button("Reset", role: .destructive) {
                resetSettings()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to reset all settings?")
        }
    }
    
    // MARK: - Helper Views
    
    private func settingsSection<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.headline)
                Spacer()
            }
            
            VStack(spacing: 8) {
                content()
            }
            .padding(.leading, 20)
        }
    }
    
    private func settingRow<Content: View>(title: String, value: String, @ViewBuilder control: () -> Content) -> some View {
        HStack {
            Text(title)
                .fontWeight(.medium)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
            control()
        }
    }
    
    private var categoryDisplayName: String {
        switch defaultCategory {
        case "latest": return "Latest"
        case "cs": return "Computer Science"
        case "math": return "Mathematics"
        case "physics": return "Physics"
        case "stat": return "Statistics"
        default: return defaultCategory.capitalized
        }
        }
    
    // MARK: - Helper Methods
    
    /// Reset all settings to their default values
    private func resetSettings() {
        refreshInterval = 30
        maxPapers = 10
        defaultCategory = "latest"
        autoRefresh = false
        showNotifications = true
        compactMode = false
        showPreview = true
        fontSize = 14.0
        
        // Notify changes
        NotificationCenter.default.post(
            name: .settingsChanged,
            object: nil
        )
    }
}

// MARK: - Previews
#if os(macOS)
#Preview("macOS Settings") {
    SettingsView()
        .frame(width: 500, height: 650)
}
#endif

#if os(iOS)
#Preview("iOS Settings") {
    SettingsView()
}
#endif

#endif

#if os(iOS)
struct SettingsView: View {
    
    // MARK: - Settings Properties
    @AppStorage("refreshInterval") private var refreshInterval = 30
    @AppStorage("maxPapers") private var maxPapers = 10
    @AppStorage("defaultCategory") private var defaultCategory = "latest"
    @AppStorage("autoRefresh") private var autoRefresh = false
    @AppStorage("showNotifications") private var showNotifications = true
    @AppStorage("compactMode") private var compactMode = false
    @AppStorage("showPreview") private var showPreview = true
    @AppStorage("fontSize") private var fontSize = 14.0
    
    // MARK: - State Properties
    @State private var isTestingConnection = false
    @State private var connectionTestResult = ""
    @State private var showingConnectionAlert = false
    @State private var showingResetAlert = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                // General Settings Section
                Section("General") {
                    HStack {
                        Text("Maximum papers")
                        Spacer()
                        Stepper(value: $maxPapers, in: 5...50, step: 5) {
                            Text("\(maxPapers)")
                        }
                    }
                    
                    HStack {
                        Text("Default category")
                        Spacer()
                        Picker("Category", selection: $defaultCategory) {
                            Text("Latest").tag("latest")
                            Text("Computer Science").tag("cs")
                            Text("Mathematics").tag("math")
                            Text("Physics").tag("physics")
                            Text("Quantitative Biology").tag("q-bio")
                            Text("Quantitative Finance").tag("q-fin")
                            Text("Statistics").tag("stat")
                            Text("Electrical Engineering").tag("eess")
                            Text("Economics").tag("econ")
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                
                // Update Settings Section
                Section("Update") {
                    Toggle("Automatic update", isOn: $autoRefresh)
                    
                    if autoRefresh {
                        HStack {
                            Text("Interval")
                            Spacer()
                            Picker("Interval", selection: $refreshInterval) {
                                Text("5 min").tag(5)
                                Text("15 min").tag(15)
                                Text("30 min").tag(30)
                                Text("60 min").tag(60)
                                Text("120 min").tag(120)
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                    }
                }
                
                // Interface Settings Section
                Section("Interface") {
                    Toggle("Compact mode", isOn: $compactMode)
                    Toggle("Show preview", isOn: $showPreview)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Font size")
                            Spacer()
                            Text("\(Int(fontSize))pt")
                                .foregroundColor(.blue)
                        }
                        
                        Slider(value: $fontSize, in: 10...20, step: 1)
                            .tint(.blue)
                    }
                }
                
                // Notifications Section
                Section("Notifications") {
                    Toggle("Show notifications", isOn: $showNotifications)
                    
                    if showNotifications {
                        Button("Test Notification") {
                            testNotification()
                        }
                        .foregroundColor(.blue)
                    }
                }
                
                // About Section
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Developer")
                        Spacer()
                        Text("Julián Hinojosa Gil")
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Test Connection") {
                        testConnection()
                    }
                    .foregroundColor(.blue)
                    .disabled(isTestingConnection)
                }
                
                // Actions Section
                Section {
                    Button("Reset Settings") {
                        showingResetAlert = true
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Connection Result", isPresented: $showingConnectionAlert) {
            Button("OK") { }
        } message: {
            Text(connectionTestResult)
        }
        .alert("Reset Settings", isPresented: $showingResetAlert) {
            Button("Reset", role: .destructive) {
                resetSettings()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to reset all settings?")
        }
    }
    
    // MARK: - Helper Methods
    
    /// Request notification permissions
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if !granted {
                    self.showNotifications = false
                }
            }
        }
    }
    
    /// Send a test notification
    private func testNotification() {
        let content = UNMutableNotificationContent()
                        content.title = "ArXiv Finder - Test"
        content.body = "Notifications are working correctly."
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "test-notification",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending notification: \(error)")
            }
        }
    }
    
    /// Test the connection with ArXiv
    private func testConnection() {
        isTestingConnection = true
        
        Task {
            do {
                let url = URL(string: "https://export.arxiv.org/api/query?search_query=all:test&start=0&max_results=1")!
                let (_, response) = try await URLSession.shared.data(from: url)
                
                DispatchQueue.main.async {
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode == 200 {
                            self.connectionTestResult = "✅ Successful connection"
                        } else {
                            self.connectionTestResult = "❌ HTTP Error: \(httpResponse.statusCode)"
                        }
                    }
                    self.isTestingConnection = false
                    self.showingConnectionAlert = true
                }
            } catch {
                DispatchQueue.main.async {
                    self.connectionTestResult = "❌ Error: \(error.localizedDescription)"
                    self.isTestingConnection = false
                    self.showingConnectionAlert = true
                }
            }
        }
    }
    
    /// Reset all settings to their default values
    private func resetSettings() {
        refreshInterval = 30
        maxPapers = 10
        defaultCategory = "latest"
        autoRefresh = false
        showNotifications = true
        compactMode = false
        showPreview = true
        fontSize = 14.0
        
        // Notify changes
        NotificationCenter.default.post(
            name: .settingsChanged,
            object: nil
        )
    }
}
#endif
