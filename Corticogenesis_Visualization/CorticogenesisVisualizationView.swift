//
//MIT License
//
//Copyright © 2025 Cong Le
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.
//
//  CorticogenesisVisualizationView.swift
//  Corticogenesis_Visualization
//
//  Created by Cong Le on 6/28/25.
//
//

import SwiftUI
import Combine

// MARK: - Data Models

enum LayerType: CaseIterable {
    case piaMater
    case preplate
    case marginalZone
    case subplate
    case corticalPlate
    case layerVI, layerV, layerIV, layerIII, layerII
    
    var data: LayerData {
        switch self {
        case .piaMater:
            return LayerData(name: "Pia Mater", color: .gray.opacity(0.3), description: "Outermost membrane")
        case .preplate:
            return LayerData(name: "Preplate", color: .yellow.opacity(0.6), description: "First structure, contains pioneer neurons")
        case .marginalZone:
            return LayerData(name: "Marginal Zone (future Layer I)", color: .blue.opacity(0.5), description: "Top layer, contains Cajal-Retzius cells")
        case .subplate:
            return LayerData(name: "Subplate (transient)", color: .orange.opacity(0.6), description: "Establishes early connections")
        case .corticalPlate:
            return LayerData(name: "Cortical Plate", color: .purple.opacity(0.2), description: "Forms layers II-VI")
        case .layerVI:
            return LayerData(name: "Layer VI", color: .purple.opacity(0.9), description: "First cortical layer to form")
        case .layerV:
            return LayerData(name: "Layer V", color: .purple.opacity(0.8), description: "Second cortical layer to form")
        case .layerIV:
            return LayerData(name: "Layer IV", color: .purple.opacity(0.7), description: "Third cortical layer to form")
        case .layerIII:
            return LayerData(name: "Layer III", color: .purple.opacity(0.6), description: "Fourth cortical layer to form")
        case .layerII:
            return LayerData(name: "Layer II", color: .purple.opacity(0.5), description: "Final cortical layer to form")
        }
    }
}

struct LayerData {
    let name: String
    let color: Color
    let description: String
}

// MARK: - State Management

// ✅ FIX: Added `Comparable` conformance.
// The compiler can now automatically compare two `CorticogenesisStage` instances
// based on their Int rawValue.
enum CorticogenesisStage: Int, CaseIterable, Comparable {
    static func < (lhs: CorticogenesisStage, rhs: CorticogenesisStage) -> Bool {
        return true
    }
    
    case initial = 0
    case preplateFormed
    case plateSplitting
    case layerVIFormation
    case layerVFormation
    case layerIVFormation
    case layerIIIFormation
    case layerIIFormation
    case finalStructure
    
    var title: String {
        switch self {
        case .initial: return "Stage 1: Initial State"
        case .preplateFormed: return "Stage 2: Preplate Formation"
        case .plateSplitting: return "Stage 3: Cortical Plate Emergence"
        case .layerVIFormation: return "Stage 4: Inside-Out Layering (Layer VI)"
        case .layerVFormation: return "Stage 5: Inside-Out Layering (Layer V)"
        case .layerIVFormation: return "Stage 6: Inside-Out Layering (Layer IV)"
        case .layerIIIFormation: return "Stage 7: Inside-Out Layering (Layer III)"
        case .layerIIFormation: return "Stage 8: Inside-Out Layering (Layer II)"
        case .finalStructure: return "Stage 9: Final Six-Layered Structure"
        }
    }
    
    var description: String {
        switch self {
        case .initial:
            return "The process begins with progenitor cells in the ventricular zone (bottom, not shown) below the Pia Mater."
        case .preplateFormed:
            return "The first-born 'pioneer' neurons migrate to form the Preplate, the earliest cortical structure."
        case .plateSplitting:
            return "A new wave of migrating neurons arrives, splitting the Preplate into the Marginal Zone (top) and the Subplate (bottom). The Cortical Plate forms between them."
        case .layerVIFormation:
            return "The 'inside-out' rule begins. Neurons migrate into the Cortical Plate to form Layer VI, the deepest layer."
        case .layerVFormation:
            return "New neurons migrate past Layer VI to form the more superficial Layer V."
        case .layerIVFormation:
            return "The process continues as neurons migrate past existing layers to establish Layer IV."
        case .layerIIIFormation:
            return "Layer III is formed by another wave of migrating neurons."
        case .layerIIFormation:
            return "The final wave of neurons forms Layer II, completing the main cortical layers."
        case .finalStructure:
            return "The mature cortex is established. Layer I (from the Marginal Zone) is on top, followed by Layers II-VI. The Subplate is a transient layer that will eventually disappear."
        }
    }
}

// MARK: - Reusable UI Component

struct CorticalLayerShape: View {
    let layerData: LayerData
    
    var body: some View {
        HStack {
            Text(layerData.name)
                .font(.system(.footnote, design: .monospaced, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal)
            Spacer()
        }
        .frame(height: 40)
        .background(layerData.color)
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
    }
}

// MARK: - Main SwiftUI View

struct CorticogenesisVisualizationView: View {
    
    @State private var currentStage: CorticogenesisStage = .initial
    @State private var stageIndex: Double = 0.0
    @State private var isPlaying: Bool = false
    @State private var timer: AnyCancellable?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Corticogenesis: Building the Cortex")
                    .font(.largeTitle).fontWeight(.bold).multilineTextAlignment(.center)
                Text(currentStage.title)
                    .font(.title2).fontWeight(.semibold).foregroundColor(.secondary)
                Text(currentStage.description)
                    .font(.body).multilineTextAlignment(.center).padding(.horizontal)
                    .frame(height: 100, alignment: .top)

                VStack(spacing: 4) {
                    CorticalLayerShape(layerData: LayerType.piaMater.data)
                    VStack(spacing: 4) {
                        // All `if` statements now work correctly because the enum is Comparable.
                        if currentStage >= .plateSplitting {
                            CorticalLayerShape(layerData: LayerType.marginalZone.data)
                                .transition(.opacity.combined(with: .scale))
                        }
                        
                        if currentStage >= .plateSplitting {
                            ZStack(alignment: .bottom) {
                                CorticalLayerShape(layerData: LayerType.corticalPlate.data)
                                VStack(spacing: 4) {
                                    Spacer()
                                    if currentStage >= .layerIIFormation {
                                        CorticalLayerShape(layerData: LayerType.layerII.data).transition(.move(edge: .top).combined(with: .opacity))
                                    }
                                    if currentStage >= .layerIIIFormation {
                                        CorticalLayerShape(layerData: LayerType.layerIII.data).transition(.move(edge: .top).combined(with: .opacity))
                                    }
                                    if currentStage >= .layerIVFormation {
                                        CorticalLayerShape(layerData: LayerType.layerIV.data).transition(.move(edge: .top).combined(with: .opacity))
                                    }
                                    if currentStage >= .layerVFormation {
                                        CorticalLayerShape(layerData: LayerType.layerV.data).transition(.move(edge: .top).combined(with: .opacity))
                                    }
                                    if currentStage >= .layerVIFormation {
                                        CorticalLayerShape(layerData: LayerType.layerVI.data).transition(.move(edge: .top).combined(with: .opacity))
                                    }
                                }
                                .padding(4)
                            }
                            .frame(height: 280)
                            .transition(.opacity)
                        }
                        
                        if currentStage == .preplateFormed {
                            CorticalLayerShape(layerData: LayerType.preplate.data)
                                .transition(.opacity.combined(with: .scale))
                                .frame(height: 288)
                        }
                        
                        if currentStage >= .plateSplitting {
                            CorticalLayerShape(layerData: LayerType.subplate.data)
                                .transition(.opacity.combined(with: .scale))
                        }
                    }
                    .frame(minHeight: 330)
                }
                .padding(.horizontal)
                
                VStack {
                    Slider(value: $stageIndex, in: 0...Double(CorticogenesisStage.allCases.count - 1), step: 1)
                        .padding(.horizontal)
                    HStack(spacing: 15) {
                        Button(action: resetAnimation) { Image(systemName: "backward.end.fill") }.disabled(currentStage == .initial)
                        Button(action: goBackStage) { Image(systemName: "backward.fill") }.disabled(currentStage == .initial)
                        Button(action: togglePlayPause) { Image(systemName: isPlaying ? "pause.fill" : "play.fill") }.font(.title)
                        Button(action: advanceStage) { Image(systemName: "forward.fill") }.disabled(currentStage == .finalStructure)
                        Button(action: goToEnd) { Image(systemName: "forward.end.fill") }.disabled(currentStage == .finalStructure)
                    }
                    .font(.title2).buttonStyle(.bordered).tint(.blue)
                }
                .padding()
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
            .padding()
        }
        .animation(.easeInOut(duration: 0.8), value: currentStage)
        .onChange(of: stageIndex) {
            currentStage = CorticogenesisStage(rawValue: Int(round(stageIndex))) ?? .initial
        }
        .onDisappear(perform: stopTimer)
    }
    
    // Control Logic functions unchanged...
    private func advanceStage() { if let nextStageRawValue = CorticogenesisStage(rawValue: currentStage.rawValue + 1)?.rawValue { stageIndex = Double(nextStageRawValue) } }
    private func goBackStage() { if let prevStageRawValue = CorticogenesisStage(rawValue: currentStage.rawValue - 1)?.rawValue { stageIndex = Double(prevStageRawValue) } }
    private func goToEnd() { stageIndex = Double(CorticogenesisStage.allCases.count - 1) }
    private func resetAnimation() { isPlaying = false; stopTimer(); stageIndex = 0.0 }
    private func togglePlayPause() { isPlaying.toggle(); if isPlaying { if currentStage == .finalStructure { stageIndex = 0.0 }; startTimer() } else { stopTimer() } }
    private func startTimer() { stopTimer(); timer = Timer.publish(every: 2.0, on: .main, in: .common).autoconnect().sink { _ in if currentStage == .finalStructure { isPlaying = false; stopTimer() } else { advanceStage() } } }
    private func stopTimer() { timer?.cancel(); timer = nil }
}

// MARK: - Preview Provider

struct CorticogenesisVisualizationView_Previews: PreviewProvider {
    static var previews: some View {
        CorticogenesisVisualizationView()
    }
}
