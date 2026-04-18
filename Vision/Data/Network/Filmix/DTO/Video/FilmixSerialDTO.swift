struct FilmixSerialDTO: Codable {
    let title: String
    let folder: [FilmixFolderDTO]
}
