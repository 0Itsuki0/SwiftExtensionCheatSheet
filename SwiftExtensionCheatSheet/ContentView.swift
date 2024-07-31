//
//  ContentView.swift
//  SwiftExtensionCheatSheet
//
//  Created by Itsuki on 2024/07/30.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack (spacing: 50) {
            NavigationLink {
                AnimationAlongPath()
            } label: {
                Text("Animation Along Path")
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 16).fill(.black))
            }
            
            NavigationLink {
                ColorExtensionDemo()
            } label: {
                Text("Color Extension Demo")
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 16).fill(.black))
            }
            
            NavigationLink {
                DateExtensionDemo()
            } label: {
                Text("Date Extension Demo")
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 16).fill(.black))
            }

        }
        .foregroundStyle(.white)
        .font(.system(size: 24))
        .fixedSize(horizontal: true, vertical: false)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

#Preview {
    return NavigationStack {
        ContentView()
    }
}
