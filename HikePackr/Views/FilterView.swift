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
    
    // updating user defaults
    @AppStorage("minDegree") var minDegree : Int = 10
    @AppStorage("maxDegree") var maxDegree : Int = 20
    
    // ranges for degree pickers
    @State var minDegrees = [Int](0...30)
    @State var maxDegrees = [Int](0...30)
    
    // checks that minDegree is lower than maxDegree, else maxdegree is changed to min + 1
    var errorMinMaxDegree : Bool {
        let a = minDegree >= maxDegree
        if(a) {
            maxDegree = minDegree + 1
        }
        return a
    }

    var body: some View {
        VStack {
            Form {
                // filter selections - degrees
                Section(header: Text("Degrees")) {
                    Text("How many degrees °C will it be on your upcoming hike?")
                        .font(.caption)
                    Toggle(isOn: $filterSettings.degreeIsChecked) {
                        Text("Choose degree range")
                    }
                    if (filterSettings.degreeIsChecked) {
                        // min degrees
                        Picker(selection: $minDegree, label: Text("From:"), content: {
                            ForEach(minDegrees, id: \.self) { index in
                                Text("\(minDegrees[index]) °C").tag(index)
                            }
                        })
                        // max degrees
                        Picker(selection: $maxDegree, label: Text("To:"), content: {
                            ForEach(maxDegrees, id: \.self) { index in
                                Text("\(maxDegrees[index]) °C").tag(index)
                            }
                        })
                        // text displayed if from degree is higher than to degree
                        if(errorMinMaxDegree) {
                            Text("From degree must be lower than to degree")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
                .padding(.top)
                // filter selections - type of stay
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
                // filter selection - number of days
                Section(header: Text("Number of days")) {
                    Text("For how many days will you hike?")
                        .font(.caption)
                    Stepper("\(filterSettings.numberOfDays) day(s)", value: $filterSettings.numberOfDays, in: 1...10)
                }
            } // end of form
        } // end of VStack
        .navigationBarBackButtonHidden(errorMinMaxDegree)
        .navigationBarItems(trailing: resetButton)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text("Filter")
                        .font(.title2)
                }
            }
        }
    } // end of body
    
    private var resetButton: some View {
        return AnyView(Button(action: {
            resetFilters()
        }, label: {
            Text("Reset")
                .font(.body)
        }))
    }
    
    // resets filters
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
