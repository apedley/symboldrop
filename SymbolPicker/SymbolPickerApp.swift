//
//  SymbolPickerApp.swift
//  SymbolPicker
//
//  Created by Andrew Pedley on 12/11/25.
//

import SwiftUI

@main
struct SymbolPickerApp: App {
  var body: some Scene {
    MenuBarExtra {
      ContentView()
        .frame(minWidth: 400, maxWidth: 800, minHeight: 400, maxHeight: 800)
    } label: {
      Label {
        Text("SymbolDrop")
      } icon: {
        let image: NSImage = {
          let ratio = $0.size.height / $0.size.width
          $0.size.height = 18
          $0.size.width = 18 / ratio
          $0.isTemplate = true
          return $0
        }(NSImage(named: "MenuBarIcon")!)

        Image(nsImage: image)
      }

    }
    .menuBarExtraStyle(.window)
    .windowResizability(.contentSize)
    .defaultSize(width: 550, height: 550)
  }
}
