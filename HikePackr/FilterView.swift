//
//  FilterView.swift
//  HikePackr
//
//  Created by Emelie on 2021-02-08.
//

import SwiftUI

struct FilterView: View {
    
    // FAKE FOR LAYOUT
    @State var tentIsChecked = false
    @State var cabinIsChecked = false
    @State var hotelIsChecked = false
    
    
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
                        Image(systemName: tentIsChecked ? "xmark.square" : "square")
                        Text("Tent")
                    }
                    .onTapGesture {
                        tentIsChecked.toggle()
                    }
                    HStack {
                        Image(systemName: cabinIsChecked ? "xmark.square" : "square")
                        Text("Cabin")
                    }
                    .onTapGesture {
                        cabinIsChecked.toggle()
                    }
                    HStack {
                        Image(systemName: hotelIsChecked ? "xmark.square" : "square")
                        Text("Hotel")
                    }
                    .onTapGesture {
                        hotelIsChecked.toggle()
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
