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
    
    // fetch all items, sort by category
    @FetchRequest(entity: Item.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Item.category, ascending: true)], animation: .default)
    private var items: FetchedResults<Item>
    
    // call function to filter list according to filter settings
    var filteredList: [Item] {
        filterItems()
    }
    
    // bool to track if item is long pressed to change name of navigation bar item
    @State private var itemIsLongPressed : Bool = false
    
    // bool for sheet
    @State private var showPackedItemsView : Bool = false
    
    // variables for action sheet
    @State private var showActionSheet : Bool = false
    @State private var indexSetDelete : IndexSet?
    
    // variabels for delete alert
    @State private var toBeDeleted: IndexSet?
    @State private var showingDeleteAlert : Bool = false
    
    // enable editing items / adding new item
    @State private var editMode : Bool = false
    
    var body: some View {
        
        NavigationView {
            VStack {
                Form {
                    // shows addButton if editmMode = true
                    if (editMode) {
                        Section {
                            addButton
                        }
                    }
                    Section {
                        // shows all items in filtered list
                        ForEach(filteredList) { item in
                            ListRowView(item: item, editMode: editMode)
                        }
                        // delete function with action sheet confirmation
                        .onDelete(perform: { indexSet in
                            indexSetDelete = indexSet
                            showActionSheet = true
                        })
                    }
                }
                Spacer()
                packedSheetButton
            } // end of VStack
            .actionSheet(isPresented: $showActionSheet, content: {
                deleteActionSheet
            })
            .navigationBarTitleDisplayMode(.inline)
//            .navigationTitle("Things to pack")
            .navigationBarItems(leading: filterButton.disabled(editMode),
                                trailing: editButton)
            .onDisappear() {
                editMode = false
            }
            .sheet(isPresented: $showPackedItemsView) {
                PackedItemsView()
                    .environment(\.managedObjectContext, self.viewContext)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Packing List")
                        .font(.title2)
                }
            }
        }// end of navigation view
    } // end of body
    
    // filter button
    private var filterButton: some View {
        return AnyView(NavigationLink(
            destination: FilterView(),
            label: {
                Text("Filter")
                    .font(.body)
            }))
    }
    
    // edit button
    private var editButton: some View {
        return AnyView(Button(action: {
            editMode.toggle()
        }, label: {
                Text(editMode ? "Done" : "Edit")
                    .font(.body)
        }))
    }
    
    // button to show sheet with packed items
    private var packedSheetButton: some View {
        return AnyView(Button(action: {
            showPackedItemsView = true
        }, label: {
            PackedCountView()
                .padding(.bottom)
        }).disabled(editMode))
    }
    
    // action sheet for delete confirmation
    private var deleteActionSheet: ActionSheet {
        return ActionSheet(title: Text("Are you sure you want to delete this item?"), message: Text("There is no undo"), buttons: [
            .destructive(Text("Delete")) {
                if let indexSet = indexSetDelete {
                    for index in indexSet {
                        let item = filteredList[index]
                        viewContext.delete(item)
                        do {
                            try viewContext.save()
                        } catch let error {
                            print("Error: \(error)")
                        }
                    }
                }
            },
            .cancel()
        ])
    }
    
    // add item button
    private var addButton: some View {
        return AnyView(NavigationLink(
                        destination: AddEditItemView(item: nil),
                        label: {
                            HStack {
                                Image(systemName: "plus")
                                Text("New item")
                            }
                            .foregroundColor(.accentColor)
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
        Group {
            ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            ContentView().preferredColorScheme(.dark).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
