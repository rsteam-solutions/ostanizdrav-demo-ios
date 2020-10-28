// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: internal/risk_level.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

/// This file is auto-generated, DO NOT make any changes here

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that you are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

enum SAP_Internal_RiskLevel: SwiftProtobuf.Enum {
  typealias RawValue = Int
  case unspecified // = 0
  case lowest // = 1
  case low // = 2
  case lowMedium // = 3
  case medium // = 4
  case mediumHigh // = 5
  case high // = 6
  case veryHigh // = 7
  case highest // = 8
  case UNRECOGNIZED(Int)

  init() {
    self = .unspecified
  }

  init?(rawValue: Int) {
    switch rawValue {
    case 0: self = .unspecified
    case 1: self = .lowest
    case 2: self = .low
    case 3: self = .lowMedium
    case 4: self = .medium
    case 5: self = .mediumHigh
    case 6: self = .high
    case 7: self = .veryHigh
    case 8: self = .highest
    default: self = .UNRECOGNIZED(rawValue)
    }
  }

  var rawValue: Int {
    switch self {
    case .unspecified: return 0
    case .lowest: return 1
    case .low: return 2
    case .lowMedium: return 3
    case .medium: return 4
    case .mediumHigh: return 5
    case .high: return 6
    case .veryHigh: return 7
    case .highest: return 8
    case .UNRECOGNIZED(let i): return i
    }
  }

}

#if swift(>=4.2)

extension SAP_Internal_RiskLevel: CaseIterable {
  // The compiler won't synthesize support with the UNRECOGNIZED case.
  static var allCases: [SAP_Internal_RiskLevel] = [
    .unspecified,
    .lowest,
    .low,
    .lowMedium,
    .medium,
    .mediumHigh,
    .high,
    .veryHigh,
    .highest,
  ]
}

#endif  // swift(>=4.2)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

extension SAP_Internal_RiskLevel: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "RISK_LEVEL_UNSPECIFIED"),
    1: .same(proto: "RISK_LEVEL_LOWEST"),
    2: .same(proto: "RISK_LEVEL_LOW"),
    3: .same(proto: "RISK_LEVEL_LOW_MEDIUM"),
    4: .same(proto: "RISK_LEVEL_MEDIUM"),
    5: .same(proto: "RISK_LEVEL_MEDIUM_HIGH"),
    6: .same(proto: "RISK_LEVEL_HIGH"),
    7: .same(proto: "RISK_LEVEL_VERY_HIGH"),
    8: .same(proto: "RISK_LEVEL_HIGHEST"),
  ]
}
