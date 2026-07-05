import SwiftUI
import UIKit

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
        )
    ]

    static let defaultCharacter = roster[0]
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
