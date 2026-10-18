/// Ilustração (2D, na paleta da marca) que representa cada categoria de exame.
/// Para usar fotos reais, basta trocar os arquivos em `assets/exams/` mantendo os nomes.
String examArtAsset(String category) {
  switch (category) {
    case 'Sangue':
      return 'assets/exams/sangue.png';
    case 'Raio-X':
      return 'assets/exams/raio-x.png';
    case 'Consultas':
      return 'assets/exams/consultas.png';
    case 'Cardio':
      return 'assets/exams/cardio.png';
    case 'Ultrassom':
      return 'assets/exams/ultrassom.png';
    default:
      return 'assets/exams/padrao.png';
  }
}
