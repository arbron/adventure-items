//
//  Disclosure.swift
//  
//
//  Created by Jeff Hitchcock on 2021-05-29.
//

import Plot


public struct Disclosure: Component {
    public var summary: Component
    public var details: Component

    public init(summary: Component, details: Component) {
        self.summary = summary
        self.details = details
    }

    public var body: Component {
        Node<HTML.BodyContext>.details(
            .summary(summary.convertToNode()),
            details.convertToNode()
        )
    }
}
