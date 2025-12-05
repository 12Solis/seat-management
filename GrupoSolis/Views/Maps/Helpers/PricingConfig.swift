//
//  PricingConfig.swift
//  GrupoSolis
//
//  Created by Leonardo Solís on 02/12/25.
//

import Foundation

struct SectionPricingConfig: Identifiable{
    let id = UUID()
    let sectionIndex: Int
    let sectionName: String
    var appliesToAllRows: Bool
    var unifiedPrice: Double = 0.0
    var rows: [RowPricingConfig]
}

struct RowPricingConfig: Identifiable{
    let id = UUID()
    let rowIndex: Int
    let label: String
    var price: Double = 0.0
}
