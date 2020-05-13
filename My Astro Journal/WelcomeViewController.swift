//
//  FirstViewController.swift
//  My Astro Journal
//
//  Created by Koso Suzuki on 3/30/19.
//  Copyright © 2019 Koso Suzuki. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import SwiftKeychainWrapper
import MessageUI

let MessierTargets = ["M1", "M2", "M3", "M4", "M5", "M6", "M7", "M8", "M9", "M10", "M11", "M12", "M13", "M14", "M15", "M16", "M17", "M18", "M19", "M20", "M21", "M22", "M23", "M24", "M25", "M26", "M27", "M28", "M29", "M30", "M31", "M32", "M33", "M34", "M35", "M36", "M37", "M38", "M39", "M40", "M41", "M42", "M43", "M44", "M45", "M46", "M47", "M48", "M49", "M50", "M51", "M52", "M53", "M54", "M55", "M56", "M57", "M58", "M59", "M60", "M61", "M62", "M63", "M64", "M65", "M66", "M67", "M68", "M69", "M70", "M71", "M72", "M73", "M74", "M75", "M76", "M77", "M78", "M79", "M80", "M81", "M82", "M83", "M84",  "M85", "M86", "M87", "M88", "M89", "M90", "M91", "M92", "M93", "M94", "M95", "M96", "M97", "M98", "M99", "M100", "M101", "M102", "M103", "M104", "M105", "M106", "M107", "M108", "M109", "M110"]
let NGCTargets = ["NGC104", "NGC246", "NGC281", "NGC292", "NGC457", "NGC869", "NGC884", "NGC1499", "NGC1501", "NGC1502", "NGC1535", "NGC1977", "NGC2024", "NGC2070", "NGC2080", "NGC2237", "NGC2244", "NGC2264", "NGC2359", "NGC2360", "NGC2362", "NGC2392", "NGC2440", "NGC3242", "NGC3372", "NGC3532", "NGC3628", "NGC4565", "NGC4567", "NGC4568", "NGC4631", "NGC4656", "NGC4676", "NGC4755", "NGC5128", "NGC5139", "NGC5466", "NGC5474", "NGC5907", "NGC6334", "NGC6369", "NGC6388", "NGC6541", "NGC6543", "NGC6723", "NGC6741", "NGC6752", "NGC6781", "NGC6826", "NGC6888", "NGC6946", "NGC6960", "NGC6974", "NGC6992", "NGC7000", "NGC7009", "NGC7023", "NGC7293", "NGC7380", "NGC7635", "NGC7662"]
let ICTargets = ["IC59", "IC63", "IC405", "IC417", "IC434", "IC443", "IC1318", "IC1396", "IC1795", "IC1805", "IC1848", "IC2118", "IC2177", "IC2391", "IC2602", "IC2944", "IC4592", "IC5067", "IC5070", "IC5146"]
let SharplessTargets = ["SH2-129", "SH2-157", "SH2-240", "SH2-68", "SH2-136"]
let OthersTargets = ["Milkyway", "JU1", "ARP188", "XSS J16271-2423", "OU4"]
let GalaxyTargets = ["M31", "M32", "M33", "M49", "M51", "M58", "M59", "M60", "M61", "M63", "M64", "M65", "M66", "M74", "M77", "M81", "M82", "M83", "M84", "M85", "M86", "M87", "M88", "M89", "M90", "M91", "M94", "M95", "M96", "M98", "M99", "M100", "M101", "M102", "M104", "M105", "M106", "M108", "M109", "M110", "NGC292", "NGC3628", "NGC4565", "NGC4567", "NGC4568", "NGC4631", "NGC4656", "NGC4676", "NGC5128", "NGC5474", "NGC5907", "NGC6946", "Milkyway", "ARP188"]
let NebulaTargets = ["M1", "M8", "M16", "M17", "M20", "M27", "M42", "M43", "M57", "M76", "M78", "M97", "NGC246", "NGC281", "NGC1499", "NGC1501", "NGC1535", "NGC1977", "NGC2024", "NGC2080", "NGC2237", "NGC2244", "NGC2264", "NGC2359", "NGC2392", "NGC2440","NGC3242", "NGC3372", "NGC6334", "NGC6369", "NGC6543", "NGC6741", "NGC6781", "NGC6826", "NGC6888", "NGC6960", "NGC6974", "NGC6992", "NGC7000", "NGC7009", "NGC7023", "NGC7293", "NGC7380", "NGC7635", "NGC7662", "IC59", "IC63", "IC405", "IC417", "IC434", "IC443", "IC1318", "IC1396", "IC1795", "IC1805", "IC1848", "IC2118", "IC2177", "IC2944", "IC4592", "IC5067", "IC5070", "IC5146", "SH2-68", "SH2-129", "SH2-136", "SH2-157", "SH2-240", "JU1", "XSS J16271-2423", "OU4"]
let ClusterTargets = ["M2", "M3", "M4", "M5", "M6", "M7", "M9", "M10", "M11", "M12", "M13", "M14", "M15", "M18", "M19", "M21", "M22", "M23", "M24", "M25", "M26", "M28", "M29", "M30", "M34", "M35", "M36", "M37", "M38", "M39", "M41", "M44", "M45", "M46", "M47", "M48", "M50", "M52", "M53", "M54", "M55", "M56", "M62", "M67", "M68", "M69", "M70", "M71", "M72", "M75", "M79", "M80", "M92", "M93", "M103", "M107", "NGC104", "NGC457", "NGC869", "NGC884", "NGC1502", "NGC2360", "NGC2362", "NGC3532", "NGC4755", "NGC5139", "NGC5466", "NGC6388", "NGC6541", "NGC6723", "NGC6752", "IC2391", "IC2602"]
let PlanetTargets = ["Sun", "Moon", "Mercury", "Venus", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune"]

let doubleTargets = ["IC5067": "IC5070", "IC5070": "IC5067", "NGC869": "NGC884", "NGC884": "NGC869", "NGC2237": "NGC2244", "NGC2244": "NGC2237", "NGC4567": "NGC4568", "NGC4568": "NGC4567"]

let nicknames = ["crab": "M1", "butterfly": "NGC4568", "ptolemy's": "M7", "lagoon": "M8", "wild duck": "M11", "hercules": "M13", "great pegasus": "M15", "eagle": "M16", "omega": "M17", "trifid": "M20", "sagittarius star cloud": "M24", "dumbbell": "M27", "andromeda": "M31", "le gentil": "M32", "triangulum": "M33", "pinwheel cluster": "M36", "starfish": "M38", "double": "M40", "orion": "M42", "de mairan's": "M43", "beehive": "M44", "pleiades": "M45", "whirlpool": "M51", "summer rose": "M55", "ring": "M57", "sunflower": "M63", "black eye": "M64", "king cobra": "M67", "phantom": "M74", "little dumbbell": "M76", "cetus a": "M77", "bode's": "M81", "cigar": "M82", "southern pinwheel": "M83", "virgo a": "M87", "cat's eye galaxy": "M94", "owl": "NGC457", "coma pinwheel": "M99", "pinwheel galaxy": "M101", "sombrero": "M104", "surfboard": "M108", "edward's young": "M110", "ghost of cassiopeia": "IC63", "flaming": "IC405", "horsehead": "IC434", "jellyfish": "IC443", "elephant's trunk": "IC1396", "heart": "IC1805", "soul": "IC1848", "witch head": "IC2118", "pelican": "IC5067", "cocoon": "IC5146", "47 tucanae": "NGC104", "pacman": "NGC281", "small magellanic cloud": "NGC292", "double cluster in perseus": "NGC869", "california": "NGC1499", "runningman": "NGC1977", "flame": "NGC2024", "tarantula": "NGC2070", "rosette": "NGC2237", "cone": "NGC2264", "thor's helmet": "NGC2359", "eskimo": "NGC2392", "carina": "NGC3372", "hamburger": "NGC3628", "needle": "NGC4565", "whale": "NGC4631", "centaurus a": "NGC5128", "omega centauri": "NGC5139", "cat's eye nebula": "NGC6543", "crescent": "NGC6888", "fireworks": "NGC6946", "western veil": "NGC6960", "pickering's triangle": "NGC6974", "eastern veil": "NGC6992", "north america": "NGC7000", "iris": "NGC7023", "helix": "NGC7293", "wizard": "NGC7380", "bubble": "NGC7635", "oyster": "NGC1501", "flying bat": "SH2-129", "lobster claw": "SH2-157", "mice": "NGC4676", "cat's paw": "NGC6334", "spider": "IC417", "fishhead": "IC1795", "fish head": "IC1795", "seagull": "IC2177", "running chicken": "IC2944", "blue horsehead": "IC4592", "spaghetti": "SH2-240", "soap bubble": "JU1", "tadpole": "ARP188", "bow tie": "NGC2440", "saturn nebula": "NGC7009", "blue snowball": "NGC7662", "sadr region": "IC1318", "hockey stick": "NGC4656", "rho ophiuchi": "XSS J16271-2423", "kemble's cascade": "NGC1502", "football": "NGC3532", "jewel box": "NGC4755", "caroline's": "NGC2360", "tau canis majoris": "NGC2362", "omicron velorum": "IC2391", "southern pleiades": "IC2602", "skull": "NGC246", "little ghost": "NGC6369", "knife edge": "NGC5907", "phantom streak": "NGC6741", "ghost of the moon": "NGC6781", "blink": "NGC6826", "ghost head": "NGC2080", "cleopatra's eye": "NGC1535", "giant squid": "OU4", "ghost of jupiter": "NGC3242", "death eater": "SH2-68", "ghost": "SH2-136"]

let MessierConst = [1: "Taurus", 2: "Aquarius", 3: "Canes Venatici", 4: "Scorpius", 5: "Serpens", 6: "Scorpius", 7: "Scorpius", 8: "Sagittarius", 9: "Ophiuchus", 10: "Ophiuchus", 11: "Scutum", 12: "Ophiuchus", 13: "Hercules", 14: "Ophiuchus", 15: "Pegasus", 16: "Serpens", 17: "Sagittarius", 18: "Sagittarius", 19: "Ophiuchus", 20: "Sagittarius", 21: "Sagittarius", 22: "Sagittarius", 23: "Sagittarius", 24: "Sagittarius", 25: "Sagittarius", 26: "Scutum", 27: "Vulpecula", 28: "Sagittarius", 29: "Cygnus", 30: "Capricornus", 31: "Andromeda", 32: "Andromeda", 33: "Triangulum", 34: "Perseus", 35: "Gemini", 36: "Auriga", 37: "Auriga", 38: "Auriga", 39: "Cygnus", 40: "Ursa Major", 41: "Canis Major", 42: "Orion", 43: "Orion", 44: "Cancer", 45: "Taurus", 46: "Puppis", 47: "Puppis", 48: "Hydra", 49: "Virgo", 50: "Monoceros", 51: "Canes Venatici", 52: "Cassiopeia", 53: "Coma Berenices", 54: "Sagittarius", 55: "Sagittarius", 56: "Lyra", 57: "Lyra", 58: "Virgo", 59: "Virgo", 60: "Virgo", 61: "Virgo", 62: "Ophiuchus", 63: "Canes Venatici", 64: "Coma Berenices", 65: "Leo", 66: "Leo", 67: "Cancer", 68: "Hydra", 69: "Sagittarius", 70: "Sagittarius", 71: "Sagitta", 72: "Aquarius", 73: "Aquarius", 74: "Pisces", 75: "Sagittarius", 76: "Perseus", 77: "Cetus", 78: "Orion", 79: "Lepus", 80: "Scorpius", 81: "Ursa Major", 82: "Ursa Major", 83: "Hydra", 84: "Virgo",  85: "ComaBerenices", 86: "Virgo", 87: "Virgo", 88: "Coma Berenices", 89: "Virgo", 90: "Virgo", 91: "Coma Berenices", 92: "Hercules", 93: "Puppis", 94: "Canes Venatici", 95: "Leo", 96: "Leo", 97: "Ursa Major", 98: "ComaBerenices", 99: "Coma Berenices", 100: "Coma Berenices", 101: "Ursa Major", 102: "Draco", 103: "Cassiopeia", 104: "Virgo", 105: "Leo", 106: "Canes Venatici", 107: "Ophiuchus", 108: "Ursa Major", 109: "Ursa Major", 110: "Andromeda"]
let NGCConst = [104: "Tucana", 246: "Cetus", 281: "Cassiopeia", 292: "Tucana", 457: "Cassiopeia", 869: "Perseus", 884: "Perseus", 1499: "Perseus", 1501: "Camelopardalis", 1502: "Camelopardalis", 1535: "Eridanus", 1977: "Orion", 2024: "Orion", 2080: "Dorado", 2237: "Monoceros", 2244: "Monoceros", 2264: "Monoceros", 2359: "Canis Major", 2360: "Canis Major", 2362: "Canis Major", 2392: "Gemini", 2440: "Puppis", 3242: "Hydra", 3372: "Carina", 3532: "Carina", 3628: "Leo", 4565: "Coma Berenices", 4567: "Virgo", 4568: "Virgo", 4631: "Canes Venatici", 4656: "Canes Venatici", 4676: "Coma Berenices", 4755: "Crux", 5128: "Centaurus", 5139: "Centaurus", 5466: "Boötes", 5474: "Ursa Major", 5907: "Draco", 6334: "Scorpius", 6369: "Ophiuchus", 6388: "Scorpius", 6541: "Corona Australis", 6543: "Draco", 6723: "Sagittarius", 6741: "Aquila", 6752: "Pavo", 6781: "Aquila", 6826: "Cygnus", 6888: "Cygnus", 6946: "Cygnus", 6960: "Cygnus", 6974: "Cygnus", 6992: "Cygnus", 7000: "Cygnus", 7009: "Aquarius", 7023: "Cepheus", 7293: "Aquarius", 7380: "Cepheus", 7635: "Cassiopeia", 7662: "Andromeda"]
let ICConst = [59: "Cassiopeia", 63: "Cassiopeia", 405: "Auriga", 417: "Auriga", 434: "Orion", 443: "Gemini", 1318: "Cygnus", 1396: "Cepheus", 1795: "Cassiopeia", 1805: "Cassiopeia", 1848: "Cassiopeia", 2118: "Eridanus", 2177: "Monoceros", 2391: "Vela", 2602: "Carina", 2944: "Centaurus", 4592: "Scorpius", 5067: "Cygnus", 5070: "Cygnus", 5146: "Cygnus"]
let SharplessConst = [68: "Serpens", 129: "Cepheus", 136: "Cepheus", 157: "Cassiopeia", 240: "Taurus"]
let OthersConst = ["JU1": "Cygnus", "ARP188": "Draco", "XSS J16271-2423": "Ophiuchus", "OU4": "Cepheus"]

let Pack1Targets = Set(["NGC457", "NGC1501", "NGC4567", "NGC4568", "SH2-129", "SH2-157", "NGC4676", "NGC6334", "IC417", "IC1795", "IC2177", "IC2944", "IC4592"])
let Pack2Targets = Set(["Sun", "Milkyway", "SH2-240", "JU1", "ARP188", "NGC5474", "NGC2440", "NGC7009", "NGC7662", "IC1318", "NGC4656", "XSS J16271-2423"])
let Pack3Targets = Set(["NGC1502", "NGC3532", "NGC4755", "NGC5466", "NGC6388", "NGC6541", "NGC6723", "NGC6752", "NGC2360", "NGC2362", "IC2391", "IC2602"])
let Pack4Targets = Set(["NGC246", "NGC6369", "NGC5907", "NGC6741", "NGC6781", "NGC6826", "NGC2080", "NGC1535", "OU4", "NGC3242", "SH2-68", "SH2-136"])

let telescopeBrands = ["Celestron", "Explore Scientific", "Meade", "Officina Stellare Veloce", "Orion", "Sky-Watcher", "Stellarvue", "Takahashi", "Tele Vue", "Vixen", "William Optics"]
let mountBrands = ["10 Micron", "Astro-Physics", "Celestron", "Hobym", "iOptron", "Meade", "Orion", "Sky-Watcher", "Software Bisque"]
let cameraBrands = ["Atik", "Canon", "Celestron", "Meade", "Moravian Instruments", "Nikon", "Orion", "QHYCCD", "QSI", "SBIG", "ZWO"]

let telescopeNames = ["Celestron": ["8\" Aplanatic", "9.25\" Schmidt-Cassegrain", "14\" Schmidt-Cassegrain", "8\" RASA f/2", "11\" RASA f/2.2", "14\" RASA f/2.2", "C11-A 11\" Starbright XLT", "C14-AF XLT 14\"", "EdgeHD 8\" Schmidt-Cassegrain", "EdgeHD 9.25\"", "EdgeHD 11\"", "EdgeHD 14\"", "NexStar 4SE", "NexStar 5SE", "NexStar 6SE", "NexStar 8SE"], "Explore Scientific": ["ED102 f/7", "ED127 f/7.5", "ED152 f/8", "EED80 f/6", "TED80 Triplet f/6"], "Meade": ["4\" 102 ED Refractor", "5\" 127 ED Refractor", "6\" 152 ED Refractor", "7\" 178 ED Refractor", "Series 6000 70mm APO", "Series 6000 80mm APO", "Series 6000 115mm APO", "Series 6000 130mm APO", "LS 6\" SCT", "LS 8\" SCT", "LX10 8\" SCT", "LX200 10\" SCT", "LX200 12\" SCT", "LX200 14\" SCT", "LX200 16\" SCT", "RCX400 10\"", "RCX400 12\"", "RCX400 14\"", "RCX400 16\"", "RCX400 20\""], "Officina Stellare Veloce": ["RH 200", "RH 250", "RH 300"], "Orion": ["CT80", "ED80T ED APO", "SkyQuest XT10i IntelliScope", "SpaceProbe 130 EQ", "SkyQuest XT6", "SkyScanner 100mm", "SkyQuest XT8", "StarBlast 4.5", "6\" Ritchey Chretien", "8\" Ritchey Chretien", "10\" Ritchey Chretien", "EON 110mm ED APO", "EON 115mm ED APO", "EON 130mm ED APO", "190mm Maksutov", "6\" Astrograph", "8\" Astrograph", "10\" Astrograph"], "Sky-Watcher": ["Esprit 100 mm ED Apo", "Esprit 120 mm ED Apo", "Esprit 150 mm ED Apo", "Esprit 80 mm ED", "Mak-Cass 102 mm", "Mak-Cass 127 mm", "Mak-Cass 150 mm", "Mak-Cass 180 mm", "SMak-Cass 190 mm", "Mak-Cass 90 mm", "ProED 100 mm Doublet Apo", "ProED 120 mm Doublet Apo", "ProED 80 mm Doublet Apo", "Quattro Newtonian 8\"", "Quattro Newtonian 10\"", "Quattro Newtonian 12\""], "Stellarvue": ["SVX070T Series", "SVX080T Series", "SVC102T Series", "SVX130T Series", "SVX140T Series", "SVX152T Series"], "Takahashi": ["FSQ-85EDX", "FSQ-106EDX4", "FS-60Q", "FOA-60 Series", "FC-76DS", "FC-100DL", "TSA-120", "FC-100 Series", "Mewlon 180C", "Mewlon 210", "Mewlon 250", "TOA-130 Series", "TOA-150 Series", "Epsilon E130D", "Epsilon E-180"], "Tele Vue": ["Apo NP Astrograph Refractor 127 mm", "Genesis 4\" Refractor", "NP-101 3.97\" Apo", "NP-101 Refractor", "NP101is 4\" Apo", "NP127fli 5\"", "Oracle 3\" Triplet Apo", "Pronto 2.8\" Refractor", "Renaissance 102 4\" Apo Refractor", "TV102iis - 4\" Apo", "TV60 2.4\" Apo", "TV60 Apo", "TV60is 2.4\" Apo", "TV76 76 Apo", "TV85 85 Apo"], "Vixen": ["3.1\" ED80SF Apo", "3.2\" A80SSWT", "VC200L 8\"", "VMC110L 4.3\"", "VMC200L 8\"", " VMC95L 3.7\""], "William Optics": ["66 mm ZenithStar", "70 mm ZenithStar", "FLT 110 Triplet Apo", "FLT 123 Super Apo", "FLT 132 Triplet Apo", "FLT 152 Triplet Apo", "FLT 158 Triplet Apo", "FLT 98 Triplet Apo", "Megrez 110 Triplet", "Megrez 88 Doublet FD", "Megrez 90 Apo", "Megrez 90 Doublet", "Megrez 90FD", "Zenith Star 80 II ED Apo", "ZenithStar 66 SD Doublet Apo"]]
let mountNames = ["10 Micron": ["GM1000 HPS", "GM2000 HPS II", "GM3000 HPS", "GM4000 HPS II"], "Astro-Physics": ["900 GTO", "1100 GTO", "1200 GTO", "1600 GTO", "3600 GTO", "Mach1 GTO", "Mach2 GTO"], "Celestron": ["AVX", "CGX", "CGX-L", "Omni CG4", "CGEM II"], "Hobym": ["CRUX 140", "CRUX 170", "CRUX 200", "CRUX 320"], "iOptron": ["CEM40", "CEM60", "CEM120", "iEQ30", "SkyGuider Pro", "SkyTracker Pro"], "Meade": ["LX65", "LX85", "LX850"], "Orion": ["Sirius EQ-G", "Atlas EQ-G"], "Sky-Watcher": ["Star Adventurer", "EQ5", "EQ6", "EQ6-R", "EQ8"], "Software Bisque": ["Paramount MyT", "Paramount ME II", "Paramount MX+", "Paramount Taurus"]]
let cameraNames = ["Atik": ["Horizon II", "Infinity", "GP", "ACIS 2.4", "ACIS 12.3", "ACIS 7.1", "4120EX", "One 9.0", "490EX", "460EX", "16200", "11000", "383L +"], "Canon": ["Rebel TXi series", "1D Series", "5D Series", "6D Series", "7D Series", "80D", "Ra", "R", "Rp"], "Celestron": ["Neximage 10 Solar Imager", "NexImage 5 Solar Imager", "Neximage BurstC", "Neximage BurstM", "Skyris 132C", "Skyris 236C", "Skyris 236M"], "Meade": ["1616", "208", "416"], "Moravian Instruments": ["G2-0402", "G2-1600", "G2-2000", "G2-3200", "G2-4000", "G2-8300", "G3-01000", "G3-11000", "G3-16200", "G3-16200C"], "Nikon": ["D780", "D850", "D7500", "D500", "D5500", "D810", "D750", "D610", "D7200", "D810A", "Z6", "Z7"], "Orion": ["Starshoot All-In-One", "Starshoot Pro", "Starshoot Solar System Color Imaging Camera"], "QHYCCD": ["QHY9", "QHY10", "QHY11", "QHY12", "QHY600M/C", "QHY268C", "QHY347C", "QHY128C", "QHY183M/C", "QHY163M/C", "QHY247C", "QHY168C", "QHY294C", "QHY550M/C/P", "QHY174/GPS", "QHY178/290/224", "QHY16200A", "QHY695A", "QHY90A", "QHY16803A", "QHY09000A", "QHY814A"], "QSI": ["6120", "616", "6162", "632", "660", "683", "690", "RS .40", "RS 1.6", "RS 2.0", "RS 2.8", "RS 3.2", "RS 4.2", "RS 6.1", "RS 8.3", "RS 9.2", "RS"], "SBIG": ["STC-428-OEM", "STX-16803", "STXL-6303E", "STXL-16200", "STC-7", "Aluma 47-10", "Aluma AC4040", "Aluma 694", "Aluma 77-00", "Aluma 814", "Aluma 3200", "Aluma 8300", "STF-8300", "STF-3200W", "STF-4070", "STF-8050"], "ZWO": ["ASI6200MM", "ASI6200MC", "ASI2600MC", "ASI533MC", "ASI1600GT", "ASI183GT", "ASI183MC", "ASI183MM", "ASI294MC", "ASI071MC", "ASI1600MM", "ASI385MC", "ASI290MC", "ASI290MM", "ASI178MM", "ASI178MC", "ASI224MC", "ASI120MC-S", "ASI120MM-S", "ASI174MM"]]

let telescopeLinks = ["Celestron": "https://optcorp.com/collections/telescopes?rfsn=3263689.229aa2&utm_source=refersion&utm_medium=affiliate&utm_campaign=3263689.229aa2#/filter:vendor:Celestron", "Explore Scientific": "https://optcorp.com/collections/telescopes?rfsn=3263689.229aa2&utm_source=refersion&utm_medium=affiliate&utm_campaign=3263689.229aa2#/filter:vendor:Explore$2520Scientific", "Meade": "https://optcorp.com/collections/telescopes?rfsn=3263689.229aa2&utm_source=refersion&utm_medium=affiliate&utm_campaign=3263689.229aa2#/filter:vendor:Meade", "Officina Stellare Veloce": "https://optcorp.com/collections/telescopes##/filter:vendor:Officina$2520Stellare", "Orion": "https://optcorp.com/collections/telescopes?rfsn=3263689.229aa2&utm_source=refersion&utm_medium=affiliate&utm_campaign=3263689.229aa2#/filter:vendor:Orion", "Sky-Watcher": "https://optcorp.com/collections/telescopes?rfsn=3263689.229aa2&utm_source=refersion&utm_medium=affiliate&utm_campaign=3263689.229aa2#/filter:vendor:Vixen#/filter:vendor:Sky$2520Watcher", "Stellarvue": "https://optcorp.com/collections/telescopes?rfsn=3263689.229aa2&utm_source=refersion&utm_medium=affiliate&utm_campaign=3263689.229aa2#/filter:vendor:Stellarvue", "Takahashi": "https://optcorp.com/collections/telescopes?rfsn=3263689.229aa2&utm_source=refersion&utm_medium=affiliate&utm_campaign=3263689.229aa2#/filter:vendor:Takahashi", "Tele Vue": "https://optcorp.com/collections/telescopes?rfsn=3263689.229aa2&utm_source=refersion&utm_medium=affiliate&utm_campaign=3263689.229aa2#/filter:vendor:Vixen#/filter:vendor:Tele$2520Vue", "Vixen": "https://optcorp.com/collections/telescopes?rfsn=3263689.229aa2&utm_source=refersion&utm_medium=affiliate&utm_campaign=3263689.229aa2#/filter:vendor:Vixen", "William Optics": "https://optcorp.com/collections/telescopes?rfsn=3263689.229aa2&utm_source=refersion&utm_medium=affiliate&utm_campaign=3263689.229aa2#/filter:vendor:Vixen#/filter:vendor:William$2520Optics"]
let mountLinks = ["10 Micron": "https://optcorp.com/collections/telescope-mounts?rfsn=3263689.229aa2&utm_source=refersion&utm_medium=affiliate&utm_campaign=3263689.229aa2#/filter:vendor:10$2520Micron", "Astro-Physics": "https://optcorp.com/collections/telescope-mounts?rfsn=3263689.229aa2&utm_source=refersion&utm_medium=affiliate&utm_campaign=3263689.229aa2#/filter:vendor:Astro-Physics", "Celestron": "https://optcorp.com/collections/telescope-mounts?rfsn=3263689.229aa2&utm_source=refersion&utm_medium=affiliate&utm_campaign=3263689.229aa2#/filter:vendor:Celestron", "Hobym": "https://optcorp.com/collections/telescope-mounts?rfsn=3263689.229aa2&utm_source=refersion&utm_medium=affiliate&utm_campaign=3263689.229aa2#/filter:vendor:HOBYM", "iOptron": "https://optcorp.com/collections/telescope-mounts?rfsn=3263689.229aa2&utm_source=refersion&utm_medium=affiliate&utm_campaign=3263689.229aa2#/filter:vendor:iOptron", "Meade": "https://optcorp.com/collections/telescope-mounts?rfsn=3263689.229aa2&utm_source=refersion&utm_medium=affiliate&utm_campaign=3263689.229aa2#/filter:vendor:Meade", "Orion": "https://optcorp.com/collections/telescope-mounts?rfsn=3263689.229aa2&utm_source=refersion&utm_medium=affiliate&utm_campaign=3263689.229aa2#/filter:vendor:Orion", "Sky-Watcher": "https://optcorp.com/collections/telescope-mounts?rfsn=3263689.229aa2&utm_source=refersion&utm_medium=affiliate&utm_campaign=3263689.229aa2#/filter:vendor:Orion#/filter:vendor:Sky$2520Watcher", "Software Bisque": "https://optcorp.com/collections/telescope-mounts?rfsn=3263689.229aa2&utm_source=refersion&utm_medium=affiliate&utm_campaign=3263689.229aa2#/filter:vendor:Orion#/filter:vendor:Software$2520Bisque"]
let cameraLinks = ["Atik": "https://optcorp.com/collections/telescope-cameras?rfsn=3263689.229aa2&utm_source=refersion&utm_medium=affiliate&utm_campaign=3263689.229aa2#/filter:vendor:ATIK", "Canon": "https://amzn.to/2KJYn7g", "Celestron": "https://optcorp.com/collections/telescope-cameras?rfsn=3263689.229aa2&utm_source=refersion&utm_medium=affiliate&utm_campaign=3263689.229aa2#/filter:vendor:Celestron", "Meade": "https://optcorp.com/collections/telescope-cameras?rfsn=3263689.229aa2&utm_source=refersion&utm_medium=affiliate&utm_campaign=3263689.229aa2#/filter:vendor:Meade", "Moravian Instruments": "https://optcorp.com/collections/telescope-cameras?rfsn=3263689.229aa2&utm_source=refersion&utm_medium=affiliate&utm_campaign=3263689.229aa2#/filter:vendor:Moravian$2520Instruments", "Nikon": "https://amzn.to/3bP7jnP", "Orion": "https://optcorp.com/collections/telescope-cameras?rfsn=3263689.229aa2&utm_source=refersion&utm_medium=affiliate&utm_campaign=3263689.229aa2#/filter:vendor:Orion", "QHYCCD": "https://optcorp.com/collections/telescope-cameras?rfsn=3263689.229aa2&utm_source=refersion&utm_medium=affiliate&utm_campaign=3263689.229aa2#/filter:vendor:QHY", "QSI": "https://optcorp.com/collections/telescope-cameras?rfsn=3263689.229aa2&utm_source=refersion&utm_medium=affiliate&utm_campaign=3263689.229aa2#/filter:vendor:QSI", "SBIG": "https://optcorp.com/collections/telescope-cameras?rfsn=3263689.229aa2&utm_source=refersion&utm_medium=affiliate&utm_campaign=3263689.229aa2#/filter:vendor:SBIG", "ZWO": "https://optcorp.com/collections/telescope-cameras?rfsn=3263689.229aa2&utm_source=refersion&utm_medium=affiliate&utm_campaign=3263689.229aa2#/filter:vendor:ZWO"]

let loadingIcon = UIActivityIndicatorView()
let startNoInput = UIApplication.shared.beginIgnoringInteractionEvents
let endNoInput = UIApplication.shared.endIgnoringInteractionEvents
let storage = Storage.storage().reference()
let db = Firestore.firestore()
let settings = FirestoreSettings()
let screenW = UIScreen.main.bounds.width
let screenH = UIScreen.main.bounds.height
let monthNames = ["January", "Feburary", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
var firstTime = false
var dateToday = ""
var featuredImageDate = ""
//communicate between profile and calendar view if featured user changes username
var newIodUserName = ""
//max image size to push and pull from db is 3MB
let imgMaxByte: Int64 = 1024 * 1024 * 3
let calCellSize = 50
let iodUserIconSize = 30
let maxSize = 700
let imageTooBigMessage = "The image size is too big. Please choose another image."

func formatLoadingIcon(icon: UIActivityIndicatorView) -> UIActivityIndicatorView {
    icon.center = CGPoint(x: screenW / 2, y: screenH / 2 - 75)
    icon.color = UIColor.lightGray
    if #available(iOS 13.0, *) {
        icon.style = UIActivityIndicatorView.Style.large
    }
    return icon
}

infix operator ^^
extension Bool {
    static func ^^(a:Bool, b:Bool) -> Bool {
        return a != b
    }
}

func processImageAndResize(inpImg: UIImage, resizeTo: CGSize, clip: Bool) -> [Any]? {
    var img = inpImg
    var factor = CGFloat(0.0)
    if clip ^^ (img.size.width / resizeTo.width > img.size.height / resizeTo.height) {
        factor = resizeTo.width / img.size.width
    } else {
        factor = resizeTo.height / img.size.height
    }
    let newSize = CGSize(width: img.size.width * factor, height: img.size.height * factor)
    let renderer = UIGraphicsImageRenderer(size: newSize)
    img = renderer.image { (context) in
        img.draw(in: CGRect(origin: .zero, size: newSize))
    }
    let imgData = img.jpegData(compressionQuality: 0.4)!
    return [img, imgData]
}

func processImage(inpImg: UIImage) -> [Any]? {
    var img = inpImg
    if Int(img.size.width) > maxSize || Int(img.size.height) > maxSize {
        let res = processImageAndResize(inpImg: img, resizeTo: CGSize(width: maxSize, height: maxSize), clip: false)
        img = res![0] as! UIImage
    }
    var quality: CGFloat = 1
    var imgData = img.jpegData(compressionQuality: 1)!
    var imgByte = imgData.count
    while imgByte > Int(1024 * 1024 * 0.7) && quality > 0 {
        quality -= 0.2
        imgData = img.jpegData(compressionQuality: quality)!
        imgByte = imgData.count
    }
    if imgByte > imgMaxByte {
        return nil
    }
    return [img, imgData]
}

func isEarlierDate(date1: String, date2: String) -> Bool {
    let year1 = Int(String(date1.suffix(4)))!
    let year2 = Int(String(date2.suffix(4)))!
    if year1 != year2 {
        return year1 < year2
    }
    let month1 = Int(String(date1.prefix(2)))!
    let month2 = Int(String(date2.prefix(2)))!
    if month1 != month2 {
        return month1 < month2
    }
    let day1 = Int(date1.prefix(4).suffix(2))!
    let day2 = Int(date2.prefix(4).suffix(2))!
    if day1 != day2 {
        return day1 < day2
    }
    return true
}

func formatTarget(inputTarget: String) -> String {
    //remove special chars and make it lowercased
    var target = inputTarget.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "’", with: "'").replacingOccurrences(of: "”", with: "\"").lowercased()
    if target.prefix(4) == "the " {
        target = String(target.suffix(target.count - 4))
    }
    if target.suffix(7) == " galaxy" && target != "cat's eye galaxy" && target != "pinwheel galaxy" {
        target = String(target.prefix(target.count - 7))
    }
    //check if a target nickname was inputted
    var res = target
    if res.suffix(5) == " star" {
        res = String(res.prefix(res.count - 5))
    }
    if res.suffix(7) == " nebula" && res != "cat's eye nebula" && res != "saturn nebula" {
        res = String(res.prefix(res.count - 7))
    }
    if res.suffix(8) == " cluster" && res != "pinwheel cluster" {
        res = String(res.prefix(res.count - 8))
    }
    if res == "double" && target.suffix(7) == "cluster" {
        res = "double cluster in perseus"
    }
    let nicknameRes = nicknames[res]
    if nicknameRes != nil {
        return nicknameRes!
    }
    //not a nickname, check if it's a valid target name
    if target == "xss j16271-2423" {
        return target.uppercased()
    }
    if target.prefix(9) == "sharpless" {
        target = "sh2" + String(target.suffix(target.count - 9))
    }
    if target.prefix(3) == "sh2" && !target.contains("-") {
        target.insert("-", at: target.index(target.startIndex, offsetBy: 3))
    }
    res = ""
    var ascVal: UInt8 = 0
    for c in target {
        if c.asciiValue == nil {continue}
        ascVal = c.asciiValue!
        //include alphanumerics only and dash if Sh
        if (ascVal > 96 && ascVal < 123) || (ascVal > 47 && ascVal < 58) || (target.prefix(2) == "sh" && ascVal == 45) {
            res.append(c)
        }
    }
    if res == "" {return inputTarget}
    res = res.uppercased()
    if res.prefix(7) == "MESSIER" {
        res = "M" + res.suffix(res.count - 7)
    } else if !res.last!.isNumber {//a planet target or Milky Way
        res = res.prefix(1).uppercased() + res.dropFirst().lowercased()
    }
    return res
}

func formattedTargetToTargetName(target: String) -> String {
    var res = target
    if target.prefix(1) == "M" && MessierConst[Int(String(target.suffix(target.count - 1))) ?? -1] != nil {
        res = "Messier " + String(target.suffix(target.count - 1))
    } else if target.prefix(3) == "NGC" && NGCConst[Int(String(target.suffix(target.count - 3))) ?? -1] != nil {
        res = "NGC " + String(target.suffix(target.count - 3))
    } else if target.prefix(2) == "IC" && ICConst[Int(String(target.suffix(target.count - 2))) ?? -1] != nil {
        res = "IC " + String(target.suffix(target.count - 2))
    } else if target.prefix(2) == "ARP" && ICConst[Int(String(target.suffix(target.count - 2))) ?? -1] != nil {
           res = "ARP " + String(target.suffix(target.count - 2))
    } else if target.prefix(2) == "JU" && ICConst[Int(String(target.suffix(target.count - 2))) ?? -1] != nil {
           res = "JU " + String(target.suffix(target.count - 3))
    } else if target.prefix(2) == "OU" && ICConst[Int(String(target.suffix(target.count - 2))) ?? -1] != nil {
           res = "OU " + String(target.suffix(target.count - 2))
    }
    if target == "XSS J16271-2423" {
        res = "Rho Ophiuchi"
    }
    if target == "Milkyway" {
        res = "Milky Way"
    }
    return res
}
func formattedTargetToImageName(target: String) -> String {
    var imageName = ""
    if Array(target)[1].isNumber {
        imageName = "Messier/" + target.dropFirst()
    } else if target.prefix(3) == "NGC" {
        imageName = "NGC/" + target.suffix(target.count - 3)
    } else if target.prefix(2) == "IC" {
        imageName = "IC/" + target.suffix(target.count - 2)
    } else if target.prefix(4) == "SH2-" {
        imageName = "Sharpless/" + target.suffix(target.count - 4)
    } else if PlanetTargets.contains(target) {
        imageName = "Planets/" + target
    } else {
        imageName = "Others/" + target
    }
    return imageName
}
class WelcomeViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var welcomeView: UIView!
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var border: UIImageView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var myAstroLabel: UILabel!
    @IBOutlet weak var signUpEmailField: UITextField!
    @IBOutlet weak var signUpPasswordField: UITextField!
    @IBOutlet weak var signUpPasswordConfirmField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var logInEmailField: UITextField!
    @IBOutlet weak var logInPasswordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var welcomeLabelLeadingC: NSLayoutConstraint!
    @IBOutlet weak var welcomeLabelTopCipad: NSLayoutConstraint!
    @IBOutlet weak var paragraphTopCipad: NSLayoutConstraint!
    @IBOutlet weak var signUpButtonTrailingC: NSLayoutConstraint!
    @IBOutlet weak var loginButtonTrailingC: NSLayoutConstraint!
    @IBOutlet weak var forgotEmailTopC: NSLayoutConstraint!
    var activeField: UIView? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for subview in welcomeView.subviews {
            subview.isHidden = true
        }
        if screenH < 600 {//iphone SE, 5s
            welcomeLabelLeadingC.constant = 15
            signUpButtonTrailingC.constant = 4
            loginButtonTrailingC.constant = 4
        } else if screenW < 400 {//iphone 8, 11
            welcomeLabelLeadingC.constant = 43
        } else if screenH > 1000 {//ipads
            background.image = UIImage(named: "Welcome/background-ipad")
            border.image = UIImage(named: "border-ipad")
            welcomeLabel.font = UIFont(name: "Pacifica Condensed", size: 26)
            myAstroLabel.font = UIFont(name: "Pacifica Condensed", size: 26)
            forgotEmailTopC.constant = 50
            if screenH > 1050 {//10.5, 11, 12,9
                paragraphTopCipad.constant = screenH * 0.05
            }
            if screenH > 1200 {//12.9
                welcomeLabelTopCipad.constant = 200
            }
        }
        for field in [signUpEmailField, signUpPasswordField, signUpPasswordConfirmField, logInEmailField, logInPasswordField] {
            field!.layer.borderColor = UIColor.white.cgColor
            field!.layer.borderWidth = 1.0
            field!.delegate = (self as UITextFieldDelegate)
            field!.autocorrectionType = .no
        }
        scrollView.delegate = (self as UIScrollViewDelegate)
    }
    override func present(_ viewControllerToPresent: UIViewController,
                          animated flag: Bool,
                          completion: (() -> Void)? = nil) {
      viewControllerToPresent.modalPresentationStyle = .fullScreen
      super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
    override func viewDidAppear(_ animated: Bool) {
        activeField?.resignFirstResponder()


//        db.collection("imageOfDayKeys").document(todayDate).setData(["imageKey": imageKey, "journalEntryInd": 0, "journalEntryListKey": journalEntryKey,"userKey": userKey], merge: false)
//        db.collection("imageOfDayLikes").document(todayDate).setData(["01JodwczOB4930pEfG3e": ""], merge: false)
//        db.collection("imageOfDayComments").document(todayDate).setData(["01JodwczOB4930pEfG3e29-08:37:00": "hi I'm Koso", "dCoSGcE9VEzij6An1wl829-11:37:00": "Hello this is Antoine"], merge: false)
        
        if Auth.auth().currentUser != nil {
            db.collection("userData").whereField("email", isEqualTo: Auth.auth().currentUser!.email!).getDocuments(completion: { (QuerySnapshot, Error) in
                if Error != nil {
                    print(Error!)
                } else {
                    if QuerySnapshot!.documents == [] {
                        do {
                            try Auth.auth().signOut()
                        }
                        catch let signOutError as NSError {
                            print ("Error signing out: %@", signOutError)
                        }
                        for subview in self.welcomeView.subviews {
                            subview.isHidden = false
                        }
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let initial = storyboard.instantiateInitialViewController()
                        UIApplication.shared.keyWindow?.rootViewController = initial
                    } else {
//                        do {
//                            try Auth.auth().signOut()
//                        }
//                        catch let signOutError as NSError {
//                            print ("Error signing out: %@", signOutError)
//                        }
//                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                        let initial = storyboard.instantiateInitialViewController()
//                        UIApplication.shared.keyWindow?.rootViewController = initial
                        
                        let data = QuerySnapshot!.documents[0]
                        KeychainWrapper.standard.set(data.documentID, forKey: "dbKey")
                        let userName = data["userName"]
                        if userName == nil {
                            self.performSegue(withIdentifier: "welcomeToProfileCreation", sender: self)
                        } else {
                            KeychainWrapper.standard.set(userName as! String, forKey: "userName")
                            self.performSegue(withIdentifier: "welcomeToCalendar", sender: nil)
                        }
                    }
                }
            })
        } else {
            for subview in welcomeView.subviews {
                subview.isHidden = false
            }
        }
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        activeField?.resignFirstResponder()
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if screenH < 1000 {
            if textField == signUpEmailField || textField == signUpPasswordField || textField == signUpPasswordConfirmField {
                scrollView.setContentOffset(CGPoint(x: 0, y: textField.frame.origin.y - (screenH * 0.45)), animated: true)
            } else {
                let yOffset = contentView.bounds.height - scrollView.bounds.height
                scrollView.setContentOffset(CGPoint(x: 0, y: yOffset), animated: true)
            }
        }
        activeField = textField
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    @IBAction func signUpButtonTapped(_ sender: Any) {
        startNoInput()
        if signUpPasswordField.text != signUpPasswordConfirmField.text {
            let alertController = UIAlertController(title: "Password Incorrect", message: "Please re-type password", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
            endNoInput()
        } else {
            Auth.auth().createUser(withEmail: signUpEmailField.text!.lowercased(), password: signUpPasswordField.text!) { (user, error) in
                if error != nil {
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    self.signUpButton.isHidden = true
                    self.loginButton.isHidden = true
                    var newDataRef: DocumentReference? = nil
                    newDataRef = db.collection("userData").addDocument(data: ["email": self.signUpEmailField.text!.lowercased()]) {err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        } else {
                            let docKey = newDataRef!.documentID
                            KeychainWrapper.standard.set(docKey, forKey: "dbKey")
                        }
                    }
                    self.performSegue(withIdentifier: "welcomeToProfileCreation", sender: self)
                }
                endNoInput()
            }
        }
    }
    @IBAction func logInButtonTapped(_ sender: Any) {
        startNoInput()
        Auth.auth().signIn(withEmail: logInEmailField.text!, password: logInPasswordField.text!) {(user, error) in
            if error != nil {
                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                self.signUpButton.isHidden = true
                self.loginButton.isHidden = true
                db.collection("userData").whereField("email", isEqualTo: self.logInEmailField.text!.lowercased()).limit(to: 1).getDocuments(completion: {(QuerySnapshot, Error) in
                    if Error != nil {
                        print(Error!)
                    } else {
                        let data = QuerySnapshot!.documents[0]
                        KeychainWrapper.standard.set(data.documentID, forKey: "dbKey")
                        if data["userName"] == nil {
                            self.performSegue(withIdentifier: "welcomeToProfileCreation", sender: self)
                        } else {
                            KeychainWrapper.standard.set(data["userName"] as! String, forKey: "userName")
                            print("sign-in successful")
                            self.performSegue(withIdentifier: "welcomeToCalendar", sender: self)
                        }
                    }
                })
            }
            endNoInput()
        }
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    @IBAction func forgotEmailButtonTapped(_ sender: Any) {
        func composeEmail() {
            if MFMailComposeViewController.canSendMail() {
                let mailComposerVC = MFMailComposeViewController()
                mailComposerVC.mailComposeDelegate = (self as MFMailComposeViewControllerDelegate)
                mailComposerVC.setToRecipients(["nevadaastrophotography@gmail.com"])
                mailComposerVC.setSubject("Forgot Email")
                mailComposerVC.setMessageBody("", isHTML: false)
                self.present(mailComposerVC, animated: true, completion: nil)
            }
        }
        let alertController = UIAlertController(title: "Forgot Email", message: "Please send an email to: nevadaastrophotography@gmail.com to recover your email. Please give us information such as username, description of profile image, etc.", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: {(alertAction) in composeEmail()})
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    @IBAction func resetPasswordButtonTapped(_ sender: Any) {
        Auth.auth().sendPasswordReset(withEmail: logInEmailField.text!) {error in
            if error != nil {
                let alertController = UIAlertController(title: "Error", message: error!.localizedDescription + " Please fix it in the email field.", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                let alertController = UIAlertController(title: "Email Sent", message: "A password reset email has been sent to your inbox.", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
}

