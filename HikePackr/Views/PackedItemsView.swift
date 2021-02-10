//
//  PackedItemsView.swift
//  HikePackr
//
//  Created by Emelie on 2021-02-09.
//

import SwiftUI

struct PackedItemsView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(entity: Item.entity(), sortDescriptors: [], predicate: NSPredicate(format: "isPacked == true"))
    
    private var items: FetchedResults<Item>
    
    var body: some View {
        NavigationView {
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
                        Image(systemName: "bag.badge.minus")
                            .onTapGesture {
                                item.isPacked = false
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
            }
        }
    }
}

struct PackedItemsView_Previews: PreviewProvider {
    static var previews: some View {
        PackedItemsView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
