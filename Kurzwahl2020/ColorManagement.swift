//
//  KurzwahlView.swift
//  Kurzwahl2020
//
//  Created by Vogel, Andreas on 30.10.19.
//  Copyright © 2019 Vogel, Andreas. All rights reserved.
//
// all colors have to be defiend in the Assets catalog. The names
// of these colors can be found in AssetColorList: [String]


import Foundation
// 3.3.2020 new data model

struct palette: Identifiable, Hashable {
    var id = UUID()
    var name: String      // Human readable name
    var thumbnail: String // name of thumbnail image in assets
    var thumbnailDarkMode: String // name of thumbnail image for dark mode
    var colors : [String]
}


// the color names refer to the items in Asset.xcassets
let ColorPaletteSummer: [String] = [
    "OrangeFF9500", "Darkblue00398E", "RedFF3A2D",  "RedAC193D",
    "Green008A00", "OrangeD24726", "Green00A600", "Blue2E8DEF",
    "Darkgrey6E6E6E", "lightGreyAEAEAE", "DarkViolet5856D6", "grey8E8E8E"]

let ColorPaletteDarkPink: [String] = [
    "E69D95", "E07260", "C83773", "B8A89F",
    "665A5C", "C64247", "B4938C", "EAA598",
    "9B7983", "B897BB", "885D8D", "742E34"]

let ColorPaletteForest: [String] = [
    "5b6c48","afc1a7",
    "415740","6b8760",
    "213522","593649",
    "7e5ef2","b2e2be",
    "5d8c60","bfe28b",
    "c189d9","2b220f"]

let ColorPaletteBlue: [String] = [
    "Blue003C76","Blue003C76",
    "Blue00417F","Blue00417F",
    "Blue00488C","Blue00488C",
    "Blue004F99","Blue004F99",
    "Blue0055A6","Blue0055A6",
    "Blue005CB2","Blue005CB2"]

let ColorPaletteGreen: [String] = [
    "Green004D00","Green004D00",
    "Green005900","Green005900",
    "Green006600","Green006600",
    "Green007300","Green007300",
    "Green007F00","Green007F00",
    "Green008D00","Green008D00"]

let ColorPaletteRed: [String] = [
    "Red4D0000","Red4D0000",
    "Red590000","Red590000",
    "Red660000","Red660000",
    "Red730000","Red730000",
    "Red7F0000","Red7F0000",
    "Red8C0000","Red8C0000"]


// constants: Names of the palettes
let c_summerTime : String = "Summer Time"
let c_darkPink : String = "Dark Pink"
let c_red : String = "Red"

// constants: file names for thumbnails in Light & Dark Mode
let c_tn_summerTime_lm = "Standard Light Mode"
let c_tn_darkPink_lm = "DarkPink Light Mode"
let c_tn_red_lm = "Red Light Mode"


class ColorManagement : ObservableObject {
    var allPalettes = [palette]()
    struct userSelectedPalettes {
        var p0 : String
        var p1 : String
        var p2 : String
    }
    
    var userScreen = [palette]()
    
    var userSelection : userSelectedPalettes = userSelectedPalettes(p0: "", p1: "", p2: "")
    
    init() {
        
        print("ColorManagemen init")
        allPalettes.append(palette(name: c_summerTime, thumbnail: "Standard Light Mode", thumbnailDarkMode: "", colors:ColorPaletteRed))
        allPalettes.append(palette(name: c_darkPink, thumbnail: "DarkPink Light Mode", thumbnailDarkMode: "", colors:ColorPaletteRed))
        allPalettes.append(palette(name: c_red
            , thumbnail: "Red Light Mode", thumbnailDarkMode: "", colors:ColorPaletteRed))
        
        //TODO: read from file
        userScreen.append(self.allPalettes[0])
        userScreen.append(self.allPalettes[1])
        userScreen.append(self.allPalettes[2])
        
    }
    
    
    func getThumbnailName(withIndex: Int) -> String {
        return userScreen[withIndex].thumbnail
    }
    
    func getAllThumbnails() -> [palette] {
        return allPalettes
    }
    
    
    func getUserSelectedPalette(withIndex: Int) -> String {
        return userScreen[withIndex].name
    }
    
    func setPalette(withIndex: Int, name: String) {
        for p in allPalettes {
            if p.name == name {
                userScreen[withIndex] = p
            }
        }
      
    }
} //class





// for a given number return the corresponding color
//extension Color {
//    static func appColor(_ id: Int) -> Color? {
//        var name: String
//        if id < globalMaxTileNumber {
//            name = AssetColorList[id]
//        }
//        else {
//            name = "Black"
//        }
//        return Color.init(name, bundle: nil)
//    }
//}

