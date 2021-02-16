//
//  SliderHandleView.swift
//  HikePackr
//
//  Created by Emelie on 2021-02-14.
//

import SwiftUI

struct SliderHandleView: View {
    
    @ObservedObject var handle: SliderHandle
    
    var body: some View {
        Circle()
            .frame(width: handle.diameter, height: handle.diameter)
            .foregroundColor(.white)
            .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 0)
            .scaleEffect(handle.onDrag ? 1.3 : 1)
            .contentShape(Rectangle())
            .position(x: handle.currentLocation.x, y: handle.currentLocation.y)
    }
}

//struct SliderHandleView_Previews: PreviewProvider {
//    static var previews: some View {
//        SliderHandleView()
//    }
//}
