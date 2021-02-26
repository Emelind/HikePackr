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
    
    //TEST SPEECH TO TEXT
    @State private var recording = false
    @ObservedObject private var mic = MicMonitor(numberOfSamples: 30)
    private var speechManager = SpeechManager()
    
    // variable for filter toggle
    @State var addFilters = false
    
    // item name
    @State var name: String = ""
    
    // category
    @State var category = "Clothing and Footwear"
    @State var selectedCategoryIndex = 0
    var categoryOptions = ["Clothing and footwear", "Personal items", "Food and water", "Navigation", "Emergency and first aid", "Health and hygiene", "Other"]
    
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
                Section(header: Text("Name of Item")) {
                    HStack {
                        ZStack {
                            TextField("", text: $name)
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.black.opacity(0.7))
                                .frame(height: 40)
                                .overlay(VStack {
                                    visualizerView()
                                })
                                .opacity(recording ? 1 : 0)
                        }
                        //recordButton()
                    }
                }
                Section(header: Text("Category")) {
                    Picker(selection: $selectedCategoryIndex, label: Text("")) {
                        ForEach(0 ..< categoryOptions.count) {
                            Text(self.categoryOptions[$0]).tag($0)
                        }
                    }
                }
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
            speechManager.checkPermissions()
            
            if(!detailsSet) {
                setDetails()
                detailsSet = true
            }
        }
    } // end of body
    
    private func saveButton() -> some View {
            Button(action: {
                save()
            }, label: {
                Text("Save")
            })
            .disabled(errorMinMaxDegree || name.count == 0)
    }
    
    private func recordButton() -> some View {
        Button(action: {
            recordItemName()
        }, label: {
            Image(systemName: recording ? "stop.fill" : "mic.fill")
                .foregroundColor(recording ? .red : .blue)
        })
    }
    
    private func recordItemName() {
        if speechManager.isRecording {
            self.recording = false
            mic.stopMonitoring()
            speechManager.stopRecording()
        } else {
            self.recording = true
            mic.startMonitoring()
            speechManager.start { (speechText) in
                guard let text = speechText, !text.isEmpty else {
                    self.recording = false
                    return
                }
                name = text
            }
        }
        speechManager.isRecording.toggle()
    }
    
    private func normalizedSoundLevel(level: Float) -> CGFloat {
        let level = max(0.2, CGFloat(level) + 50) / 2
        return CGFloat(level * (100 / 25))
    }
    
    private func visualizerView() -> some View {
        VStack {
            HStack(spacing: 2) {
                ForEach(mic.soundSamples, id: \.self) { level in
                    BarView(value: self.normalizedSoundLevel(level: level))
                }
            }
        }
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
        } // end of animation
    } // end of save function
} // end of struct

//struct AddEditItemView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddEditItemView()
//    }
//}
