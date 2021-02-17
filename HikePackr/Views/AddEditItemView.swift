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
    @State var minDegree = 10
    @State var maxDegree = 15
    
    var minDegrees = [Int](0...30)
    var maxDegrees = [Int](0...30)
    
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
            newItem.perXNumberOfDays = Int64(perXNumberOfDays)
            newItem.whenDegrees = degreeIsChecked
            
            // FAKE VALUES FOR TESTING PURPOSES. CHANGE WHEN MULTISLIDER IMPLEMENTED.
            newItem.minDegree = Int64(minDegree)
            newItem.maxDegree = Int64(maxDegree)
            if (tentIsChecked == false && cabinIsChecked == false && hotelIsChecked == false) {
                newItem.whenTypeOfStay = false
            } else {
                newItem.whenTypeOfStay = true
            }
            
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
                presentationMode.wrappedValue.dismiss()
                print(newItem)
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        } // end of addItem function
        
//        for save function when editing - use:
//        if viewContext.hasChanges {
//            do {
//                try viewContext.save()
//            } catch {
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
    }
}

struct AddEditItemView_Previews: PreviewProvider {
    static var previews: some View {
        AddEditItemView()
    }
}
