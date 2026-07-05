import SwiftUI
import UIKit

enum KapselkiL10n {
    static var isEnglish: Bool {
        if let preferred = Locale.preferredLanguages.first?.lowercased(), preferred.hasPrefix("en") {
            return true
        }
        return Locale.current.language.languageCode?.identifier.lowercased().hasPrefix("en") == true
    }

    static func text(_ polish: String) -> String {
        guard isEnglish else {
            return polish
        }
        return english[polish] ?? polish
    }

    static func pick(pl polish: String, en english: String) -> String {
        isEnglish ? english : polish
    }

    private static let english: [String: String] = [
        "Szybka partyjka": "Quick match",
        "Osiedlowy tour": "Backyard tour",
        "Wyzwanie dnia": "Daily challenge",
        "Mistrz podwórka": "Backyard champ",
        "3 krótkie próby": "3 short runs",
        "5 podwórkowych etapów": "5 backyard stages",
        "jedna trasa na dziś": "one track today",
        "5 rund specjalnych": "5 special rounds",
        "Chodnik": "Sidewalk",
        "Trawa": "Grass",
        "Piasek": "Sand",
        "Boisko": "Court",
        "Stół": "Table",
        "szybki ślizg": "fast slide",
        "miękka kontrola": "soft control",
        "krótki, ciężki ruch": "short, heavy move",
        "kreda i zakręty": "chalk and turns",
        "gładka jazda": "smooth ride",
        "Szybki finisz": "Fast finish",
        "Meta do 8 pstryków": "Finish in 8 flicks",
        "Cel: dojedź do mety w maksymalnie 8 pstryków.": "Goal: reach the finish in 8 flicks or fewer.",
        "czysto": "clean",
        "Czysta kreda": "Clean chalk",
        "Bez wyjazdu": "No off-track",
        "Cel: przejedź etap bez wyjazdu za kredę.": "Goal: finish the stage without leaving the chalk line.",
        "Zgarnij bonus": "Grab a bonus",
        "Weź 1 power-up": "Get 1 power-up",
        "Cel: wpadnij kapslem w przynajmniej jeden bonus.": "Goal: hit at least one bonus with your cap.",
        "Mało pstryków": "Few flicks",
        "Do 11 pstryków": "Up to 11 flicks",
        "Cel: dojedź do mety w maksymalnie 11 pstryków.": "Goal: reach the finish in 11 flicks or fewer.",
        "Zapas siły": "Energy reserve",
        "60+ energii": "60+ energy",
        "Cel: dojedź do mety z energią co najmniej 60.": "Goal: finish with at least 60 energy.",
        "Stylowy finał": "Stylish finish",
        "120 stylu": "120 style",
        "Cel: uzbieraj 120 punktów stylu.": "Goal: score 120 style points.",
        "Dzisiejszy łup": "Today's haul",
        "Cel dnia: zgarnij bonus i dojedź do mety.": "Daily goal: grab a bonus and reach the finish.",
        "Czysty dzień": "Clean day",
        "Cel dnia: żadnego wyjazdu za kredę.": "Daily goal: do not leave the chalk line.",
        "Oszczędzaj siłę": "Save energy",
        "55+ energii": "55+ energy",
        "Cel dnia: zachowaj co najmniej 55 energii.": "Daily goal: keep at least 55 energy.",
        "Podpis na asfalcie": "Signature on asphalt",
        "110 stylu": "110 style",
        "Cel dnia: zrób 110 punktów stylu.": "Daily goal: score 110 style points.",
        "Runda czystości": "Clean run",
        "Cel: przejedź bez wyjazdu za kredę.": "Goal: finish without leaving the chalk line.",
        "Turbo po drodze": "Turbo on the way",
        "Weź 2 power-upy": "Get 2 power-ups",
        "Cel: zbierz dwa bonusy w jednej rundzie.": "Goal: collect two bonuses in one run.",
        "Krótka ręka": "Short hand",
        "Do 10 pstryków": "Up to 10 flicks",
        "Cel: meta w maksymalnie 10 pstryków.": "Goal: finish in 10 flicks or fewer.",
        "Zimna głowa": "Cool head",
        "65+ energii": "65+ energy",
        "Cel: finisz z energią co najmniej 65.": "Goal: finish with at least 65 energy.",
        "Mistrzowski styl": "Champion style",
        "135 stylu": "135 style",
        "Cel: zakończ z wynikiem stylu 135+.": "Goal: finish with 135+ style.",
        "Blokowy Chodnik": "Block Sidewalk",
        "rozgrzewka na płytach": "warm-up on concrete slabs",
        "Boisko z Kredą": "Chalk Court",
        "ciasne zakręty": "tight turns",
        "Trawnik za Garażem": "Garage Lawn",
        "miękki ślizg": "soft slide",
        "Piaskownica Turbo": "Turbo Sandbox",
        "ciężkie pstryki": "heavy flicks",
        "Kuchenny Finał": "Kitchen Final",
        "szybka gładka meta": "fast smooth finish",
        "Czysty Start": "Clean Start",
        "bez wyjazdu za kredę": "no leaving the chalk",
        "Turbo Kreda": "Turbo Chalk",
        "zgarnij dwa bonusy": "grab two bonuses",
        "Trawnikowy Slalom": "Lawn Slalom",
        "krótka seria pstryków": "short flick series",
        "Piaskowy Spokój": "Sand Calm",
        "oszczędzaj energię": "save energy",
        "Finał na Stole": "Table Final",
        "styl ponad wszystko": "style above all",
        "Pstryknij": "Flick",
        "Dotknij kapsla, odciągnij palec i puść. Im dalej odciągniesz, tym mocniejszy strzał.": "Touch the cap, pull your finger back, and release. The farther you pull, the stronger the shot.",
        "Trzymaj kredę": "Stay on chalk",
        "Jedź między kredowymi liniami. Wyjazd poza trasę zabiera energię i psuje styl.": "Ride between the chalk lines. Leaving the track costs energy and hurts style.",
        "Wybierz ekipę": "Pick your crew",
        "Każda postać ma własny kapsel: inną moc, kontrolę i spin. Dobierz styl do planszy.": "Each character has a unique cap: power, control, and spin. Match your style to the board.",
        "podwórkowy pstryk na kilka minut": "a backyard flick game for a few minutes",
        "SZYBKA PARTYJKA": "QUICK MATCH",
        "OSIEDLOWY TOUR": "BACKYARD TOUR",
        "WYZWANIE DNIA": "DAILY CHALLENGE",
        "MISTRZ PODWÓRKA": "BACKYARD CHAMP",
        "O CO CHODZI": "HOW TO PLAY",
        "OSIEDLE '86": "BLOCK '86",
        "PSTRYK": "FLICK",
        "BONUSY": "BONUSES",
        "Wybór kapsla": "Cap selection",
        "JAK SIĘ GRA": "HOW TO PLAY",
        "WYBIERZ KAPSEL": "PICK A CAP",
        "DALEJ": "NEXT",
        "START 3 PRÓB": "START 3 RUNS",
        "START ETAPU": "START STAGE",
        "START DNIA": "START DAY",
        "START RUNDY": "START ROUND",
        "EKIPA": "CREW",
        "Ta postać jest jeszcze zablokowana.": "This character is still locked.",
        "PLANSZE": "BOARDS",
        "ETAPY TOURU": "TOUR STAGES",
        "TRASA DNIA": "TODAY'S TRACK",
        "RUNDY MISTRZA": "CHAMP ROUNDS",
        "Pstryki": "Flicks",
        "Kreda": "Chalk",
        "Energia": "Energy",
        "Próba": "Run",
        "Etap": "Stage",
        "Runda": "Round",
        "Menu": "Menu",
        "Kamera": "Camera",
        "Restart": "Restart",
        "Podnieś albo opuść kamerę": "Raise or lower the camera",
        "Przybliż albo oddal kamerę": "Zoom the camera in or out",
        "Porusz kamerą": "Move the camera",
        "Miejsce": "Place",
        "Wyjazdy": "Off-track",
        "Styl": "Style",
        "CEL ZALICZONY": "GOAL COMPLETE",
        "CEL NA NASTĘPNY RAZ": "NEXT TIME GOAL",
        "Szybka partyjka zakończona. Najlepszy wynik robisz kolejną serią.": "Quick match finished. Start another series to beat your best.",
        "Tour ukończony. To już finał osiedla.": "Tour complete. That was the backyard final.",
        "Dzisiejsze wyzwanie możesz poprawiać, aż pstryk będzie idealny.": "You can replay today's challenge until the flick is perfect.",
        "Seria Mistrza podwórka ukończona.": "Backyard champ series complete.",
        "NASTĘPNY ETAP": "NEXT STAGE",
        "TOUR OD NOWA": "RESTART TOUR",
        "POPRAW WYNIK DNIA": "RETRY DAILY SCORE",
        "NASTĘPNA RUNDA": "NEXT ROUND",
        "SERIA OD NOWA": "RESTART SERIES",
        "Złoto pod blokiem": "Backyard gold",
        "Srebro na kredzie": "Chalk silver",
        "Brązowy pstryk": "Bronze flick",
        "Meta zaliczona": "Finish reached",
        "Cel zaliczony.": "Goal complete.",
        "Cel jeszcze do poprawy.": "Goal still needs work.",
        "Kreda!": "Chalk!",
        "Patyk!": "Twig!",
        "Guma!": "Gum!",
        "Pudełko!": "Matchbox!",
        "Kamyczek!": "Marble!",
        "Kałuża!": "Puddle!",
        "Linijka!": "Ruler!",
        "Hopka!": "Ramp!",
        "Energia!": "Energy!",
        "Dotknij kapsla": "Touch the cap",
        "Dotknij kapsla, odciągnij palec i puść.": "Touch the cap, pull your finger back, and release.",
        "Twój ruch": "Your turn",
        "Petarda!": "Rocket shot!",
        "Podkręcony!": "Nice spin!",
        "Czysty pstryk!": "Clean flick!",
        "Uratowane!": "Saved!",
        "Meta z klasą!": "Stylish finish!",
        "Meta!": "Finish!",
        "Poza trasą": "Off track",
        "Wróć kapslem na kredę jednym spokojnym pstrykiem.": "Get the cap back on the chalk with one calm flick.",
        "Pstrykaj czysto.": "Flick clean.",
        "Ślizg kapsla": "Cap sliding",
        "Patrz na spin, przeszkody i kredową linię.": "Watch the spin, obstacles, and chalk line.",
        "Rywale pstrykają": "Rivals flick",
        "Za chwilę twój ruch.": "Your turn is next.",
        "Cel rundy zaliczony.": "Round goal complete.",
        "Cel można poprawić kolejnym przejazdem.": "You can improve the goal on the next run.",
        "mocny pierwszy strzał": "strong opening shot",
        "najczystsza linia": "cleanest line",
        "odbicia od przeszkód": "obstacle rebounds",
        "największa rakieta": "biggest rocket",
        "mało traci energii": "loses little energy",
        "najmocniejszy spin": "strongest spin",
        "precyzja na kredzie": "chalk precision",
        "długi miękki ślizg": "long soft slide",
        "kontakt i przepychanki": "contact and shoves",
        "wybacza błędy": "forgives mistakes",
        "szybki refleks": "quick reflex",
        "sprężyste odbicia": "springy rebounds",
        "swój styl kapsla": "their own cap style",
        "Felek Pstryk": "Felek Flick",
        "Tosia Spryt": "Tosia Smart",
        "Rudy Okular": "Rudy Specs",
        "Gapcio Rakieta": "Gapcio Rocket",
        "Dziadek Wacek": "Grandpa Wacek",
        "Kapitan Niko": "Captain Niko",
        "Mietek Sen": "Sleepy Mietek",
        "Ruda Iskra": "Rusty Spark",
        "Babcia Lola": "Grandma Lola",
        "Profesor Sprężyna": "Professor Spring",
        "Iskra": "Spark",
        "Spręż": "Spring",
        "Mocny start": "Strong start",
        "Czysta linia": "Clean line",
        "Techniczne odbicia": "Technical rebounds",
        "Szalony wystrzal": "Wild shot",
        "Stara szkola": "Old school",
        "Bandy i ryzyko": "Rails and risk",
        "Precyzyjny kurs": "Precise course",
        "Miekki slizg": "Soft slide",
        "Agresywne odbicie": "Aggressive rebound",
        "Wybacza bledy": "Forgives mistakes",
        "Turbo refleks": "Turbo reflex",
        "Sprytne odbicia": "Clever rebounds",
        "Odwazny podworkowy kapitan. Lubi pstryknac pierwszy i narobic zamieszania przy bandzie.": "A brave backyard captain. Loves flicking first and stirring things up by the rail.",
        "Widzi skroty tam, gdzie inni widza tylko krzywa krede. Najlepsza do spokojnych, dokladnych pstrykow.": "Sees shortcuts where others only see crooked chalk. Best for calm, accurate flicks.",
        "Liczy katy w glowie i lubi odbijac sie od przeszkod jak od linijki.": "Calculates angles in his head and likes bouncing off obstacles like off a ruler.",
        "Nie zawsze wie, dokad leci, ale kiedy trafi, cala trasa klaszcze.": "Does not always know where he is flying, but when he hits, the whole track cheers.",
        "Spokojny mistrz. Nie spieszy sie, bo wie, ze kapsel i tak dojedzie tam, gdzie trzeba.": "A calm master. He never rushes, because the cap will get where it needs to go.",
        "Gra na krawedzi kredy. Najlepsza, kiedy trzeba mocno podkrecic kapsel obok przeszkody.": "Plays on the edge of the chalk. Best when the cap needs heavy spin around an obstacle.",
        "Trzyma nerwy na wodzy. Idealny do waskich przejazdow i pstrykow na centymetry.": "Keeps nerves steady. Perfect for narrow passages and centimeter-perfect flicks.",
        "Wyglada, jakby zaraz zasnal, ale jego kapsel potrafi dlugo plynac po trasie.": "Looks like he might fall asleep, but his cap can glide a long way down the track.",
        "Lubi przepychanki i szybkie decyzje. Dobry wybor, gdy trasa robi sie ciasna.": "Likes shoves and quick decisions. A good pick when the track gets tight.",
        "Legenda osiedla. Nie robi popisu, tylko dowozi wynik z usmiechem.": "A neighborhood legend. No showboating, just brings the result home with a smile.",
        "Pojawia sie, kiedy ktos pokaze, ze szybka partyjka to nie przypadek, tylko czysty pstryk.": "Shows up when someone proves a quick match is not luck, just a clean flick.",
        "Zna kazdy kat, kazda linijke i kazda hopke. Do ekipy dolacza po finale osiedlowego touru.": "Knows every angle, every ruler, and every ramp. Joins the crew after the backyard tour final.",
        "Czerwony rant, niebieska tasma, lekko poobijany papier po wielu startach.": "Red rim, blue tape, and slightly battered paper after many starts.",
        "Zolty rant, czerwony pasek kontrolny i rowno przyklejona wkladka.": "Yellow rim, red control stripe, and a neatly glued insert.",
        "Zielony rant, zolte oznaczenie i papier z malymi kreskami jak notatki taktyczne.": "Green rim, yellow mark, and paper with tiny lines like tactical notes.",
        "Niebieski rant, pomaranczowy pasek i luzno krzywa tasma po awaryjnych naprawach.": "Blue rim, orange stripe, and loosely crooked tape after emergency repairs.",
        "Miodowo-brazowy rant, zielona tasma i papier wygladajacy jak wycinek ze starego zeszytu.": "Honey-brown rim, green tape, and paper that looks cut from an old notebook.",
        "Turkusowy rant, zolty pasek i kilka jasnych odpryskow na zebach kapsla.": "Turquoise rim, yellow stripe, and a few bright chips on the cap teeth.",
        "Granatowy rant, jasna tasma jak marynarski pasek i mocno wycentrowana wkladka.": "Navy rim, pale tape like a sailor stripe, and a tightly centered insert.",
        "Morski rant, niebieska tasma i gladka plastelina bez nerwowych odciskow.": "Sea-green rim, blue tape, and smooth putty without nervous fingerprints.",
        "Pomaranczowy rant, zielony pasek i mocniej porysowana krawedz po kontaktach.": "Orange rim, green stripe, and a heavily scratched edge from contact.",
        "Fioletowy rant, zolta tasma i najczysciej przyklejony portret w calym pudelku.": "Purple rim, yellow tape, and the cleanest glued portrait in the box.",
        "Neonowy rant, zolty pasek i portret, ktory wyglada jak wycinek z kolorowego plakatu.": "Neon rim, yellow stripe, and a portrait that looks cut from a colorful poster.",
        "Mietowy rant, pomaranczowy pasek i idealnie podklejony portret malego wynalazcy.": "Mint rim, orange stripe, and a perfectly glued portrait of a little inventor.",
        "Zdobądź srebro w Szybkiej Partyjce.": "Win silver in Quick Match.",
        "Ukończ Kuchenny Finał w Osiedlowym Tourze.": "Finish the Kitchen Final in Backyard Tour."
    ]
}

extension String {
    var kText: String {
        KapselkiL10n.text(self)
    }
}

enum KapselkiTheme {
    static let ink = Color(red: 0.09, green: 0.10, blue: 0.10)
    static let paper = Color(red: 0.98, green: 0.92, blue: 0.72)
    static let chalk = Color(red: 0.98, green: 0.97, blue: 0.88)
    static let red = Color(red: 0.86, green: 0.18, blue: 0.12)
    static let blue = Color(red: 0.10, green: 0.37, blue: 0.72)
    static let yellow = Color(red: 0.96, green: 0.72, blue: 0.17)
    static let green = Color(red: 0.24, green: 0.53, blue: 0.29)
    static let orange = Color(red: 0.91, green: 0.43, blue: 0.16)
    static let sky = Color(red: 0.58, green: 0.76, blue: 0.78)
    static let concrete = Color(red: 0.57, green: 0.56, blue: 0.49)
    static let sand = Color(red: 0.76, green: 0.59, blue: 0.35)

    static let uiInk = UIColor(red: 0.09, green: 0.10, blue: 0.10, alpha: 1)
    static let uiPaper = UIColor(red: 0.98, green: 0.92, blue: 0.72, alpha: 1)
    static let uiChalk = UIColor(red: 0.98, green: 0.97, blue: 0.88, alpha: 1)
    static let uiRed = UIColor(red: 0.86, green: 0.18, blue: 0.12, alpha: 1)
    static let uiBlue = UIColor(red: 0.10, green: 0.37, blue: 0.72, alpha: 1)
    static let uiYellow = UIColor(red: 0.96, green: 0.72, blue: 0.17, alpha: 1)
    static let uiGreen = UIColor(red: 0.24, green: 0.53, blue: 0.29, alpha: 1)
    static let uiOrange = UIColor(red: 0.91, green: 0.43, blue: 0.16, alpha: 1)
    static let uiSky = UIColor(red: 0.58, green: 0.76, blue: 0.78, alpha: 1)
}

struct KapselkiCharacter: Identifiable, Equatable {
    let id: String
    let name: String
    let shortName: String
    let number: String
    let portraitAssetName: String
    let color: Color
    let uiColor: UIColor
    let stripeColor: UIColor
    let style: String
    let bio: String
    let capDescription: String
    let powerMultiplier: Float
    let control: Float
    let spinMultiplier: Float
    let unlockRequirement: String?

    init(
        id: String,
        name: String,
        shortName: String,
        number: String,
        portraitAssetName: String,
        color: Color,
        uiColor: UIColor,
        stripeColor: UIColor,
        style: String,
        bio: String,
        capDescription: String,
        powerMultiplier: Float,
        control: Float,
        spinMultiplier: Float,
        unlockRequirement: String? = nil
    ) {
        self.id = id
        self.name = name
        self.shortName = shortName
        self.number = number
        self.portraitAssetName = portraitAssetName
        self.color = color
        self.uiColor = uiColor
        self.stripeColor = stripeColor
        self.style = style
        self.bio = bio
        self.capDescription = capDescription
        self.powerMultiplier = powerMultiplier
        self.control = control
        self.spinMultiplier = spinMultiplier
        self.unlockRequirement = unlockRequirement
    }

    var powerScore: Int {
        Int((powerMultiplier * 5).rounded()).clamped(to: 1...7)
    }

    var controlScore: Int {
        Int((control * 6).rounded()).clamped(to: 1...7)
    }

    var spinScore: Int {
        Int((spinMultiplier * 5).rounded()).clamped(to: 1...7)
    }

    var trait: String {
        switch id {
        case "felek":
            return "mocny pierwszy strzał".kText
        case "tosia":
            return "najczystsza linia".kText
        case "rudy":
            return "odbicia od przeszkód".kText
        case "gapcio":
            return "największa rakieta".kText
        case "wacek":
            return "mało traci energii".kText
        case "klara":
            return "najmocniejszy spin".kText
        case "niko":
            return "precyzja na kredzie".kText
        case "mietek":
            return "długi miękki ślizg".kText
        case "iskra":
            return "kontakt i przepychanki".kText
        case "lola":
            return "wybacza błędy".kText
        case "neon":
            return "szybki refleks".kText
        case "sprezyna":
            return "sprężyste odbicia".kText
        default:
            return "swój styl kapsla".kText
        }
    }

    var localizedName: String {
        name.kText
    }

    var localizedShortName: String {
        shortName.kText
    }

    var localizedStyle: String {
        style.kText
    }

    var localizedBio: String {
        bio.kText
    }

    var localizedCapDescription: String {
        capDescription.kText
    }

    var localizedUnlockRequirement: String? {
        unlockRequirement?.kText
    }

    static func == (lhs: KapselkiCharacter, rhs: KapselkiCharacter) -> Bool {
        lhs.id == rhs.id
    }

    static let roster: [KapselkiCharacter] = [
        KapselkiCharacter(
            id: "felek",
            name: "Felek Pstryk",
            shortName: "Felek",
            number: "7",
            portraitAssetName: "portrait_felek",
            color: KapselkiTheme.red,
            uiColor: KapselkiTheme.uiRed,
            stripeColor: KapselkiTheme.uiBlue,
            style: "Mocny start",
            bio: "Odwazny podworkowy kapitan. Lubi pstryknac pierwszy i narobic zamieszania przy bandzie.",
            capDescription: "Czerwony rant, niebieska tasma, lekko poobijany papier po wielu startach.",
            powerMultiplier: 1.06,
            control: 0.80,
            spinMultiplier: 1.00
        ),
        KapselkiCharacter(
            id: "tosia",
            name: "Tosia Spryt",
            shortName: "Tosia",
            number: "11",
            portraitAssetName: "portrait_tosia",
            color: KapselkiTheme.yellow,
            uiColor: KapselkiTheme.uiYellow,
            stripeColor: KapselkiTheme.uiRed,
            style: "Czysta linia",
            bio: "Widzi skroty tam, gdzie inni widza tylko krzywa krede. Najlepsza do spokojnych, dokladnych pstrykow.",
            capDescription: "Zolty rant, czerwony pasek kontrolny i rowno przyklejona wkladka.",
            powerMultiplier: 0.98,
            control: 0.90,
            spinMultiplier: 0.94
        ),
        KapselkiCharacter(
            id: "rudy",
            name: "Rudy Okular",
            shortName: "Rudy",
            number: "2",
            portraitAssetName: "portrait_rudy",
            color: KapselkiTheme.green,
            uiColor: KapselkiTheme.uiGreen,
            stripeColor: KapselkiTheme.uiYellow,
            style: "Techniczne odbicia",
            bio: "Liczy katy w glowie i lubi odbijac sie od przeszkod jak od linijki.",
            capDescription: "Zielony rant, zolte oznaczenie i papier z malymi kreskami jak notatki taktyczne.",
            powerMultiplier: 0.96,
            control: 0.88,
            spinMultiplier: 1.08
        ),
        KapselkiCharacter(
            id: "gapcio",
            name: "Gapcio Rakieta",
            shortName: "Gapcio",
            number: "8",
            portraitAssetName: "portrait_gapcio",
            color: KapselkiTheme.blue,
            uiColor: KapselkiTheme.uiBlue,
            stripeColor: KapselkiTheme.uiOrange,
            style: "Szalony wystrzal",
            bio: "Nie zawsze wie, dokad leci, ale kiedy trafi, cala trasa klaszcze.",
            capDescription: "Niebieski rant, pomaranczowy pasek i luzno krzywa tasma po awaryjnych naprawach.",
            powerMultiplier: 1.13,
            control: 0.74,
            spinMultiplier: 1.03
        ),
        KapselkiCharacter(
            id: "wacek",
            name: "Dziadek Wacek",
            shortName: "Wacek",
            number: "5",
            portraitAssetName: "portrait_wacek",
            color: Color(red: 0.62, green: 0.42, blue: 0.18),
            uiColor: UIColor(red: 0.62, green: 0.42, blue: 0.18, alpha: 1),
            stripeColor: KapselkiTheme.uiGreen,
            style: "Stara szkola",
            bio: "Spokojny mistrz. Nie spieszy sie, bo wie, ze kapsel i tak dojedzie tam, gdzie trzeba.",
            capDescription: "Miodowo-brazowy rant, zielona tasma i papier wygladajacy jak wycinek ze starego zeszytu.",
            powerMultiplier: 0.94,
            control: 0.93,
            spinMultiplier: 0.88
        ),
        KapselkiCharacter(
            id: "klara",
            name: "Klara Bandana",
            shortName: "Klara",
            number: "3",
            portraitAssetName: "portrait_klara",
            color: Color(red: 0.10, green: 0.60, blue: 0.66),
            uiColor: UIColor(red: 0.10, green: 0.60, blue: 0.66, alpha: 1),
            stripeColor: KapselkiTheme.uiYellow,
            style: "Bandy i ryzyko",
            bio: "Gra na krawedzi kredy. Najlepsza, kiedy trzeba mocno podkrecic kapsel obok przeszkody.",
            capDescription: "Turkusowy rant, zolty pasek i kilka jasnych odpryskow na zebach kapsla.",
            powerMultiplier: 1.01,
            control: 0.80,
            spinMultiplier: 1.20
        ),
        KapselkiCharacter(
            id: "niko",
            name: "Kapitan Niko",
            shortName: "Niko",
            number: "1",
            portraitAssetName: "portrait_niko",
            color: Color(red: 0.08, green: 0.25, blue: 0.50),
            uiColor: UIColor(red: 0.08, green: 0.25, blue: 0.50, alpha: 1),
            stripeColor: KapselkiTheme.uiChalk,
            style: "Precyzyjny kurs",
            bio: "Trzyma nerwy na wodzy. Idealny do waskich przejazdow i pstrykow na centymetry.",
            capDescription: "Granatowy rant, jasna tasma jak marynarski pasek i mocno wycentrowana wkladka.",
            powerMultiplier: 0.97,
            control: 0.95,
            spinMultiplier: 0.92
        ),
        KapselkiCharacter(
            id: "mietek",
            name: "Mietek Sen",
            shortName: "Mietek",
            number: "4",
            portraitAssetName: "portrait_mietek",
            color: Color(red: 0.20, green: 0.56, blue: 0.56),
            uiColor: UIColor(red: 0.20, green: 0.56, blue: 0.56, alpha: 1),
            stripeColor: KapselkiTheme.uiBlue,
            style: "Miekki slizg",
            bio: "Wyglada, jakby zaraz zasnal, ale jego kapsel potrafi dlugo plynac po trasie.",
            capDescription: "Morski rant, niebieska tasma i gladka plastelina bez nerwowych odciskow.",
            powerMultiplier: 0.92,
            control: 0.86,
            spinMultiplier: 1.16
        ),
        KapselkiCharacter(
            id: "iskra",
            name: "Ruda Iskra",
            shortName: "Iskra",
            number: "9",
            portraitAssetName: "portrait_iskra",
            color: KapselkiTheme.orange,
            uiColor: KapselkiTheme.uiOrange,
            stripeColor: KapselkiTheme.uiGreen,
            style: "Agresywne odbicie",
            bio: "Lubi przepychanki i szybkie decyzje. Dobry wybor, gdy trasa robi sie ciasna.",
            capDescription: "Pomaranczowy rant, zielony pasek i mocniej porysowana krawedz po kontaktach.",
            powerMultiplier: 1.08,
            control: 0.77,
            spinMultiplier: 1.12
        ),
        KapselkiCharacter(
            id: "lola",
            name: "Babcia Lola",
            shortName: "Lola",
            number: "10",
            portraitAssetName: "portrait_lola",
            color: Color(red: 0.55, green: 0.36, blue: 0.70),
            uiColor: UIColor(red: 0.55, green: 0.36, blue: 0.70, alpha: 1),
            stripeColor: KapselkiTheme.uiYellow,
            style: "Wybacza bledy",
            bio: "Legenda osiedla. Nie robi popisu, tylko dowozi wynik z usmiechem.",
            capDescription: "Fioletowy rant, zolta tasma i najczysciej przyklejony portret w calym pudelku.",
            powerMultiplier: 0.90,
            control: 0.97,
            spinMultiplier: 0.84
        ),
        KapselkiCharacter(
            id: "neon",
            name: "Zosia Neon",
            shortName: "Neon",
            number: "12",
            portraitAssetName: "portrait_neon",
            color: Color(red: 0.86, green: 0.10, blue: 0.52),
            uiColor: UIColor(red: 0.86, green: 0.10, blue: 0.52, alpha: 1),
            stripeColor: KapselkiTheme.uiYellow,
            style: "Turbo refleks",
            bio: "Pojawia sie, kiedy ktos pokaze, ze szybka partyjka to nie przypadek, tylko czysty pstryk.",
            capDescription: "Neonowy rant, zolty pasek i portret, ktory wyglada jak wycinek z kolorowego plakatu.",
            powerMultiplier: 1.10,
            control: 0.84,
            spinMultiplier: 1.18,
            unlockRequirement: "Zdobądź srebro w Szybkiej Partyjce."
        ),
        KapselkiCharacter(
            id: "sprezyna",
            name: "Profesor Sprężyna",
            shortName: "Spręż",
            number: "13",
            portraitAssetName: "portrait_sprezyna",
            color: Color(red: 0.18, green: 0.63, blue: 0.48),
            uiColor: UIColor(red: 0.18, green: 0.63, blue: 0.48, alpha: 1),
            stripeColor: KapselkiTheme.uiOrange,
            style: "Sprytne odbicia",
            bio: "Zna kazdy kat, kazda linijke i kazda hopke. Do ekipy dolacza po finale osiedlowego touru.",
            capDescription: "Mietowy rant, pomaranczowy pasek i idealnie podklejony portret malego wynalazcy.",
            powerMultiplier: 0.99,
            control: 0.91,
            spinMultiplier: 1.25,
            unlockRequirement: "Ukończ Kuchenny Finał w Osiedlowym Tourze."
        )
    ]

    static let defaultCharacter = roster[0]
}

private extension Int {
    func clamped(to range: ClosedRange<Int>) -> Int {
        Swift.min(range.upperBound, Swift.max(range.lowerBound, self))
    }
}

extension View {
    func kapselkiPanel(cornerRadius: CGFloat = 8) -> some View {
        self
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(KapselkiTheme.ink.opacity(0.18), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 6)
    }
}
