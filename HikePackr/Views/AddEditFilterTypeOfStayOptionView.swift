//
//  AddEditFilterTypeOfStayOptionView.swift
//  HikePackr
//
//  Created by Emelie on 2021-02-25.
//

import SwiftUI

struct AddEditFilterTypeOfStayOptionView: View {
    
    var text: String
    var isChecked: Bool
    
    init(text: String, isChecked: Bool) {
        self.text = text
        self.isChecked = isChecked
    }
        
    var body: some View {
        HStack {
            Text(text)
            Spacer()
            Image(systemName: isChecked ? "xmark.square" : "square")
        }
    }
}

//HStack {
//    Text("Tent")
//    Spacer()
//    Image(systemName: tentIsChecked ? "xmark.square" : "square")
//
//}
//.onTapGesture {
//    tentIsChecked.toggle()
//}

//struct AddEditFilterTypeOfStayOptionView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddEditFilterTypeOfStayOptionView()
//    }
//}
