import Foundation

enum ScraperError: LocalizedError {
    case invalidURL
    case notCookpadURL
    case networkFailed(Error)
    case noRecipeFound
    case decodingFailed(Error)
    case timeout

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL yang kamu masukkan tidak valid. Pastikan dimulai dengan https://"
        case .notCookpadURL:
            return "Saat ini hanya mendukung link dari Cookpad. Pastikan link berasal dari cookpad.com."
        case .networkFailed(let e):
            return "Gagal terhubung: \(e.localizedDescription)"
        case .noRecipeFound:
            return "Tidak ditemukan data resep di halaman ini. Situs mungkin tidak menggunakan format resep standar, atau link bukan halaman resep."
        case .decodingFailed(let e):
            return "Gagal membaca data resep: \(e.localizedDescription)"
        case .timeout:
            return "Halaman terlalu lama dimuat. Periksa koneksi internet dan coba lagi."
        }
    }
}
