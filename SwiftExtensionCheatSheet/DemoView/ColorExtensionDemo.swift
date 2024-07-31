//
//  ColorExtensionDemo.swift
//  SwiftExtensionCheatSheet
//
//  Created by Itsuki on 2024/07/31.
//

import SwiftUI

struct ColorExtensionDemo: View {
    private static let colorString = "#0000FF"
    private let color = UIColor(hex: Self.colorString) ?? .clear

    var body: some View {

        VStack(spacing: 32) {
            Text(Self.colorString)
            if let rgba = color.rgba {
                Text("rgba from Color: \(rgba)")
            }

            if let hex = color.hex() {
                Text("hex from Color: \(hex)")
            }

            RoundedRectangle(cornerRadius: 16)
                .fill(Color(color))
                .frame(width: 150, height: 100)

            Text("inverted color")
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(color.inverted ?? .clear))
                .frame(width: 150, height: 100)
        }

    }
}

#Preview {
    ColorExtensionDemo()
}
