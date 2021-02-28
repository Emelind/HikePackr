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
    
    var item: Item? = nil
    
    // variable for filter toggle
    @State var addFilters = false
    
    // item name
    @State var name: String = ""
    
    // TEST category
    var categories = Categories()
    @State var category = "Other"
    @State var selectedCategoryIndex = 0
    //var categoryOptions = ["Other", "Clothing and footwear", "Emergency and first aid", "Food and water", "Health and hygiene", "Navigation", "Personal items"]
    
    // item degrees
    @State var degreeIsChecked = false
    @State var minDegree = 10
    @State var maxDegree = 15
    
    // for picker views degrees
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
    
    init(item: Item?) {
        self.item = item
    }
    
    var body: some View {
        VStack {
            Form {
                // text field for item name and a clear text button
                Section(header: Text("Name of Item")) {
                    HStack {
                        TextField("", text: $name)
                        clearTextButton
                    }
                }
                // select item category - other is default
                Section(header: Text("Category")) {
                    Picker(selection: $selectedCategoryIndex, label: Text("")) {
                        ForEach(0 ..< categories.categories.count) {
                            Text("\(self.categories.categories[$0])").tag($0)
                        }
                    }
                }
                // toggle to display filter options
                VStack {
                    Toggle(isOn: $addFilters, label: {
                        Text("Add filters?")
                    })
                    HStack {
                        Text("If none is chosen, item is always shown")
                            .font(.caption)
                        Spacer()
                    }
                }
                if (addFilters) {
                    // filter - degrees
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
                    // filter - type of stay
                    Section(header: Text("Type of stay")) {
                        Text("Will you use this item if you stay in a ... ?")
                            .font(.caption)
                        AddEditFilterTypeOfStayOptionView(text: "Tent", isChecked: tentIsChecked)
                            .onTapGesture {
                                tentIsChecked.toggle()
                            }
                        AddEditFilterTypeOfStayOptionView(text: "Cabin", isChecked: cabinIsChecked)
                            .onTapGesture {
                                cabinIsChecked.toggle()
                            }
                        AddEditFilterTypeOfStayOptionView(text: "Hotel", isChecked: hotelIsChecked)
                            .onTapGesture {
                                hotelIsChecked.toggle()
                            }
                    }
                    // filter - quantity per day and measurement
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
                } // end of if addFilters
            } // end of Form
        } // end of VStack
        .navigationBarItems(trailing: saveButton())
        .onAppear() {
            if(!detailsSet) {
                setDetails()
                detailsSet = true
            }
        }
    } // end of body
    
    // save button
    private func saveButton() -> some View {
            Button(action: {
                save()
            }, label: {
                Text("Save")
            })
            .disabled(errorMinMaxDegree || name.count == 0)
    }
    
    // clear text button
    private var clearTextButton: some View {
        return AnyView(Button(action: {
            name = ""
        }, label: {
            Image(systemName: "xmark.circle.fill")
        }).disabled(name.count == 0)
        )
    }

    // set details if editing an item
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
            if (item.category == "Other") {
                selectedCategoryIndex = 0
            } else if (item.category == "Clothing and footwear") {
                selectedCategoryIndex = 1
            }else if (item.category == "Emergency and first aid") {
                selectedCategoryIndex = 2
            } else if(item.category == "Food and water") {
                selectedCategoryIndex = 3
            } else if(item.category == "Health and hygiene") {
                selectedCategoryIndex = 4
            } else if(item.category == "Hiking gear") {
                selectedCategoryIndex = 5
            } else if(item.category == "Navigation") {
                selectedCategoryIndex = 6
            } else if(item.category == "Personal items") {
                selectedCategoryIndex = 7
            } else {
                selectedCategoryIndex = 0
            }
            perXNumberOfDays = Int(item.perXNumberOfDays)
            if(!degreeIsChecked && !tentIsChecked && !cabinIsChecked && !hotelIsChecked && quantity == 1 && selectedMeasurementIndex == 0 && perXNumberOfDays == 0) {
                addFilters = false
            } else {
                addFilters = true
            }
        } else {
            return
        }
    }
    
    // save new or edited item
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
                item.category = categories.categories[selectedCategoryIndex]
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
                newItem.category = categories.categories[selectedCategoryIndex]
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
        } // end of animation
    } // end of save function
} // end of struct

//struct AddEditItemView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddEditItemView()
//    }
//}
