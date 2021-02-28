//
//  PackedCountView.swift
//  HikePackr
//
//  Created by Emelie on 2021-02-11.
//

import SwiftUI

struct PackedCountView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    // fetch all items where isPacked = true
    @FetchRequest(entity: Item.entity(), sortDescriptors: [], predicate: NSPredicate(format: "isPacked == true"))
    private var items: FetchedResults<Item>
    
    var body: some View {
        HStack {
            Text("Packed items ( \(items.count) )")
            Image(systemName: "bag.fill")
        }
    }
}

struct PackedCountView_Previews: PreviewProvider {
    static var previews: some View {
        PackedCountView()
    }
}
