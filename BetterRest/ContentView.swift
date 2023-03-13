//
//  ContentView.swift
//  BetterRest
//
//  Created by Maximilian Berndt on 2023/03/12.
//

import CoreML
import SwiftUI

struct ContentView: View {
    
    @State private var wakeUp = ContentView.defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 2
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    private static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    DatePicker(
                        "Please enter a time",
                        selection: $wakeUp,
                        displayedComponents: .hourAndMinute
                    )
                    .labelsHidden()
                } header: {
                    Text("When do you want to wake up?")
                }
                Section {
                    Stepper(
                        "\(sleepAmount.formatted()) hours",
                        value: $sleepAmount,
                        in: 4...12, step: 0.25
                    )
                } header: {
                    Text("Desired amount of sleep")
                }
                Section {
                    Picker("^[\(coffeeAmount + 1) cup](inflect: true)", selection: $coffeeAmount) {
                        ForEach(1..<21) {
                            Text("\($0)")
                        }
                    }
                } header: {
                    Text("Daily coffee intake")
                }
                Section {
                    Text("\(calculateBedtime().formatted(date: .omitted, time: .shortened))")
                        .font(.headline)
                } header: {
                    Text("Recommended Bedtime")
                }
            }
            .navigationTitle("BetterRest")
        }
    }
    
    private func calculateBedtime() -> Date {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hours = (components.hour ?? 0) * 60 * 60
            let minutes = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(
                wake: Double(hours + minutes),
                estimatedSleep: sleepAmount,
                coffee: Double(coffeeAmount)
            )
            let sleepTime = wakeUp - prediction.actualSleep
            return sleepTime
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
            showingAlert = true
        }
        return Date.now
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
