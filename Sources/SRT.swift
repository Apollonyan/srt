//
//  SRT.swift
//  srt
//
//  Created by Zhiyu Zhu on 7/9/17.
//  Copyright © 2017-2019 ApolloZhu. MIT License.
//

import Foundation

public struct SRT {
    public var body = [Subtitle]()
}

extension SRT {
    /// Initialize a srt with its content.
    ///
    /// - Parameter content: content of a srt file.
    public init(content: String) {
        /// Indicating what the next piece of information is
        enum ParsingState { case index, time, content }

        let lineSeparator: String
        if content.contains("\r\n") {
            lineSeparator = "\r\n"
        } else if content.contains("\r") {
            lineSeparator = "\r"
        } else {
            lineSeparator = "\n"
        }

        for part in content.components(separatedBy: "\(lineSeparator)\(lineSeparator)").lazy {
            var state = ParsingState.index
            var index: Int? = nil
            var time: String? = nil
            var content = [String]()
            for line in part.components(separatedBy: lineSeparator) {
                let line = line.trimmingCharacters(in: .whitespacesAndNewlines)
                switch state {
                case .index:
                    if let i = Int(line) {
                        index = i
                        state = .time
                    }
                case .time:
                    if line.contains("-->") {
                        time = line
                        state = .content
                    }
                case .content:
                    if line.count > 0 {
                        content.append(line)
                    }
                }
            }
            if let i = index, let t = time, content.count > 0 {
                body.append(Subtitle(index: i, time: t, content: content))
            }
        }
    }
}

extension SRT {
    /// Initialize a srt with the url, nil if file not found.
    ///
    /// - Parameters:
    ///   - url: url to the srt file.
    ///   - enc: encoding of the file content.
    /// - Throws: an NSError object that describes the problem.
    public init(url: URL, stringEncoding enc: String.Encoding = .utf8) throws {
        let content = try String(contentsOf: url, encoding: enc)
        self.init(content: content)
    }

    /// Initialize a srt with its path, nil if file not found.
    ///
    /// - Parameters:
    ///   - path: path to the srt file.
    ///   - enc: encoding of the file content.
    /// - Throws: an NSError object that describes the problem.
    public init(path: String, stringEncoding enc: String.Encoding = .utf8) throws {
        let content = try String(contentsOfFile: path, encoding: enc)
        self.init(content: content)
    }
}

extension SRT: CustomStringConvertible {
    /// Convert back to what it would be like in a .srt file.
    public var description: String {
        return body.map({ $0.description }).joined(separator: "\n")
    }
}

