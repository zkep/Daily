//
//  BlobView.swift
//  Daily
//
//  Created by kasoly on 2022/4/17.
//

import SwiftUI

struct BlobView: View {
    @State var appear = false
    
    var body: some View {
        TimelineView(.animation) { timeline in
            let now = timeline.date.timeIntervalSinceReferenceDate
            let angle = Angle.degrees(now.remainder(dividingBy: 5) * 60)
            let x = cos(angle.radians)
            let angle2 = Angle.degrees(now.remainder(dividingBy: 6) * 10)
            let x2 = cos(angle2.radians)
            
            Canvas { context, size in
                context.fill(path(in: CGRect(x: 0, y: 0, width: size.width, height: size.height),x: x, x2: x2), with: .linearGradient(Gradient(colors: [.pink,.blue]), startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 400, y: 400)))
            }
            .frame(width: 400, height: 414)
            .rotationEffect(.degrees(appear ? 360 : 30))
        }
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: true)) {
                appear = true
            }
        }
    }
    
    func path(in rect: CGRect, x: Double, x2: Double) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.99576*width, y: 0.53053*height))
        path.addCurve(to: CGPoint(x: 0.51271*width, y: height), control1: CGPoint(x: 0.99576*width, y: 0.74344*height), control2: CGPoint(x: 0.70227*width, y: height*x2))
        path.addCurve(to: CGPoint(x: 0, y: 0.34733*height), control1: CGPoint(x: 0.32316*width*x, y: height*x2), control2: CGPoint(x: 0, y: 0.56023*height))
        path.addCurve(to: CGPoint(x: 0.82203*width, y: 0), control1: CGPoint(x: 0, y: 0.13442*height*x2), control2: CGPoint(x: 0.63248*width, y: 0))
        path.addCurve(to: CGPoint(x: 0.99576*width, y: 0.53053*height), control1: CGPoint(x: 1.01159*width, y: 0), control2: CGPoint(x: 0.99576*width, y: 0.31763*height))
        path.closeSubpath()
        return path
    }
}

struct BlobView_Previews: PreviewProvider {
    static var previews: some View {
        BlobView()
    }
}


