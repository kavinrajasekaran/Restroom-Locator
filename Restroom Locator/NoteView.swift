//
//  NoteView.swift
//  Restroom Locator
//
//  Created by Kavin Rajasekaran on 9/28/24.
//

// NoteView.swift

import SwiftUI
import MapKit

struct NoteView: View {
    var annotation: MKPointAnnotation
    @Binding var isPresented: Bool
    @State private var note: String = ""

    var body: some View {
        VStack {
            Text(annotation.title ?? "Restaurant")
                .font(.headline)
                .padding()

            TextField("Enter restroom code or note", text: $note)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            HStack {
                Button(action: {
                    isPresented = false
                }) {
                    Text("Cancel")
                }
                Spacer()
                Button(action: {
                    saveNote()
                    isPresented = false
                }) {
                    Text("Save")
                }
            }
            .padding()
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(10)
        .padding()
        .onAppear {
            loadNote()
        }
    }

    func saveNote() {
        let key = "\(annotation.coordinate.latitude),\(annotation.coordinate.longitude)"
        UserDefaults.standard.setValue(note, forKey: key)
    }

    func loadNote() {
        let key = "\(annotation.coordinate.latitude),\(annotation.coordinate.longitude)"
        if let savedNote = UserDefaults.standard.string(forKey: key) {
            note = savedNote
        }
    }
}
