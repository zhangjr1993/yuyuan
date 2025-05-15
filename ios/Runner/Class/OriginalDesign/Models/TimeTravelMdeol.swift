//
//  TimeTravelMdeol.swift
//  Runner
//
//  Created by Bolo on 2025/3/26.
//

import UIKit

/// 修炼等级
enum OwnStrengthType: Int, SmartCodable {
    init() {
        self = .unowned
    }
    case unowned
    case origin = 1
    case lianqi = 2
    case lianqihouqi = 3
    case zhuji = 4
    case zhujihouqi = 5
    case jindan = 6
    case jindanhouqi = 7
    case yuanyin = 8
    case yuanyinhouqi = 9
    case huashen = 10
    case heti = 11
    case dujie = 12
    case xianren = 13
}

/// 运算符
enum OperatorType: Int, SmartCodable {
    init() {
        self = .unowned
    }
    case unowned
    // 加上level
    case add = 1
    // 减去level
    case subt = 2
    // 归0，重来
    case rzero = 3
    // 结束
    case gameover = 4
}

struct TimeTravelListModel: SmartCodable {
    var list: [TimeTravelModel] = []
}

struct TimeTravelModel: SmartCodable {
    var tid = 0
    var audioFile = ""
    var audioLength = 0
    var title = ""
    var cover = ""
    var ownStrength: OwnStrengthType = .unowned
    var backgroud = ""
    var progress: [TimeTravelItemModel] = []
}

struct TimeTravelItemModel: SmartCodable {
    var pid = 0
    var title = ""
    var jumpNext = false
    var A: TimeTravelSelectedModel?
    var B: TimeTravelSelectedModel?
    var C: TimeTravelSelectedModel?
}

struct TimeTravelSelectedModel: SmartCodable {
    var des = ""
    var result: [TimeSelectedResultModel] = []
}

struct TimeSelectedResultModel: SmartCodable {
    var operatorType: OperatorType = .unowned
    var level = 0
    var vo = ""
    
    static func mappingForKey() -> [SmartKeyTransformer]? {
        [
            CodingKeys.operatorType <--- "operator"
        ]
    }
}

extension TimeTravelListModel {
    static func loadTravelInfo() -> TimeTravelListModel? {
        guard let url = Bundle.main.url(forResource: "TimeTravel", withExtension: "geojson"),
              let data = try? Data(contentsOf: url),
              let jsonDic = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        
        return TimeTravelListModel.deserialize(from: jsonDic)
    }
    
    static func currentLevelDesc(_ level: OwnStrengthType, tid: Int) -> String {
        switch tid {
        case 1: // 修仙模式
            switch level {
            case .unowned:
                return "凡人"
            case .origin:
                return "先天"
            case .lianqi:
                return "练气期"
            case .lianqihouqi:
                return "练气后期大圆满"
            case .zhuji:
                return "筑基"
            case .zhujihouqi:
                return "筑基后期大圆满"
            case .jindan:
                return "金丹"
            case .jindanhouqi:
                return "金丹后期大圆满"
            case .yuanyin:
                return "元婴"
            case .yuanyinhouqi:
                return "元婴后期大圆满"
            case .huashen:
                return "化神期"
            case .heti:
                return "合体期"
            case .dujie:
                return "渡劫期"
            case .xianren:
                return "仙人"
            }
        case 2: // 创业模式
            let value = level.rawValue
            switch value {
            case 0:
                return "待业青年"
            case 1...3:
                return "创业新手"
            case 4...5:
                return "小有成就"
            case 6...8:
                return "企业高管"
            case 9...10:
                return "上市公司CEO"
            default:
                return "商业大亨"
            }
        case 3: // 荒岛求生模式
            let value = level.rawValue
            switch value {
            case 0:
                return "遇难者"
            case 1...3:
                return "初级求生者"
            case 4...5:
                return "熟练求生者"
            case 6...8:
                return "野外专家"
            case 9...10:
                return "生存大师"
            default:
                return "荒野之王"
            }
        default:
            return "未知"
        }
    }
}
