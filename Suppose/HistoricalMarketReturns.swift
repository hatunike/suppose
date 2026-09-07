import Foundation

/// One calendar year's US market return and inflation figures.
struct HistoricalMarketYear: Identifiable, Equatable {
    let year: Int
    /// S&P 500 total return (including dividends), as a percentage.
    let nominalReturnPercent: Double
    /// US CPI-U annual average inflation rate, as a percentage.
    let inflationRatePercent: Double

    var id: Int { year }

    /// The inflation-adjusted return, via the Fisher equation:
    /// (1 + nominal) / (1 + inflation) - 1.
    var realReturnPercent: Double {
        ((1 + nominalReturnPercent / 100) / (1 + inflationRatePercent / 100) - 1) * 100
    }
}

// SOURCED DATA, retrieved 2026-09-07 — S&P 500 total annual return (with
// dividends) from Aswath Damodaran's historical returns dataset (NYU Stern:
// pages.stern.nyu.edu/~adamodar/New_Home_Page/datafile/histretSP.html), and US
// CPI-U annual average inflation rate from usinflationcalculator.com (sourced
// from the Bureau of Labor Statistics). Both are real published figures, not
// estimates — but re-verify against the primary sources if precision matters,
// and refresh this list yearly as new figures are published.
enum HistoricalMarketReturns {
    /// Ordered oldest to newest.
    static let years: [HistoricalMarketYear] = [
        HistoricalMarketYear(year: 1928, nominalReturnPercent: 43.81, inflationRatePercent: -1.7),
        HistoricalMarketYear(year: 1929, nominalReturnPercent: -8.30, inflationRatePercent: 0.0),
        HistoricalMarketYear(year: 1930, nominalReturnPercent: -25.12, inflationRatePercent: -2.3),
        HistoricalMarketYear(year: 1931, nominalReturnPercent: -43.84, inflationRatePercent: -9.0),
        HistoricalMarketYear(year: 1932, nominalReturnPercent: -8.64, inflationRatePercent: -9.9),
        HistoricalMarketYear(year: 1933, nominalReturnPercent: 49.98, inflationRatePercent: -5.1),
        HistoricalMarketYear(year: 1934, nominalReturnPercent: -1.19, inflationRatePercent: 3.1),
        HistoricalMarketYear(year: 1935, nominalReturnPercent: 46.74, inflationRatePercent: 2.2),
        HistoricalMarketYear(year: 1936, nominalReturnPercent: 31.94, inflationRatePercent: 1.5),
        HistoricalMarketYear(year: 1937, nominalReturnPercent: -35.34, inflationRatePercent: 3.6),
        HistoricalMarketYear(year: 1938, nominalReturnPercent: 29.28, inflationRatePercent: -2.1),
        HistoricalMarketYear(year: 1939, nominalReturnPercent: -1.10, inflationRatePercent: -1.4),
        HistoricalMarketYear(year: 1940, nominalReturnPercent: -10.67, inflationRatePercent: 0.7),
        HistoricalMarketYear(year: 1941, nominalReturnPercent: -12.77, inflationRatePercent: 5.0),
        HistoricalMarketYear(year: 1942, nominalReturnPercent: 19.17, inflationRatePercent: 10.9),
        HistoricalMarketYear(year: 1943, nominalReturnPercent: 25.06, inflationRatePercent: 6.1),
        HistoricalMarketYear(year: 1944, nominalReturnPercent: 19.03, inflationRatePercent: 1.7),
        HistoricalMarketYear(year: 1945, nominalReturnPercent: 35.82, inflationRatePercent: 2.3),
        HistoricalMarketYear(year: 1946, nominalReturnPercent: -8.43, inflationRatePercent: 8.3),
        HistoricalMarketYear(year: 1947, nominalReturnPercent: 5.20, inflationRatePercent: 14.4),
        HistoricalMarketYear(year: 1948, nominalReturnPercent: 5.70, inflationRatePercent: 8.1),
        HistoricalMarketYear(year: 1949, nominalReturnPercent: 18.30, inflationRatePercent: -1.2),
        HistoricalMarketYear(year: 1950, nominalReturnPercent: 30.81, inflationRatePercent: 1.3),
        HistoricalMarketYear(year: 1951, nominalReturnPercent: 23.68, inflationRatePercent: 7.9),
        HistoricalMarketYear(year: 1952, nominalReturnPercent: 18.15, inflationRatePercent: 1.9),
        HistoricalMarketYear(year: 1953, nominalReturnPercent: -1.21, inflationRatePercent: 0.8),
        HistoricalMarketYear(year: 1954, nominalReturnPercent: 52.56, inflationRatePercent: 0.7),
        HistoricalMarketYear(year: 1955, nominalReturnPercent: 32.60, inflationRatePercent: -0.4),
        HistoricalMarketYear(year: 1956, nominalReturnPercent: 7.44, inflationRatePercent: 1.5),
        HistoricalMarketYear(year: 1957, nominalReturnPercent: -10.46, inflationRatePercent: 3.3),
        HistoricalMarketYear(year: 1958, nominalReturnPercent: 43.72, inflationRatePercent: 2.8),
        HistoricalMarketYear(year: 1959, nominalReturnPercent: 12.06, inflationRatePercent: 0.7),
        HistoricalMarketYear(year: 1960, nominalReturnPercent: 0.34, inflationRatePercent: 1.7),
        HistoricalMarketYear(year: 1961, nominalReturnPercent: 26.64, inflationRatePercent: 1.0),
        HistoricalMarketYear(year: 1962, nominalReturnPercent: -8.81, inflationRatePercent: 1.0),
        HistoricalMarketYear(year: 1963, nominalReturnPercent: 22.61, inflationRatePercent: 1.3),
        HistoricalMarketYear(year: 1964, nominalReturnPercent: 16.42, inflationRatePercent: 1.3),
        HistoricalMarketYear(year: 1965, nominalReturnPercent: 12.40, inflationRatePercent: 1.6),
        HistoricalMarketYear(year: 1966, nominalReturnPercent: -9.97, inflationRatePercent: 2.9),
        HistoricalMarketYear(year: 1967, nominalReturnPercent: 23.80, inflationRatePercent: 3.1),
        HistoricalMarketYear(year: 1968, nominalReturnPercent: 10.81, inflationRatePercent: 4.2),
        HistoricalMarketYear(year: 1969, nominalReturnPercent: -8.24, inflationRatePercent: 5.5),
        HistoricalMarketYear(year: 1970, nominalReturnPercent: 3.56, inflationRatePercent: 5.7),
        HistoricalMarketYear(year: 1971, nominalReturnPercent: 14.22, inflationRatePercent: 4.4),
        HistoricalMarketYear(year: 1972, nominalReturnPercent: 18.76, inflationRatePercent: 3.2),
        HistoricalMarketYear(year: 1973, nominalReturnPercent: -14.31, inflationRatePercent: 6.2),
        HistoricalMarketYear(year: 1974, nominalReturnPercent: -25.90, inflationRatePercent: 11.0),
        HistoricalMarketYear(year: 1975, nominalReturnPercent: 37.00, inflationRatePercent: 9.1),
        HistoricalMarketYear(year: 1976, nominalReturnPercent: 23.83, inflationRatePercent: 5.8),
        HistoricalMarketYear(year: 1977, nominalReturnPercent: -6.98, inflationRatePercent: 6.5),
        HistoricalMarketYear(year: 1978, nominalReturnPercent: 6.51, inflationRatePercent: 7.6),
        HistoricalMarketYear(year: 1979, nominalReturnPercent: 18.52, inflationRatePercent: 11.3),
        HistoricalMarketYear(year: 1980, nominalReturnPercent: 31.74, inflationRatePercent: 13.5),
        HistoricalMarketYear(year: 1981, nominalReturnPercent: -4.70, inflationRatePercent: 10.3),
        HistoricalMarketYear(year: 1982, nominalReturnPercent: 20.42, inflationRatePercent: 6.2),
        HistoricalMarketYear(year: 1983, nominalReturnPercent: 22.34, inflationRatePercent: 3.2),
        HistoricalMarketYear(year: 1984, nominalReturnPercent: 6.15, inflationRatePercent: 4.3),
        HistoricalMarketYear(year: 1985, nominalReturnPercent: 31.24, inflationRatePercent: 3.6),
        HistoricalMarketYear(year: 1986, nominalReturnPercent: 18.49, inflationRatePercent: 1.9),
        HistoricalMarketYear(year: 1987, nominalReturnPercent: 5.81, inflationRatePercent: 3.6),
        HistoricalMarketYear(year: 1988, nominalReturnPercent: 16.54, inflationRatePercent: 4.1),
        HistoricalMarketYear(year: 1989, nominalReturnPercent: 31.48, inflationRatePercent: 4.8),
        HistoricalMarketYear(year: 1990, nominalReturnPercent: -3.06, inflationRatePercent: 5.4),
        HistoricalMarketYear(year: 1991, nominalReturnPercent: 30.23, inflationRatePercent: 4.2),
        HistoricalMarketYear(year: 1992, nominalReturnPercent: 7.49, inflationRatePercent: 3.0),
        HistoricalMarketYear(year: 1993, nominalReturnPercent: 9.97, inflationRatePercent: 3.0),
        HistoricalMarketYear(year: 1994, nominalReturnPercent: 1.33, inflationRatePercent: 2.6),
        HistoricalMarketYear(year: 1995, nominalReturnPercent: 37.20, inflationRatePercent: 2.8),
        HistoricalMarketYear(year: 1996, nominalReturnPercent: 22.68, inflationRatePercent: 3.0),
        HistoricalMarketYear(year: 1997, nominalReturnPercent: 33.10, inflationRatePercent: 2.3),
        HistoricalMarketYear(year: 1998, nominalReturnPercent: 28.34, inflationRatePercent: 1.6),
        HistoricalMarketYear(year: 1999, nominalReturnPercent: 20.89, inflationRatePercent: 2.2),
        HistoricalMarketYear(year: 2000, nominalReturnPercent: -9.03, inflationRatePercent: 3.4),
        HistoricalMarketYear(year: 2001, nominalReturnPercent: -11.85, inflationRatePercent: 2.8),
        HistoricalMarketYear(year: 2002, nominalReturnPercent: -21.97, inflationRatePercent: 1.6),
        HistoricalMarketYear(year: 2003, nominalReturnPercent: 28.36, inflationRatePercent: 2.3),
        HistoricalMarketYear(year: 2004, nominalReturnPercent: 10.74, inflationRatePercent: 2.7),
        HistoricalMarketYear(year: 2005, nominalReturnPercent: 4.83, inflationRatePercent: 3.4),
        HistoricalMarketYear(year: 2006, nominalReturnPercent: 15.61, inflationRatePercent: 3.2),
        HistoricalMarketYear(year: 2007, nominalReturnPercent: 5.48, inflationRatePercent: 2.8),
        HistoricalMarketYear(year: 2008, nominalReturnPercent: -36.55, inflationRatePercent: 3.8),
        HistoricalMarketYear(year: 2009, nominalReturnPercent: 25.94, inflationRatePercent: -0.4),
        HistoricalMarketYear(year: 2010, nominalReturnPercent: 14.82, inflationRatePercent: 1.6),
        HistoricalMarketYear(year: 2011, nominalReturnPercent: 2.10, inflationRatePercent: 3.2),
        HistoricalMarketYear(year: 2012, nominalReturnPercent: 15.89, inflationRatePercent: 2.1),
        HistoricalMarketYear(year: 2013, nominalReturnPercent: 32.15, inflationRatePercent: 1.5),
        HistoricalMarketYear(year: 2014, nominalReturnPercent: 13.52, inflationRatePercent: 1.6),
        HistoricalMarketYear(year: 2015, nominalReturnPercent: 1.38, inflationRatePercent: 0.1),
        HistoricalMarketYear(year: 2016, nominalReturnPercent: 11.77, inflationRatePercent: 1.3),
        HistoricalMarketYear(year: 2017, nominalReturnPercent: 21.61, inflationRatePercent: 2.1),
        HistoricalMarketYear(year: 2018, nominalReturnPercent: -4.23, inflationRatePercent: 2.4),
        HistoricalMarketYear(year: 2019, nominalReturnPercent: 31.21, inflationRatePercent: 1.8),
        HistoricalMarketYear(year: 2020, nominalReturnPercent: 18.02, inflationRatePercent: 1.2),
        HistoricalMarketYear(year: 2021, nominalReturnPercent: 28.47, inflationRatePercent: 4.7),
        HistoricalMarketYear(year: 2022, nominalReturnPercent: -18.04, inflationRatePercent: 8.0),
        HistoricalMarketYear(year: 2023, nominalReturnPercent: 26.06, inflationRatePercent: 4.1),
        HistoricalMarketYear(year: 2024, nominalReturnPercent: 24.88, inflationRatePercent: 2.9),
        HistoricalMarketYear(year: 2025, nominalReturnPercent: 17.78, inflationRatePercent: 2.6),
    ]
}
