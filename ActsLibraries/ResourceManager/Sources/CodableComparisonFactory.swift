//
//  File.swift
//  
//
//  Created by Paul Fechner on 2/13/20.
//

import Foundation

//MARK: - CodableComparisonFactory

// **NOTE** code had to be duplicated to avoid availability errors.

//#if canImport(Combine)
//import Combine
//
//@available(iOS 13.0, *)
//public class CodableComparisonFactory<DecoderType: TopLevelDecoder, T: Decodable> where DecoderType.Input == Data {
//
////    private let decoder: DecoderType
////    private let comparisonAction: (T, T) -> Bool
//    init(decoder: DecoderType) {
////        self.decoder = decoder
////        self.comparisonAction = comparisonAction
//    }
//
//    func compare(_ leftData: Data, _ rightData: Data) -> Bool {
//        return false
////        do {
////            let leftItem = try decoder.decode(T.self, from: leftData)
////            let rightItem = try decoder.decode(T.self, from: rightData)
////            return comparisonAction(leftItem, rightItem)
////        } catch {
////            print(error)
////            return false
////        }
//    }
//}
//
//#else

public class CodableComparisonFactory<DecoderType: TopLevelDecoder, T: Decodable> where DecoderType.Input == Data {

    private let decoder: DecoderType
    private let comparisonAction: (T, T) -> Bool
    init(decoder: DecoderType, comparisonAction: @escaping (T, T) -> Bool) {
        self.decoder = decoder
        self.comparisonAction = comparisonAction
    }

    func compare(_ leftData: Data, _ rightData: Data) -> Bool {
        do {
            let leftItem = try decoder.decode(T.self, from: leftData)
            let rightItem = try decoder.decode(T.self, from: rightData)
            return comparisonAction(leftItem, rightItem)
        } catch {
            print(error)
            return false
        }
    }
}


// MARK: - TopLevelDecoder
public protocol TopLevelDecoder {
    associatedtype Input
    func decode<T>(_ type: T.Type, from: Self.Input) throws -> T where T : Decodable
}

extension JSONDecoder: TopLevelDecoder { }
extension PropertyListDecoder: TopLevelDecoder {}


//#endif



