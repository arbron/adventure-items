//
//  Markdowned.swift
//  
//
//  Created by Jeff Hitchcock on 2021-05-29.
//

import Ink
import Plot


public struct Markdowned: Component {
    static let parser = MarkdownParser()

    public var body: Component { node }
    private var node: Node<HTML.BodyContext>

    public init(_ string: String) {
        self.init(node: .raw(Self.parser.html(from: string)))
    }

    private init(node: Node<HTML.BodyContext>) {
        self.node = node
    }

    public func bold() -> Markdowned {
        Markdowned(node: .strong(node))
    }

    public func italic() -> Markdowned {
        Markdowned(node: .em(node))
    }
}
