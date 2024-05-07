PImage imgOriginal, gray, edges, groundTruth, processedImage, blackBackgroundImage;

void setup() {
  size(1520, 500);  // Largura suficiente para 4 imagens lado a lado.
  imgOriginal = loadImage("SegmentationImages/Image.jpg");  // Supondo que esta seja a localização da imagem original.
  groundTruth = loadImage("SegmentationImages/SegmentationObject.png");  // Carregar a imagem ground truth.
  gray = convertToGrayScale(imgOriginal); // Converte a imagem original para a escala de cinza.
  edges = createImage(gray.width, gray.height, RGB); // Cria uma nova imagem.

  // Aplicar um filtro gaussiano para suavizar a imagem
  gray.filter(BLUR, 2); // Aplica o filtro gaussiano para suavizar a imagem.
  filterSobel(gray, edges);  // Filtro de Sobel para detectar bordas.
  threshold(edges, 63); // Limiarização para simplificar a imagem .
  floodFill(edges, 190, 250, color(255), color(0)); // Realiza o preenchimento.
  removeNoise(edges);  // Remove pequenas áreas e ruídos.
  
  processedImage = edges;  // Esta é a imagem pós-processada
  blackBackgroundImage = maskBackgroundToBlack(imgOriginal);  // Aplicar a função para mudar o fundo para preto
  
  noLoop();
}

void draw() {
  background(255);
  image(imgOriginal, 0, 0); // Exibir imagem original
  image(groundTruth, 380, 0); // Exibir ground truth original
  image(processedImage, 760, 0); // Exibir imagem pós-processada
  image(blackBackgroundImage, 1140, 0); // Exibir imagem original com fundo preto
}

// Converte uma imagem colorida para a escala de cinza.
PImage convertToGrayScale(PImage source) {
  PImage result = createImage(source.width, source.height, RGB);
  source.loadPixels();
  result.loadPixels();
  for (int i = 0; i < source.pixels.length; i++) {
    float r = red(source.pixels[i]);
    float g = green(source.pixels[i]);
    float b = blue(source.pixels[i]);
    float grayValue = 0.219 * r + 0.267 * g + 0.514 * b;
    result.pixels[i] = color(grayValue);
  }
  result.updatePixels();
  return result;
}

// Detectar bordas na imagem.
void filterSobel(PImage source, PImage destination) {
  int[][] gx = {{-1, 0, 1}, {-2, 0, 2}, {-1, 0, 1}};
  int[][] gy = {{-1, -2, -1}, {0, 0, 0}, {1, 2, 1}};
  source.loadPixels();
  destination.loadPixels();

  for (int y = 1; y < source.height - 1; y++) {
    for (int x = 1; x < source.width - 1; x++) {
      float sumX = 0;
      float sumY = 0;

      for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
          int colora = source.pixels[(x + i) + (y + j) * source.width];
          sumX += brightness(colora) * gx[j + 1][i + 1];
          sumY += brightness(colora) * gy[j + 1][i + 1];
        }
      }

      float sum = sqrt(sq(sumX) + sq(sumY));
      destination.pixels[x + y * source.width] = color(sum);
    }
  }
  destination.updatePixels();
}

// Limiarização binária à imagem.
void threshold(PImage img, float thresh) {
  img.loadPixels();
  for (int i = 0; i < img.pixels.length; i++) {
    img.pixels[i] = brightness(img.pixels[i]) > thresh ? color(255) : color(0);
  }
  img.updatePixels();
}

// Preenche toda a área conectada a partir de um ponto na imagem.
void floodFill(PImage img, int x, int y, color newColor, color oldColor) {
  ArrayList<int[]> queue = new ArrayList<int[]>();
  queue.add(new int[]{x, y});

  while (!queue.isEmpty()) {
    int[] pos = queue.remove(0);
    int px = pos[0];
    int py = pos[1];

    if (px < 0 || py < 0 || px >= img.width || py >= img.height) continue;
    if (img.pixels[py * img.width + px] != oldColor) continue;

    img.pixels[py * img.width + px] = newColor;
    queue.add(new int[]{px + 1, py});
    queue.add(new int[]{px - 1, py});
    queue.add(new int[]{px, py + 1});
    queue.add(new int[]{px, py - 1});
  }
  img.updatePixels();
}
