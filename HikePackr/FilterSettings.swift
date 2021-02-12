//
//  FilterSettings.swift
//  HikePackr
//
//  Created by Emelie on 2021-02-12.
//

import Foundation
import Combine

class FilterSettings : ObservableObject {
    
    @Published var degreeIsChecked: Bool {
        didSet {
            UserDefaults.standard.set(degreeIsChecked, forKey: "degree")
        }
    }
    @Published var minDegree: Int {
        didSet {
            UserDefaults.standard.set(minDegree, forKey: "minDegree")
        }
    }
    @Published var maxDegree: Int {
        didSet {
            UserDefaults.standard.set(maxDegree, forKey: "maxDegree")
        }
    }
    @Published var tentIsChecked: Bool {
        didSet {
            UserDefaults.standard.set(tentIsChecked, forKey: "tent")
        }
    }
    @Published var cabinIsChecked: Bool {
        didSet {
            UserDefaults.standard.set(cabinIsChecked, forKey: "cabin")
        }
    }
    @Published var hotelIsChecked: Bool {
        didSet {
            UserDefaults.standard.set(hotelIsChecked, forKey: "hotel")
        }
    }
    @Published var numberOfDays: Int {
        didSet {
            UserDefaults.standard.set(numberOfDays, forKey: "days")
        }
    }
    
    init() {
        self.degreeIsChecked = UserDefaults.standard.object(forKey: "degree") as? Bool ?? false
        self.minDegree = UserDefaults.standard.object(forKey: "minDegree") as? Int ?? 10
        self.maxDegree = UserDefaults.standard.object(forKey: "maxDegree") as? Int ?? 20
        self.tentIsChecked = UserDefaults.standard.object(forKey: "tent") as? Bool ?? false
        self.cabinIsChecked = UserDefaults.standard.object(forKey: "cabin") as? Bool ?? false
        self.hotelIsChecked = UserDefaults.standard.object(forKey: "hotel") as? Bool ?? false
        self.numberOfDays = UserDefaults.standard.object(forKey: "days") as? Int ?? 1
    }
}
