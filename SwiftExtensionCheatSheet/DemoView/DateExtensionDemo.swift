//
//  DateExtensionDemo.swift
//  SwiftExtensionCheatSheet
//
//  Created by Itsuki on 2024/07/31.
//

import SwiftUI

struct DateExtensionDemo: View {
    private let dateFormatter = Date.dateFormatter
    private let date = Date()
    var body: some View {
        VStack(spacing: 24) {
            Text("current date: \(date)")
                .multilineTextAlignment(.center)
            
            Text("localizedDate")
                .font(.headline)
            Text(date.localizedDate)
            
            Text("localizedDate with Weekday")
                .font(.headline)
            Text(date.localizedDateWithWeekday)
            
            Text("localizedYearMonth")
                .font(.headline)
            Text(date.localizedYearMonth)
            
            Text("localizedDate")
                .font(.headline)
            Text(date.localizedDate)
            
            Text("localizedTodaySymbol")
                .font(.headline)
            Text(Date.localizedTodaySymbol)
            
            Text("Add Date")
                .font(.headline)
            Text(date.plusDate(1).localizedDate)
            
            Text("Add month")
                .font(.headline)
            Text(date.plusMonth(1).localizedDate)

        }
        .padding(.all, 16)
    }
}



#Preview {
    DateExtensionDemo()
}
