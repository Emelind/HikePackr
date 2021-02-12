//
//  FilterView.swift
//  HikePackr
//
//  Created by Emelie on 2021-02-08.
//

import SwiftUI

struct FilterView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var filterSettings = FilterSettings()
    
    // DEGREE SLIDER, WILL CHANGE
    @State var chosenDegree = 0.0
   
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Degrees")) {
                    Text("How many degrees °C will it be on your upcoming hike?")
                        .font(.caption)
                    Toggle(isOn: $filterSettings.degreeIsChecked) {
                        Text("Choose degree range")
                    }
                    if (filterSettings.degreeIsChecked) {
                        HStack {
                            Text("\(Int(chosenDegree)) °C")
                            Slider(value: $chosenDegree, in: -10...30, step: 1)
                        }
                    }
                }
                Section(header: Text("Type of stay")) {
                    Text("What type of stay(s) have you planned?")
                        .font(.caption)
                    Toggle(isOn: $filterSettings.tentIsChecked) {
                        Text("Tent")
                    }
                    Toggle(isOn: $filterSettings.cabinIsChecked) {
                        Text("Cabin")
                    }
                    Toggle(isOn: $filterSettings.hotelIsChecked) {
                        Text("Hotel")
                    }
                }
                Section(header: Text("Number of days")) {
                    Text("How many days will you hike?")
                        .font(.caption)
                    Stepper("\(filterSettings.numberOfDays) day(s)", value: $filterSettings.numberOfDays, in: 1...10)
                }
            }
        }
        .toolbar(content: {
            Button(action: {
                resetFilters()
            }, label: {
                Text("Reset")
            })
        })
    }
    
    private func resetFilters() {
        filterSettings.degreeIsChecked = false
        filterSettings.minDegree = 10
        filterSettings.maxDegree = 20
        filterSettings.tentIsChecked = false
        filterSettings.cabinIsChecked = false
        filterSettings.hotelIsChecked = false
        filterSettings.numberOfDays = 1
        
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView()
    }
}
