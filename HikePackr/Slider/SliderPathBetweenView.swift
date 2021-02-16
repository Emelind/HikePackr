//
//  SliderPathBetweenView.swift
//  HikePackr
//
//  Created by Emelie on 2021-02-14.
//

import SwiftUI

struct SliderPathBetweenView: View {
    
    @ObservedObject var slider: CustomSlider
    
    var body: some View {
        Path { path in
            path.move(to: slider.lowHandle.currentLocation)
            path.addLine(to: slider.highHandle.currentLocation)
        }
        .stroke(Color.green, lineWidth: slider.lineWidth)
    }
}

//struct SliderPathBetweenView_Previews: PreviewProvider {
//    static var previews: some View {
//        SliderPathBetweenView()
//    }
//}
