//
//  ListRowView.swift
//  HikePackr
//
//  Created by Emelie on 2021-02-21.
//

import SwiftUI

struct ListRowView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    var item: Item
    var editMode: Bool
    @AppStorage("days") var numberOfDays : Int = 1
    
    var body: some View {
        HStack {
            HStack {
//                Image(systemName: "circle.fill")
//                    .foregroundColor(.green)
                VStack {
                    HStack {
                        if let name = item.name {
                            Text(name.prefix(20))
                                .font(.headline)
                        }
                        Spacer()
                    }
                    HStack {
                        // call function calculateQuantity to get quantity based on number of days chosen in filter
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
                }
            }
            Spacer()
            if(editMode) {
                NavigationLink(destination: AddEditItemView(item: item)) {
                    Text("")
                }
            } else {
                // changes item from not packed to packed
                Button(action: {
                    item.isPacked = true
                    do {
                        try viewContext.save()
                    } catch {
                        let nsError = error as NSError
                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                    }
                }, label: {
                    Image(systemName: "square")
                        .padding(10.0)
                })
            }
        }
    }
    // function to get the item quantity based on number of days chosen in filter
    private func calculateQuantity(itemQuantity: Double, perXNumberOfDays: Int64) -> Int {
        if(perXNumberOfDays > 0) {
            let doublePerXNumberOfDays : Double = Double(perXNumberOfDays)
            let quantityDouble : Double = (itemQuantity / doublePerXNumberOfDays)
            let doubleNumberOfDays : Double = Double(numberOfDays)
            let perDayDouble : Double = quantityDouble * doubleNumberOfDays
            let doubleRoundedUp : Double = perDayDouble.rounded(.up)
            return Int(doubleRoundedUp)
        } else {
            return Int(itemQuantity)
        }
    }
}

//struct ListRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        ListRowView()
//    }
//}
