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

    @FetchRequest(entity: Item.entity(), sortDescriptors: [])
    
    private var items: FetchedResults<Item>
    
    @State var itemIsLongPressed = false
    
    @State var showFilterView = false

    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    HStack {
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
                            .padding(.trailing)
                    }
                }
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
            .listStyle(PlainListStyle())
            .navigationTitle("Things to pack")
            .navigationBarItems(leading: Button(action: {
                showFilterView = true
            }, label: {
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
            .sheet(isPresented: $showFilterView) {
                FilterView()
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
