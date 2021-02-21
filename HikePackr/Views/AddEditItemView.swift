//
//  AddEditItemView.swift
//  HikePackr
//
//  Created by Emelie on 2021-02-08.
//

import SwiftUI

struct AddEditItemView: View {
    
    @State var item: Item? = nil
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    // variable for filter toggle
    @State var addFilters = false
    
    // item name
    @State var name: String = ""
    
    // item degrees
    @State var degreeIsChecked = false
    @State var minDegree = 10
    @State var maxDegree = 15
    
    // for picker views
    var minDegrees = [Int](0...30)
    var maxDegrees = [Int](0...30)
    
    // checks that minDegree is lower than maxDegree
    private var errorMinMaxDegree : Bool {
        minDegree >= maxDegree
    }
    
    // item type of stay
    @State var tentIsChecked = false
    @State var cabinIsChecked = false
    @State var hotelIsChecked = false
    
    // item quantity / measurement
    @State var quantity = 1
    @State var perXNumberOfDays = 0
    @State var measuremeant = "pcs"
    @State var selectedMeasurementIndex = 0
    var measurementOptions = ["pcs", "pair", "hectogram", "deciliter"]
    
    // set details of item when editing, only once
    @State var detailsSet = false
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Name of Item")) {
                    HStack {
                        TextField("", text: $name)
                        Image(systemName: "mic.fill")
                    }
                    
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
                            if (errorMinMaxDegree) {
                                Text("FROM degree must be lower than TO degree!")
                                    .font(.caption)
                                    .foregroundColor(Color.red)
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
            } // end of Form
        } // end of VStack
        .onAppear() {
            if(!detailsSet) {
                setDetails()
                detailsSet = true
            }
        }
        .navigationBarItems(trailing: Button(action: {
            save()
        }, label: {
            Text("Save")
        }).disabled(errorMinMaxDegree))
    }
    
    private func setDetails() {

        if let item = item {
            if let itemname = item.name {
                name = itemname
            }
            degreeIsChecked = item.whenDegrees
            minDegree = Int(item.minDegree)
            maxDegree = Int(item.maxDegree)
            //type of stay
            tentIsChecked = item.whenTent
            cabinIsChecked = item.whenCabin
            hotelIsChecked = item.whenHotel
            quantity = Int(item.quantity)
            if item.measurement == "pcs" {
                selectedMeasurementIndex = 0
            } else if(item.measurement == "pair") {
                selectedMeasurementIndex = 1
            } else if(item.measurement == "hectogram") {
                selectedMeasurementIndex = 2
            } else {
                selectedMeasurementIndex = 3
            }
            perXNumberOfDays = Int(item.perXNumberOfDays)
            if(!degreeIsChecked && !tentIsChecked && !cabinIsChecked && !hotelIsChecked && quantity == 1 && selectedMeasurementIndex == 0 && perXNumberOfDays == 0) {
                addFilters = false
            } else {
                addFilters = true
            }
        }
    }
    
    // SKA EJ GÅ ATT SPARA OM ERRORMINMAXDEGREE == TRUE
    private func save() {
        withAnimation {
            if let item = item {
                if name == "" {
                    item.name = "Item not named"
                } else {
                    item.name = name
                }
                item.whenTent = tentIsChecked
                item.whenCabin = cabinIsChecked
                item.whenHotel = hotelIsChecked
                item.quantity = Double(quantity)
                item.measurement = measurementOptions[selectedMeasurementIndex]
                item.perXNumberOfDays = Int64(perXNumberOfDays)
                item.whenDegrees = degreeIsChecked
                item.minDegree = Int64(minDegree)
                item.maxDegree = Int64(maxDegree)
                if (tentIsChecked == false && cabinIsChecked == false && hotelIsChecked == false) {
                    item.whenTypeOfStay = false
                } else {
                    item.whenTypeOfStay = true
                }
                if(tentIsChecked == false && cabinIsChecked == false && hotelIsChecked == false && degreeIsChecked == false) {
                    item.alwaysDisplayed = true
                } else {
                    item.alwaysDisplayed = false
                }
                item.category = ""
                item.isPacked = false
                
                if viewContext.hasChanges {
                    do {
                        try viewContext.save()
                        detailsSet = false
                        presentationMode.wrappedValue.dismiss()
                    } catch {
                        let nsError = error as NSError
                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                    }
                } else {
                    presentationMode.wrappedValue.dismiss()
                }
            
            } else {
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
                    detailsSet = false
                    presentationMode.wrappedValue.dismiss()
                } catch {
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
        } // end of save function
    }
}

struct AddEditItemView_Previews: PreviewProvider {
    static var previews: some View {
        AddEditItemView()
    }
}
