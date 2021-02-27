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
                categoryCircle
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
    private var categoryCircle: some View {
        return Image(systemName: "circle.fill")
            .foregroundColor(getColor())
            .font(.caption)
    }
    
    private func getColor() -> Color {
        if (item.category == "Other") {
            return .blue
        } else if (item.category == "Clothing and footwear") {
            return .green
        } else if (item.category == "Emergency and first aid") {
            return .red
        } else if (item.category == "Food and water") {
            return .purple
        } else if (item.category == "Health and hygiene") {
            return .pink
        } else if (item.category == "Hiking gear") {
            return .gray
        } else if (item.category == "Navigation") {
            return .orange
        } else if (item.category == "Personal items") {
            return .yellow
        }
        return .black
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
