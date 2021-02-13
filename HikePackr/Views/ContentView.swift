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
    
    @ObservedObject var filterSettings = FilterSettings()
    @AppStorage("days") var numberOfDays : Int = 1
    
    
    // fetch all items that are not packed. Will be changed to fetch items that fit in to the filter criteria selected in FilterView
    @FetchRequest(entity: Item.entity(), sortDescriptors: [], predicate: NSPredicate(format: "isPacked == false")) private var items: FetchedResults<Item>
    
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
                    ForEach(items) { item in
                        HStack {
                            //UPPDATERAS EJ SOM DEN SKA
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
                        }
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
                }
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
    
    private func calculateQuantity(itemQuantity: Double, perXNumberOfDays: Int16) -> Int {
        if(perXNumberOfDays > 0) {
            let quantityDouble = (itemQuantity / Double(perXNumberOfDays))
            print(quantityDouble * Double(numberOfDays))
            let perDayDouble = quantityDouble * Double(numberOfDays)
            return Int(perDayDouble.rounded(.up))
        } else {
            print(Int(itemQuantity))
            return Int(itemQuantity)
        }
    }
    
    private func deleteRow(at indexSet: IndexSet) {
        self.toBeDeleted = indexSet
        self.showingDeleteAlert = true
    }
    
} // end of view

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
