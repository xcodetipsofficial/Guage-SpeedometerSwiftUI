//
//  ContentView.swift
//  SpeedometerSwiftUI
//
//  Created by Kyle Wilson on 2020-10-17.
//


//Full tutorial on Medium by Prafulla Singh: https://medium.com/dev-genius/ios-how-create-gaugeview-speedometer-using-swiftui-ae46778e042f

import SwiftUI

struct ContentView: View {
    
    @State private var value = 25.0 //default value of spedometer
    
    var body: some View {
        ZStack {
            Color.black
            VStack {
                GaugeView(coveredRadius: 225, maxValue: 100, steperSplit: 10, value: $value)
                Slider(value: $value, in: 0...100, step: 1)
                    .padding(.horizontal, 20)
                    .accentColor(.orange)
                HStack {
                    Spacer()
                    Button(action: {
                        self.value = 0
                    }) {
                        Text("Zero")
                            .bold()
                    }.foregroundColor(.green)
                    Spacer()
                    Button(action: {
                        self.value = 100
                    }) {
                        Text("Max")
                            .bold()
                    }.foregroundColor(.red)
                    Spacer()
                }
            }
        }.edgesIgnoringSafeArea(.all)
    }
}

struct Needle: Shape { //create the red needle shape
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.height / 2))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        return path
    }
}

struct GaugeView: View {
    
    func colorMix(percent: Int) -> Color {
        let p = Double(percent) //get the percent and convert it into a double for decimals (accuracy)
        let tempG = (100.0 - p) / 100 //the more value p is, the less green will be applied to the mix
        let g: Double = tempG < 0 ? 0 : tempG //apply the green value when tempG is not less than 0
        let tempR = 1 + (p - 100.0) / 100.0 //the less value p is, the more red will be applied to the mix
        let r: Double = tempR < 0 ? 0 : tempR //apply the red value when tempR is not less than 0
        return Color.init(red: r, green: g, blue: 0) //create the color mix with the obtained values
    }
    
    func tick(at tick: Int, totalTicks: Int) -> some View { //this function sets the small and big dashes just like in a spedometer
        let percent = (tick * 100) / totalTicks //get percent for color mix
        let startAngle = coveredRadius / 2 * -1
        let stepper = coveredRadius / Double(totalTicks) //if its 0 to 100 in steps of 10, it will show 0, 10, 20, 30, ... 100.
        let rotation = Angle.degrees(startAngle + stepper * Double(tick)) //get the rotation angle in degrees using the start angle, stepper, and tick
        return VStack { //a VStack that rotates its views with rotationEffect
                   Rectangle()
                    .fill(colorMix(percent: percent))
                       .frame(width: tick % 2 == 0 ? 5 : 3,
                              height: tick % 2 == 0 ? 20 : 10) //flip between small and big dash
                   Spacer()
           }.rotationEffect(rotation)
    }
    
    func tickText(at tick: Int, text: String) -> some View {
        let percent = (tick * 100) / tickCount //get percentage for applying color mix
        let startAngle = coveredRadius / 2 * -1 + 90 //get start angle for reference on rotation
        let stepper = coveredRadius / Double(tickCount) //amount of space between each text values
        let rotation = startAngle + stepper * Double(tick) //calculate rotation
        return Text(text).foregroundColor(colorMix(percent: percent)).rotationEffect(.init(degrees: -1 * rotation), anchor: .center).offset(x: -110, y: 0).rotationEffect(Angle.degrees(rotation)) //set the text values with the corresponding rotation value and offset the x value so they are aligned with the dashes
    }
    
    let coveredRadius: Double //0 - 360°
    let maxValue: Int
    let steperSplit: Int
    
    private var tickCount: Int {
        return maxValue / steperSplit
    }
    
    @Binding var value: Double
    
    var body: some View {
        ZStack {
            Text("\(value, specifier: "%0.0f")") //for spedometer value shown in middle
                .font(.system(size: 40, weight: Font.Weight.bold))
                .foregroundColor(Color.orange)
                .offset(x: 0, y: 40)
            ForEach(0..<tickCount * 2 + 1) { tick in //this loop sets the dashes
                self.tick(at: tick,
                          totalTicks: self.tickCount * 2)
            }
            ForEach(0..<tickCount + 1) { tick in //this loop sets the text values like: 0, 10, 20, ... around the spedometer
                self.tickText(at: tick, text: "\(self.steperSplit * tick)")
            }
            Needle() //red needle directing the speed
                .fill(Color.red)
                .frame(width: 140, height: 6)
                .offset(x: -70, y: 0)
                .rotationEffect(.init(degrees: getAngle(value: value)), anchor: .center) //get the value set in the main view
                .animation(.linear)
            Circle() //rotation point of needle, simple circle
                .frame(width: 20, height: 20)
                .foregroundColor(.red)
        }.frame(width: 300, height: 300, alignment: .center) //frame of guage
    }
    
    func getAngle(value: Double) -> Double { //function that gets the angle with the specified value and sets it to the needle
        return (value / Double(maxValue)) * coveredRadius - coveredRadius / 2 + 90
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
