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
    
    // track changes in user default, days, for updating item quantity text
    @AppStorage("days") var numberOfDays : Int = 1
    
    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    HStack {
                        Text(String(calculateQuantity(itemQuantity: item.quantity, perXNumberOfDays: item.perXNumberOfDays)))
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
}

struct PackedItemsView_Previews: PreviewProvider {
    static var previews: some View {
        PackedItemsView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
