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
    
    //@ObservedObject var filterSettings = FilterSettings()
    
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
    @State var itemIsLongPressed = false
    
    // bool for sheet
    @State var showPackedItemsView = false
    
    // variabels for delete alert
    @State private var toBeDeleted: IndexSet?
    @State var showingDeleteAlert = false
    
    
    var body: some View {
        
        NavigationView {
            VStack {
                List {
                    ForEach(filteredList) { item in
                        HStack {
                            // call function calculateQuantity to get quantity based on number of days chosen in filter
                            Text(String(calculateQuantity(itemQuantity: item.quantity, perXNumberOfDays: item.perXNumberOfDays)))
                            if let measurement = item.measurement {
                                Text(measurement)
                            }
                            if let name = item.name {
                                Text(name)
                            }
                            Spacer()
                            
                            // changes item from not packed to packed
                            Image(systemName: "bag.badge.plus")
                                .onTapGesture {
                                    item.isPacked = true
                                    do {
                                        try viewContext.save()
                                    } catch {
                                        let nsError = error as NSError
                                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                                    }
                                }
                                .padding(.trailing)
                        } // end of HStack
                    } // end of ForEach
                    .onDelete(perform: deleteRow)
                    .alert(isPresented: self.$showingDeleteAlert, content: {
                            Alert(title: Text("Delete this item?"), message: Text("Item will be deleted from your application."), primaryButton: .destructive(Text("Delete")) {
                                if let selfToBeDeleted = self.toBeDeleted {
                                    for index in selfToBeDeleted {
                                        let item = items[index]
                                        viewContext.delete(item)
                                        do {
                                            try viewContext.save()
                                        } catch let error {
                                            print("Error: \(error)")
                                        }
                                    }
                                    self.toBeDeleted = nil
                                }
                            }, secondaryButton: .cancel() {
                                self.toBeDeleted = nil
                            }
                            )})
                    .onTapGesture {
                        if (itemIsLongPressed) {
                            let newBool = false
                            itemIsLongPressed = newBool
                            //AVMARKERA SOM PRESSED
                        }
                    }
                    .onLongPressGesture(minimumDuration: 0.1) {
                        itemIsLongPressed = true
                        // MARKERA SOM PRESSED
                    }
                } // end of list
                Button(action: {
                    showPackedItemsView = true
                }, label: {
                    PackedCountView()
                })
                .sheet(isPresented: $showPackedItemsView) {
                    PackedItemsView()
                }
            } // end of VStack
            .listStyle(PlainListStyle())
            .navigationBarTitle("Things to pack", displayMode: .inline)
            .navigationBarItems(leading: NavigationLink(destination: FilterView(), label: {
                Image(systemName: "slider.horizontal.3")
            }), trailing: itemIsLongPressed ? NavigationLink(
                                        destination: AddEditItemView(),
                                        label: {
                                            Image(systemName: "pencil")
                                        }) : NavigationLink(
                                        destination: AddEditItemView(),
                                        label: {
                                            Image(systemName: "plus")
                                        }))
        } // end of list
    } // end of navigation view
    
    
    // function to get the item quantity based on number of days chosen in filter
    private func calculateQuantity(itemQuantity: Double, perXNumberOfDays: Int64) -> Int {
        if(perXNumberOfDays > 0) {
            let quantityDouble = (itemQuantity / Double(perXNumberOfDays))
            let perDayDouble = quantityDouble * Double(numberOfDays)
            return Int(perDayDouble.rounded(.up))
        } else {
            return Int(itemQuantity)
        }
    }
    
    // function to delete row / show alert
    private func deleteRow(at indexSet: IndexSet) {
        self.toBeDeleted = indexSet
        self.showingDeleteAlert = true
    }
    
    // function to get a filtered list according to filter settings
    private func filterItems() -> [Item] {
        var theseItems: [Item]
        if (tentIsChecked) {
             theseItems = items.filter { item in
                (item.whenTent)
            }
            return theseItems
        }
        return [Item]()
    }
} // end of view

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            //.colorScheme(.dark)
    }
}
