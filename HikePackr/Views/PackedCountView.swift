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
            Image(systemName: "bag.fill")
                .font(.largeTitle)
                .foregroundColor(.accentColor)
                .overlay(
                    Text("\(items.count)")
                        .foregroundColor(.white)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .baselineOffset(-5)
                    , alignment: .center
                )
        }
        
    }
}

struct PackedCountView_Previews: PreviewProvider {
    static var previews: some View {
        PackedCountView()
    }
}
