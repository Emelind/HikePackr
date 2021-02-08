//
//  FilterView.swift
//  HikePackr
//
//  Created by Emelie on 2021-02-08.
//

import SwiftUI

struct FilterView: View {
    
    // FAKE FOR LAYOUT
    var isChecked = false
    
    // FAKE FOR LAYOUT
    @State var numberOfDays = 1
   
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Degrees")) {
                    Text("Slider goes here")
                }
                Section(header: Text("Type of stay")) {
                    HStack {
                        Image(systemName: isChecked ? "xmark.square" : "square")
                        Text("Tent")
                    }
                    HStack {
                        Image(systemName: isChecked ? "xmark.square" : "square")
                        Text("Cabin")
                    }
                    HStack {
                        Image(systemName: isChecked ? "xmark.square" : "square")
                        Text("Hotel")
                    }
                }
                Section(header: Text("Number of days")) {
                    Stepper("\(numberOfDays) day(s)", value: $numberOfDays, in: 1...10)
                }
                Button(action: {
                    print("Apply")
                }, label: {
                    Text("Apply")
                })
            }
            
        }
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView()
    }
}
