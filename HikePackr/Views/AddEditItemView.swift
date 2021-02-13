//
//  AddEditItemView.swift
//  HikePackr
//
//  Created by Emelie on 2021-02-08.
//

import SwiftUI

struct AddEditItemView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    // variable for filter toggle
    @State var addFilters = false
    
    // FAKE FOR LAYOUT
    @State var name: String = ""
    
    // FAKE FOR LAYOUT
    @State var degreeIsChecked = false
    @State var chosenDegree = 0.0
    
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
                VStack {
                    HStack {
                        Toggle(isOn: $addFilters, label: {
                            Text("Add filters?")
                        })
                    }
                    Text("If none is chosen, item is always shown")
                        .font(.caption)
                }
                if (addFilters) {
                    Section(header: Text("Degrees")) {
                        Toggle(isOn: $degreeIsChecked, label: {
                            Text("Add temperature filter")
                        })
                        if (degreeIsChecked) {
                            HStack {
                                Text("\(Int(chosenDegree)) °C")
                                Slider(value: $chosenDegree, in: -10...30, step: 1)
                            }
                        }
                    }
                    Section(header: Text("Type of stay")) {
                        Text("Will you use this item if you stay in a ... ?")
                            .font(.caption)
                        HStack {
                            Text("Tent")
                            Spacer()
                            Image(systemName: tentIsChecked ? "xmark.square" : "square")
                            
                        }
                        .onTapGesture {
                            tentIsChecked.toggle()
                        }
                        HStack {
                            Text("Cabin")
                            Spacer()
                            Image(systemName: cabinIsChecked ? "xmark.square" : "square")
                            
                        }
                        .onTapGesture {
                            cabinIsChecked.toggle()
                        }
                        HStack {
                            Text("Hotel")
                            Spacer()
                            Image(systemName: hotelIsChecked ? "xmark.square" : "square")
                            
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
                        Stepper(perXNumberOfDays == 0 ? "Always" : "Every \(perXNumberOfDays) day(s)", value: $perXNumberOfDays, in: 0...10)
                    }
                }
            }
        }
        .toolbar(content: {
            Button(action: {
                addItem()
            }, label: {
                Text("Save")
            })
        })
    }
    
    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            if name == "" {
                newItem.name = "Item not named"
            } else {
                newItem.name = name
            }
            newItem.whenTent = tentIsChecked
            newItem.whenCabin = cabinIsChecked
            newItem.whenHotel = hotelIsChecked
            newItem.quantity = Double(quantity)
            newItem.measurement = measurementOptions[selectedMeasurementIndex]
            newItem.perXNumberOfDays = Int16(perXNumberOfDays)
            newItem.whenDegrees = degreeIsChecked
            
            // FAKE VALUES FOR TESTING PURPOSES. CHANGE WHEN MULTISLIDER IMPLEMENTED.
            newItem.minDegree = 10
            newItem.maxDegree = 20
            
            // When no filter other than quantity is checked/changed, alwaysDisplayed is true, else false
            if(tentIsChecked == false && cabinIsChecked == false && hotelIsChecked == false && degreeIsChecked == false) {
                newItem.alwaysDisplayed = true
            } else {
                newItem.alwaysDisplayed = false
            }
            newItem.category = ""
            newItem.isPacked = false
            
            do {
                try viewContext.save()
                print("SAVED: \(newItem)")
                presentationMode.wrappedValue.dismiss()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct AddEditItemView_Previews: PreviewProvider {
    static var previews: some View {
        AddEditItemView()
    }
}
