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
                        VStack {
                            //Text("Value: " + slider.valueBetween)
                            //Text("Percentages: " + slider.percentagesBetween)
                            HStack {
                                Text("From: \(Int(slider.lowHandle.currentValue)) °C")
                                Spacer()
                                Text("To: \(Int(slider.highHandle.currentValue)) °C")
                            }
                            //Slider
                            SliderView(slider: slider)
                                .padding(.bottom)
                        } // END TEST SLIDER
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

/*
 1. INGA FILTER
 ** all items
 ** except item.isPacked == true
 
 2. BARA DEGREE, EJ STAY
 ** item.whenDegree == true  && item.minDegree..item.maxDegree match filterSettings.minDegree...filterSettings.maxDegree
 ** item.whenDegree == false && item.whenTypeOfStay == true
 ** item.alwaysDisplayed == true
 ** except item.isPacked == true
 
 3. BARA STAY, EJ DEGREE
 ** item.whenTypeOfStay == true && item.whenXXX match filterSettings.XXXisChecked == true
 ** item.whenTypeOfStay == false && item.whenDegree == true
 ** item.alwaysDisplayed == true
 ** except item.isPacked == true
 
 4. COMBO - DEGREE + STAY
 ** item.whenDegree == true && item.minDegree..item.maxDegree match filterSettings.minDegree...filterSettings.maxDegree
        &&
    item.whenTypeOfStay == true && item.whenXXX match filterSettings.XXXisChecked == true
 ** item.whenDegree == true && tem.minDegree..item.maxDegree match filterSettings.minDegree...filterSettings.maxDegree
        &&
    item.whenTypeOfStay == false
 ** item.whenDegree == false
        &&
    item.whenTypeOfStay == true && item.whenXXX match filterSettings.XXXisChecked == true
 ** except item.isPacked == true
 */
