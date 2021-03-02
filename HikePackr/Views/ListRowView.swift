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
    
    init(item: Item, editMode: Bool) {
        self.item = item
        self.editMode = editMode
    }
    
    var body: some View {
        HStack {
            HStack {
                // circle with color of item category
                categoryCircle
                VStack {
                    HStack {
                        if let name = item.name {
                            Text(name.prefix(20))
                                   
                        }
                        Spacer()
                    }
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    HStack {
                        // call function calculateQuantity to get quantity based on number of days chosen in filter
                        Text(String(calculateQuantity(itemQuantity: item.quantity, perXNumberOfDays: item.perXNumberOfDays)))
                        if let measurement = item.measurement {
                            Text(measurement)
                        }
                        Spacer()
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
            Spacer()
            // if editMode = true, link to AddEditView
            if(editMode) {
                NavigationLink(destination: AddEditItemView(item: item)) {
                    Text("")
                }
                // else, display square to pack items
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
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .padding(10.0)
                })
            }
        }
    }
    
    // circle with color item category
    private var categoryCircle: some View {
        return Image(systemName: "circle.fill")
            .foregroundColor(getColor())
            .font(.caption)
            .overlay(Circle().stroke(Color.black, lineWidth: 1))
            .padding(.trailing)
            .shadow(radius: 2)
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
