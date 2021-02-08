//
//  AddEditItemView.swift
//  HikePackr
//
//  Created by Emelie on 2021-02-08.
//

import SwiftUI

struct AddEditItemView: View {
    
    // FAKE FOR LAYOUT
    @State var name: String = ""
    
    // FAKE FOR LAYOUT
    @State var tentIsChecked = false
    @State var cabinIsChecked = false
    @State var hotelIsChecked = false
    
    // FAKE FOR LAYOUT
    @State var quantity = 1
    @State var perXNumberOfDays = 0
    @State var measuremeant = "pcs"
    @State var selectedMeasurementIndex = 0
    var measurementOptions = ["pcs", "pair", "hectogram", "deciliter"]
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Name of Item")) {
                    TextEditor(text: $name)
                }
                HStack {
                    Text("Add filters?")
                    Text("(Optional - If none is chosen, item is always shown)")
                        .font(.caption)
                }
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
                Section(header: Text("Quantity")) {
                    Text("If below filter is not actively modified, default number is 1 pcs dependless of number of days")
                        .font(.caption)
                    Stepper("Quantity: \(quantity)", value: $quantity, in: 1...10)
                    Picker(selection: $selectedMeasurementIndex, label: Text("Means of measurement")) {
                        ForEach(0 ..< measurementOptions.count) {
                            Text(self.measurementOptions[$0]).tag($0)
                        }
                    }
                    //Ändra nedan till att visa ALWAYS om perXNumberOfDays == 0 (< 1)
                    Stepper("Every \(perXNumberOfDays) day(s)", value: $perXNumberOfDays, in: 0...10)
                }
            }
        }
    }
}

struct AddEditItemView_Previews: PreviewProvider {
    static var previews: some View {
        AddEditItemView()
    }
}
