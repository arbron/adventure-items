//
//  File.swift
//  
//
//  Created by Jeff Hitchcock on 2021-09-29.
//

import Plot

extension ElementDefinitions {
    public enum ASection: ElementDefinition { public static var wrapper = Node.section }
}

public typealias ASection = ElementComponent<ElementDefinitions.ASection>
