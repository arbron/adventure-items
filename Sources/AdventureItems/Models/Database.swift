//
//  Database.swift
//  
//
//  Created by Jeff Hitchcock on 2021-06-10.
//

struct Database {
    var adventures: [Adventure]
    var series: [Series]

    init() throws {
        adventures = try Adventure.load()
        series = try Series.load()

        Series.collate(&series, with: &adventures)
    }
}
