//
//  CountryFlag.swift
//  liga1
//

import Foundation

/// Bandera y nombre de país a partir del código de nacionalidad guardado en
/// `equipos/{code}/players` (FIFA o ISO de 3 letras, ej. "PER", "CHI", "URU").
enum CountryFlag {

    /// Código de 3 letras (FIFA o ISO 3166-1 alpha-3) → ISO alpha-2.
    /// Se incluyen ambas variantes cuando difieren (CHI/CHL, URU/URY, PAR/PRY...).
    private static let alpha2ByCode: [String: String] = [
        // Sudamérica
        "PER": "PE", "ARG": "AR", "BRA": "BR", "BOL": "BO", "COL": "CO", "ECU": "EC", "VEN": "VE",
        "CHI": "CL", "CHL": "CL", "URU": "UY", "URY": "UY", "PAR": "PY", "PRY": "PY",
        // Norte, Centroamérica y Caribe
        "USA": "US", "MEX": "MX", "CAN": "CA", "PAN": "PA", "CRC": "CR", "CRI": "CR",
        "HON": "HN", "HND": "HN", "GUA": "GT", "GTM": "GT", "SLV": "SV", "NCA": "NI", "NIC": "NI",
        "CUB": "CU", "DOM": "DO", "HAI": "HT", "HTI": "HT", "JAM": "JM",
        // Europa
        "ESP": "ES", "POR": "PT", "PRT": "PT", "ITA": "IT", "FRA": "FR", "GER": "DE", "DEU": "DE",
        "ENG": "GB", "GBR": "GB", "NED": "NL", "NLD": "NL", "BEL": "BE", "SUI": "CH", "CHE": "CH",
        "CRO": "HR", "HRV": "HR", "SRB": "RS", "GRE": "GR", "GRC": "GR",
        // Asia, África, Oceanía
        "KOR": "KR", "JPN": "JP", "CHN": "CN", "PSE": "PS", "PLE": "PS", "AUS": "AU",
        "NGA": "NG", "GHA": "GH", "CMR": "CM", "SEN": "SN", "CIV": "CI", "MAR": "MA"
    ]

    /// ISO alpha-2 o `nil` si el código no se reconoce.
    static func alpha2(for code: String?) -> String? {
        guard let code = code?.trimmingCharacters(in: .whitespaces).uppercased(), !code.isEmpty else {
            return nil
        }
        if code.count == 2 { return code }
        return alpha2ByCode[code]
    }

    /// Emoji de bandera (indicadores regionales), ej. "PER" → "🇵🇪".
    static func emoji(for code: String?) -> String? {
        guard let alpha2 = alpha2(for: code) else { return nil }
        let scalars = alpha2.unicodeScalars.compactMap { UnicodeScalar(127_397 + $0.value) }
        guard scalars.count == 2 else { return nil }
        return String(String.UnicodeScalarView(scalars))
    }

    /// Nombre del país en español, ej. "PER" → "Perú".
    static func name(for code: String?, locale: Locale = Locale(identifier: "es_PE")) -> String? {
        guard let alpha2 = alpha2(for: code) else { return nil }
        return locale.localizedString(forRegionCode: alpha2)
    }
}
