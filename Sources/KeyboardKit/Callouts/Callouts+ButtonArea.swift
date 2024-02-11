//
//  Callouts+ButtonArea.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-09-30.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import SwiftUI

public extension Callouts {
    
    /**
     This view is used to cover the parts of the button that
     was tapped or pressed to trigger the callout.
     */
    struct ButtonArea: View {
        
        /**
         Create an autocomplete toolbar item style.
         
         - Parameters:
           - frame: The button area frame.
           - style: The style to use, by default `.standard`.
         */
        public init(
            frame: CGRect,
            style: Style = .standard,
            isLeftCurveEnabled: Bool = true
        ) {
            self.frame = frame
            self.style = style
            self.isLeftCurveEnabled = isLeftCurveEnabled
        }
        
        public typealias Style = KeyboardStyle.Callout
        
        private let frame: CGRect
        private let style: Style
        private let isLeftCurveEnabled: Bool

        public var body: some View {
            HStack(alignment: .top, spacing: 0) {
                if isLeftCurveEnabled {
                    calloutCurve.rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                } else {
                    Rectangle()
                        .frame(width: curveSize.width, height: curveSize.height)
                        .foregroundColor(.clear)
                }
                buttonBody
                calloutCurve
            }
        }
    }
}

private extension Callouts.ButtonArea {
    
    var backgroundColor: Color { style.backgroundColor }
    
    var cornerRadius: CGFloat { style.buttonCornerRadius }
    
    var curveSize: CGSize { style.curveSize }
    
    var buttonBody: some View {
        CustomRoundedRectangle(bottomLeft: cornerRadius, bottomRight: cornerRadius)
            .foregroundColor(backgroundColor)
            .frame(width: frame.size.width, height: frame.size.height)
    }
    
    var calloutCurve: some View {
        Callouts.Curve()
            .frame(width: curveSize.width, height: curveSize.height)
            .foregroundColor(backgroundColor)
    }
}

struct Callouts_ButtonArea_Previews: PreviewProvider {
    
    static var previews: some View {
        Callouts.ButtonArea(
            frame: CGRect(x: 0, y: 0, width: 50, height: 50),
            style: .standard
        )
        .padding(30)
        .background(Color.gray)
        .cornerRadius(20)
    }
}
