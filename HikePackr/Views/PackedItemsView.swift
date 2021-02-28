//
//  PackedItemsView.swift
//  HikePackr
//
//  Created by Emelie on 2021-02-09.
//

import SwiftUI

struct PackedItemsView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @Environment(\.presentationMode) var presentationMode
    
    // fetch all items that with attribute isPacked == true
    @FetchRequest(entity: Item.entity(), sortDescriptors: [], predicate: NSPredicate(format: "isPacked == true"))
    private var items: FetchedResults<Item>
    
    // track changes in user default, days, for updating item quantity text
    @AppStorage("days") var numberOfDays : Int = 1
    
    var body: some View {
        List {
            // displays empty bag and cancel button
            HStack {
                clearAllButton
                Spacer()
                cancelButton
            }
            .padding(.vertical)
            
            // displays all packed items
            ForEach(items) { item in
                HStack {
                    VStack {
                        HStack {
                            if let name = item.name {
                                Text(name.prefix(20))
                                    .font(.headline)
                            }
                            Spacer()
                        }
                        HStack {
                            Text(String(calculateQuantity(itemQuantity: item.quantity, perXNumberOfDays: item.perXNumberOfDays)))
                                .font(.caption)
                                .foregroundColor(Color.gray)
                            if let measurement = item.measurement {
                                Text(measurement)
                                    .font(.caption)
                                    .foregroundColor(Color.gray)
                            }
                            Spacer()
                        }
                    } // end of VStack
                    Spacer()
                    Button(action: {
                        item.isPacked = false
                        do {
                            try viewContext.save()
                        } catch {
                            let nsError = error as NSError
                            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                        }
                    }, label: {
                        Image(systemName: "checkmark.square")
                            .foregroundColor(.blue)
                            .padding(10.0)
                    })
                } // end of HStack
            } // end of ForEach
        } // end of List
    } // end of body
    
    
    // cancel button
    private var cancelButton: some View {
        return Button(action: {
            cancel()
        }, label: {
            Text("Cancel")
                .foregroundColor(.blue)
                .fontWeight(.bold)
        })
    }
    
    // cancel function
    private func cancel() {
        presentationMode.wrappedValue.dismiss()
    }
    
    // clear all button
    private var clearAllButton: some View {
        return Button(action: {
            clearAll()
        }, label: {
            Text("Empty bag")
                .foregroundColor(.red)
        })
    }
    
    // clear all items from packed items view function
    private func clearAll() {
        withAnimation {
            for item in items {
                if (item.isPacked) {
                    item.isPacked.toggle()
                }
            }
            if viewContext.hasChanges {
                do {
                    try viewContext.save()
                } catch {
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
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
