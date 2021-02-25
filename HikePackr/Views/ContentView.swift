//
//  ContentView.swift
//  HikePackr
//
//  Created by Emelie on 2021-02-08.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    // tracking changes in user defaults, used in filterItems function and calculate quantity
    @AppStorage("degree") var degreeIsChecked : Bool = false
    @AppStorage("minDegree") var minDegree : Int = 10
    @AppStorage("maxDegree") var maxDegree : Int = 20
    
    @AppStorage("tent") var tentIsChecked: Bool = false
    @AppStorage("cabin") var cabinIsChecked: Bool = false
    @AppStorage("hotel") var hotelIsChecked: Bool = false
    
    @AppStorage("days") var numberOfDays : Int = 1
    
    // fetch all items
    @FetchRequest(entity: Item.entity(), sortDescriptors: [], animation: .default)
    private var items: FetchedResults<Item>
    
    // call function to filter list according to filter settings
    var filteredList: [Item] {
        filterItems()
    }
    
    // bool to track if item is long pressed to change name of navigation bar item
    @State private var itemIsLongPressed : Bool = false
    
    // bool for sheet
    @State private var showPackedItemsView : Bool = false
    
    // variabels for delete alert
    @State private var toBeDeleted: IndexSet?
    @State private var showingDeleteAlert : Bool = false
    
    @State private var editMode : Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    if (editMode) {
                        Section {
                            addButton
                        }
                    }
                    Section {
                        ForEach(filteredList) { item in
                            ListRowView(item: item, editMode: editMode)
                        }
                        .onDelete(perform: { indexSet in
                            for index in indexSet {
                                let item = filteredList[index]
                                viewContext.delete(item)
                                do {
                                    try viewContext.save()
                                } catch let error {
                                    print("Error: \(error)")
                                }
                            }
                        })
                    }
                }                
                Spacer()
                Button(action: {
                    showPackedItemsView = true
                }, label: {
                    PackedCountView()
                })
                .disabled(editMode)
                .sheet(isPresented: $showPackedItemsView) {
                    PackedItemsView()
                        .environment(\.managedObjectContext, self.viewContext)
                }
            } // end of VStack
            .navigationBarTitle("Things to pack", displayMode: .automatic)
            .navigationBarItems(leading: filterButton
                                    .disabled(editMode),
                                trailing: editButton)
        } // end of navigation view
    } // end of body
    
    // filter button
    private var filterButton: some View {
        return AnyView(NavigationLink(
            destination: FilterView(),
            label: {
                Text("Filter")
            }))
    }
    
    private var editButton: some View {
        return AnyView(Button(action: {
            editMode.toggle()
        }, label: {
            Text(editMode ? "Done" : "Edit")
        }))
    }
    
    // add item button
    private var addButton: some View {
        return AnyView(NavigationLink(
                        destination: AddEditItemView(item: nil),
                        label: {
                            HStack {
                                Text("New item")
                                    .foregroundColor(.blue)
                            }
                        }))
    }
        
    // function to get a filtered list according to filter settings
    private func filterItems() -> [Item] {
        var filteredItems: [Item]
        
        // if no filters have been chosen, display all except packed items
        if(!degreeIsChecked && !tentIsChecked && !cabinIsChecked && !hotelIsChecked) {
            filteredItems = items.filter { item in
                (!item.isPacked)
            }
            return filteredItems
            
            // only degrees
        } else if (degreeIsChecked && !tentIsChecked && !cabinIsChecked && !hotelIsChecked) {
            filteredItems = items.filter { item in
                ((item.whenDegrees && checkTemp(itemMin: item.minDegree, itemMax: item.maxDegree) && !item.isPacked)
                    || (!item.whenDegrees && item.whenTypeOfStay && !item.isPacked)
                    || (item.alwaysDisplayed && !item.isPacked))
            }
            return filteredItems
            
            // only tent
        } else if (!degreeIsChecked && tentIsChecked && !cabinIsChecked && !hotelIsChecked) {
            filteredItems = items.filter { item in
                ((item.whenTent && !item.isPacked) ||
                    (!item.whenTypeOfStay && item.whenDegrees && !item.isPacked) ||
                    (item.alwaysDisplayed && !item.isPacked))
            }
            return filteredItems
        
            // only cabin
        } else if (!degreeIsChecked && !tentIsChecked && cabinIsChecked && !hotelIsChecked) {
            filteredItems = items.filter { item in
                ((item.whenCabin && !item.isPacked) ||
                    (!item.whenTypeOfStay && item.whenDegrees && !item.isPacked) ||
                    (item.alwaysDisplayed && !item.isPacked))
            }
            return filteredItems
            
            //only hotel
        } else if (!degreeIsChecked && !tentIsChecked && !cabinIsChecked && hotelIsChecked) {
            filteredItems = items.filter { item in
                ((item.whenHotel && !item.isPacked) ||
                    (!item.whenTypeOfStay && item.whenDegrees && !item.isPacked) ||
                    (item.alwaysDisplayed && !item.isPacked))
            }
            return filteredItems
            
            // tent + cabin
        } else if (!degreeIsChecked && tentIsChecked && cabinIsChecked && !hotelIsChecked) {
            filteredItems = items.filter { item in
                (((item.whenTent || item.whenCabin) && !item.isPacked) ||
                    (!item.whenTypeOfStay && item.whenDegrees && !item.isPacked) ||
                    (item.alwaysDisplayed && !item.isPacked))
            }
            return filteredItems
            
            // tent + hotel
        } else if (!degreeIsChecked && tentIsChecked && !cabinIsChecked && hotelIsChecked) {
            filteredItems = items.filter { item in
                (((item.whenTent || item.whenHotel) && !item.isPacked) ||
                    (!item.whenTypeOfStay && item.whenDegrees && !item.isPacked) ||
                    (item.alwaysDisplayed && !item.isPacked))
            }
            return filteredItems
        
            // cabin + hotel
        } else if (!degreeIsChecked && !tentIsChecked && cabinIsChecked && hotelIsChecked) {
            filteredItems = items.filter { item in
                (((item.whenCabin || item.whenHotel) && !item.isPacked) ||
                    (!item.whenTypeOfStay && item.whenDegrees && !item.isPacked) ||
                    (item.alwaysDisplayed && !item.isPacked))
            }
            return filteredItems
            
            // tent + cabin + hotel
        } else if (!degreeIsChecked && tentIsChecked && cabinIsChecked && hotelIsChecked) {
            filteredItems = items.filter { item in
                (((item.whenTent || item.whenCabin || item.whenHotel) && !item.isPacked) ||
                    (!item.whenTypeOfStay && item.whenDegrees && !item.isPacked) ||
                    (item.alwaysDisplayed && !item.isPacked))
            }
            return filteredItems
            
            // degrees + tent
        } else if (degreeIsChecked && tentIsChecked && !cabinIsChecked && !hotelIsChecked) {
            filteredItems = items.filter { item in
                ((item.whenDegrees && checkTemp(itemMin: item.minDegree, itemMax: item.maxDegree) && item.whenTent && !item.isPacked) ||
                    (item.whenDegrees && checkTemp(itemMin: item.minDegree, itemMax: item.maxDegree) && !item.whenTypeOfStay && !item.isPacked) ||
                    (!item.whenDegrees && item.whenTent && !item.isPacked) ||
                    (item.alwaysDisplayed && !item.isPacked))
            }
            return filteredItems
            
            // degrees + cabin
        } else if (degreeIsChecked && !tentIsChecked && cabinIsChecked && !hotelIsChecked) {
            filteredItems = items.filter { item in
                ((item.whenDegrees && checkTemp(itemMin: item.minDegree, itemMax: item.maxDegree) && item.whenCabin && !item.isPacked) ||
                    (item.whenDegrees && checkTemp(itemMin: item.minDegree, itemMax: item.maxDegree) && !item.whenTypeOfStay && !item.isPacked) ||
                    (!item.whenDegrees && item.whenCabin && !item.isPacked) ||
                    (item.alwaysDisplayed && !item.isPacked))
            }
            return filteredItems
            
            // degrees + hotel
        } else if (degreeIsChecked && !tentIsChecked && !cabinIsChecked && hotelIsChecked) {
            filteredItems = items.filter { item in
                ((item.whenDegrees && checkTemp(itemMin: item.minDegree, itemMax: item.maxDegree) && item.whenHotel && !item.isPacked) ||
                    (item.whenDegrees && checkTemp(itemMin: item.minDegree, itemMax: item.maxDegree) && !item.whenTypeOfStay && !item.isPacked) ||
                    (!item.whenDegrees && item.whenHotel && !item.isPacked) ||
                    (item.alwaysDisplayed && !item.isPacked))
            }
            return filteredItems
            
            // degree + tent + cabin
        } else if (degreeIsChecked && tentIsChecked && cabinIsChecked && !hotelIsChecked) {
            filteredItems = items.filter { item in
                ((item.whenDegrees && checkTemp(itemMin: item.minDegree, itemMax: item.maxDegree) && (item.whenTent || item.whenCabin) && !item.isPacked) ||
                    (item.whenDegrees && checkTemp(itemMin: item.minDegree, itemMax: item.maxDegree) && !item.whenTypeOfStay && !item.isPacked) ||
                    (!item.whenDegrees && (item.whenTent || item.whenCabin) && !item.isPacked) ||
                    (item.alwaysDisplayed && !item.isPacked))
            }
            return filteredItems
            
            //degree + tent + hotel
        } else if (degreeIsChecked && tentIsChecked && !cabinIsChecked && hotelIsChecked) {
            filteredItems = items.filter { item in
                ((item.whenDegrees && checkTemp(itemMin: item.minDegree, itemMax: item.maxDegree) && (item.whenTent || item.whenHotel) && !item.isPacked) ||
                    (item.whenDegrees && checkTemp(itemMin: item.minDegree, itemMax: item.maxDegree) && !item.whenTypeOfStay && !item.isPacked) ||
                    (!item.whenDegrees && (item.whenTent || item.whenHotel) && !item.isPacked) ||
                    (item.alwaysDisplayed && !item.isPacked))
            }
            return filteredItems
            
            // degree + cabin + hotel
        } else if (degreeIsChecked && !tentIsChecked && cabinIsChecked && hotelIsChecked) {
            filteredItems = items.filter { item in
                ((item.whenDegrees && checkTemp(itemMin: item.minDegree, itemMax: item.maxDegree) && (item.whenCabin || item.whenHotel) && !item.isPacked) ||
                    (item.whenDegrees && checkTemp(itemMin: item.minDegree, itemMax: item.maxDegree) && !item.whenTypeOfStay && !item.isPacked) ||
                    (!item.whenDegrees && (item.whenCabin || item.whenHotel) && !item.isPacked) ||
                    (item.alwaysDisplayed && !item.isPacked))
            }
            return filteredItems
            
            //degree + tent + cabin + hotel
        } else if (degreeIsChecked && tentIsChecked && cabinIsChecked && hotelIsChecked) {
            filteredItems = items.filter { item in
                ((item.whenDegrees && checkTemp(itemMin: item.minDegree, itemMax: item.maxDegree) && (item.whenTent || item.whenCabin || item.whenHotel) && !item.isPacked) ||
                    (item.whenDegrees && checkTemp(itemMin: item.minDegree, itemMax: item.maxDegree) && !item.whenTypeOfStay && !item.isPacked) ||
                    (!item.whenDegrees && (item.whenTent || item.whenCabin || item.whenHotel) && !item.isPacked) ||
                    (item.alwaysDisplayed && !item.isPacked))
            }
            return filteredItems
        }
        return [Item]()
    } // end of filterItems function
    
    private func checkTemp(itemMin: Int64, itemMax: Int64) -> Bool {
        for itemDegree in itemMin...itemMax {
            for filterDegree in minDegree...maxDegree {
                if itemDegree == filterDegree {
                    return true
                }
            }
        }
        return false
    }
    
} // end of view

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            //.colorScheme(.dark)
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
 
 ** alwaysDisplayed == true
 */
