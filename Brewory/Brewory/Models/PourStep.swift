//
//  PourStep.swift
//  Brewory
//
//  Created by Nam Jun Lee on 5/18/25.
//

import Foundation

struct PourStep: Identifiable, Codable, Equatable {
    let id: UUID
    var time: TimeInterval  // 해당 단계가 시작되는 시간 (초)
    var targetWater: Double // 이 시점까지 누적된 물의 양 (g)

    init(id: UUID = UUID(), time: TimeInterval, targetWater: Double) {
        self.id = id
        self.time = time
        self.targetWater = targetWater
    }
}
