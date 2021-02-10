//
//  FilterView.swift
//  HikePackr
//
//  Created by Emelie on 2021-02-08.
//

import SwiftUI

struct FilterView: View {
    
    @State var degreeIsChecked = false
    
    // FAKE FOR LAYOUT
    @State var tentIsChecked = false
    @State var cabinIsChecked = false
    @State var hotelIsChecked = false
    
    // FAKE FOR LAYOUT
    @State var numberOfDays = 1
    
    // FAKE FOR LAYOUT
    @State var chosenDegree = 0.0
//    @State var minDegree = -10
//    @State var maxDegree = 30
   
    var body: some View {
        
        VStack {
            Form {
                Section(header: Text("Degrees")) {
                    Text("How many degrees will it be on your upcoming hike?")
                        .font(.caption)
                    HStack {
                        Image(systemName: degreeIsChecked ? "xmark.square" : "square")
                            Text("Choose degree range")
                    }
                    .onTapGesture {
                        degreeIsChecked.toggle()
                    }
                    if (degreeIsChecked) {
                        HStack {
                            Text("\(Int(chosenDegree)) °C")
                            Slider(value: $chosenDegree, in: -10...30, step: 1)
                        }
                    }
                }
                Section(header: Text("Type of stay")) {
                    Text("What type of stay(s) have you planned?")
                        .font(.caption)
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
                    Text("How many days will you hike?")
                        .font(.caption)
                    Stepper("\(numberOfDays) day(s)", value: $numberOfDays, in: 1...10)
                }
                HStack {
                    Spacer()
                    Button(action: {
                        print("Apply")
                    }, label: {
                        Text("Apply")
                })
                }
            }
        }
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView()
    }
}
