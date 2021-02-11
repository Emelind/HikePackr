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

    @FetchRequest(entity: Item.entity(), sortDescriptors: [], predicate: NSPredicate(format: "isPacked == false"))
    
    private var items: FetchedResults<Item>
    
    @State var itemIsLongPressed = false
    
    @State var showPackedItemsView = false
    
    @State private var toBeDeleted: IndexSet?
    @State var showingDeleteAlert = false

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(items) { item in
                        HStack {
                            // NEDAN SKA KALKYLERAS UTIFRÅN ANTAL DAGAR I FILTER
                            Text(String(Int(item.quantity.rounded(.up))))
                                .padding(.leading)
                            if let measurement = item.measurement {
                                Text(measurement)
                            }
                            if let name = item.name {
                                Text(name)
                            }
                            Spacer()
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
                    }
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
                            //AVMARKERA SOM TAPPED
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
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Things to pack")
            .navigationBarItems(leading: NavigationLink(destination: FilterView(), label: {
                    Text("Filter")
                }), trailing: itemIsLongPressed ? NavigationLink(
                                        destination: AddEditItemView(),
                                        label: {
                                            Text("Edit item")
                                        }) : NavigationLink(
                                        destination: AddEditItemView(),
                                        label: {
                                            Text("Add new item")
                                        }))
        }
    }
    
    private func deleteRow(at indexSet: IndexSet) {
        self.toBeDeleted = indexSet
        self.showingDeleteAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
