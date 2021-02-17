//
//  FilterView.swift
//  HikePackr
//
//  Created by Emelie on 2021-02-08.
//

import SwiftUI

struct FilterView: View {
    
    //TEST SLIDER
    @ObservedObject var slider = CustomSlider(start: -10, end: 30)
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var filterSettings = FilterSettings()
    
    @AppStorage("minDegree") var minDegree : Int = 10
    @AppStorage("maxDegree") var maxDegree : Int = 20
    
    @State var minDegrees = [Int](0...30)
    @State var maxDegrees = [Int](0...30)
    @State var maxNumber = 30
    
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
                        // TEST SLIDER
//                        VStack {
//                            //Text("Value: " + slider.valueBetween)
//                            //Text("Percentages: " + slider.percentagesBetween)
//                            HStack {
//                                Text("From: \(Int(slider.lowHandle.currentValue)) °C")
//                                Spacer()
//                                Text("To: \(Int(slider.highHandle.currentValue)) °C")
//                            }
//                            //Slider
//                            SliderView(slider: slider)
//                                .padding(.bottom)
//                        } // END TEST SLIDER
                        Picker(selection: $minDegree, label: Text("From:"), content: {
                            ForEach(0..<minDegrees.count) { index in
                                Text("\(minDegrees[index]) °C").tag(index)
                            }
                        })
                        Picker(selection: $maxDegree, label: Text("To:"), content: {
                            ForEach(0..<maxDegrees.count) { index in
                                Text("\(maxDegrees[index]) °C").tag(index)
                            }
                        })
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
                    Text("For how many days will you hike?")
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
