//
//  ContentView.swift
//  FilterVisuals
//
//  Created by iRny on 11/2/21.
//

import Foundation
import SwiftUI
import Accelerate
import PhotosUI

struct ContentView: View {
    @EnvironmentObject var polynomialTransformer: PolynomialTransformer
    @State private var selectNewImage = false
    @State var showRedCurveView = false
    @State var showGreenCurveView = false
    @State var showBlueCurveView = false

    var body: some View {
        VStack {
            Image(decorative: polynomialTransformer.outputImage, scale: 1)
                .resizable()
                .scaledToFit()
                .padding()
                .frame(minWidth: 600, minHeight: 400)
            //            Text(imageLabel)
            //                .font(.footnote)
            //        }
            HStack {
                Button(action:{
                    self.showRedCurveView = true
                    self.showGreenCurveView = false
                    self.showBlueCurveView = false
                }) {
                    Text("Red")
                    //                    .fontWeight(.thin)
                        .foregroundColor(.red)
                    //                    .padding()
                    //                    .overlay(
                    //                        RoundedRectangle(cornerRadius: 50)
                    //                            .stroke(Color.red, lineWidth: 0.2)
                    //                    )
                }
                Button(action:{
                    self.showGreenCurveView = true
                    self.showRedCurveView = false
                    self.showBlueCurveView = false
                }) {
                    Text("Green")
                        .foregroundColor(.green)
                }
                Button(action:{
                    self.showBlueCurveView = true
                    self.showGreenCurveView = false
                    self.showRedCurveView = false
                }) {
                    Text("Blue")
                        .foregroundColor(.blue)
                }
                
            }
            ZStack {
                // Red
                if(self.showRedCurveView){
                    PolynomialEditor(
                        title: "Red",
                        color: .red,
                        values: $polynomialTransformer.redValues,
                        coefficients: $polynomialTransformer.redCoefficients)
                }
                else if(self.showGreenCurveView){
                    // Green
                    PolynomialEditor(
                        title: "Green",
                        color: .green,
                        values: $polynomialTransformer.greenValues,
                        coefficients: $polynomialTransformer.greenCoefficients)
                }
                else{
                    // Blue
                    PolynomialEditor(
                        title: "Blue",
                        color: .blue,
                        values: $polynomialTransformer.blueValues,
                        coefficients: $polynomialTransformer.blueCoefficients)
                }
            }
        }
        .frame(minWidth: 400)
        .padding()
    }

    var imageLabel: String {
        let model = polynomialTransformer.sourceImageFormat.colorSpace.takeRetainedValue().name
        return
            "\(model ?? "[unknown color space]" as CFString) | " +
        "\(Int(polynomialTransformer.sourceImage!.size.width)) x " +
            "\(Int(polynomialTransformer.sourceImage!.size.height))"
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(PolynomialTransformer())
    }
}

