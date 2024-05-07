// Declaração das variáveis de imagem
PImage imgOriginal, gray, edges, groundTruth, processedImage, blackBackgroundImage;

void setup() {
  size(1520, 300);  // Define o tamanho da janela de exibição
  imgOriginal = loadImage("Image.jpg");  // Carrega a imagem original
  groundTruth = loadImage("SegmentationObject.png");  // Carrega a imagem ground truth
  gray = convertToGrayScale(imgOriginal); // Converte a imagem original para escala de cinza
  edges = createImage(gray.width, gray.height, RGB); // Cria uma nova imagem para as bordas

  // Aplica um filtro gaussiano para suavizar a imagem em escala de cinza
  gray.filter(BLUR, 2); 
  // Aplica o filtro de Sobel para detectar bordas
  filterSobel(gray, edges);  
  // Limiarização para simplificar a imagem binária
  threshold(edges, 63); 
  // Realiza o preenchimento das áreas conectadas
  floodFill(edges, 190, 250, color(255), color(0)); 
  // Remove pequenas áreas e ruídos da imagem binária
  removeNoise(edges);  
  
  // Atribui a imagem processada à variável processedImage
  processedImage = edges;  
  // Aplica a função para mudar o fundo da imagem original para preto
  blackBackgroundImage = maskBackgroundToBlack(imgOriginal);  
  
  noLoop(); // Interrompe o loop draw
}

void draw() {
  background(255); // Define o fundo branco
  // Exibe as imagens: original, ground truth, imagem processada e imagem original com fundo preto
  image(imgOriginal, 0, 0); 
  image(groundTruth, 380, 0); 
  image(processedImage, 760, 0); 
  image(blackBackgroundImage, 1140, 0); 
}

// Função para mudar o fundo da imagem original para preto
PImage maskBackgroundToBlack(PImage source) {
  PImage result = source.copy();
  float threshold = 218;  // Define um limiar de similaridade para a cor do fundo

  source.loadPixels();
  result.loadPixels();
  // Loop sobre todos os pixels da imagem
  for (int i = 0; i < source.pixels.length; i++) {
    // Verifica se o brilho do pixel é maior que o limiar
    if (brightness(source.pixels[i]) > threshold) {
      result.pixels[i] = color(0);  // Altera para preto
    }
  }
  result.updatePixels();
  return result;
}

// Converte uma imagem colorida para escala de cinza
PImage convertToGrayScale(PImage source) {
  PImage result = createImage(source.width, source.height, RGB);
  source.loadPixels();
  result.loadPixels();
  // Loop sobre todos os pixels da imagem
  for (int i = 0; i < source.pixels.length; i++) {
    float r = red(source.pixels[i]);
    float g = green(source.pixels[i]);
    float b = blue(source.pixels[i]);
    // Calcula o valor de cinza ponderado para o pixel
    float grayValue = 0.219 * r + 0.267 * g + 0.514 * b;
    result.pixels[i] = color(grayValue);
  }
  result.updatePixels();
  return result;
}

// Aplica o filtro de Sobel para detecção de bordas na imagem em escala de cinza
void filterSobel(PImage source, PImage destination) {
  int[][] gx = {{-1, 0, 1}, {-2, 0, 2}, {-1, 0, 1}};
  int[][] gy = {{-1, -2, -1}, {0, 0, 0}, {1, 2, 1}};
  source.loadPixels();
  destination.loadPixels();

  // Loop sobre todos os pixels da imagem
  for (int y = 1; y < source.height - 1; y++) {
    for (int x = 1; x < source.width - 1; x++) {
      float sumX = 0;
      float sumY = 0;

      // Aplica a máscara de convolução em torno do pixel atual
      for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
          int colora = source.pixels[(x + i) + (y + j) * source.width];
          sumX += brightness(colora) * gx[j + 1][i + 1];
          sumY += brightness(colora) * gy[j + 1][i + 1];
        }
      }

      // Calcula o gradiente de intensidade e atribui à imagem de destino
      float sum = sqrt(sq(sumX) + sq(sumY));
      destination.pixels[x + y * source.width] = color(sum);
    }
  }
  destination.updatePixels();
}

// Aplica uma limiarização binária à imagem
void threshold(PImage img, float thresh) {
  img.loadPixels();
  // Loop sobre todos os pixels da imagem
  for (int i = 0; i < img.pixels.length; i++) {
    // Define o pixel como branco ou preto dependendo do valor de limiar
    img.pixels[i] = brightness(img.pixels[i]) > thresh ? color(255) : color(0);
  }
  img.updatePixels();
}

// Preenche toda a área conectada a partir de um ponto na imagem
void floodFill(PImage img, int x, int y, color newColor, color oldColor) {
  ArrayList<int[]> queue = new ArrayList<int[]>();
  queue.add(new int[]{x, y});

  while (!queue.isEmpty()) {
    int[] pos = queue.remove(0);
    int px = pos[0];
    int py = pos[1];

    // Verifica os limites da imagem e a cor do pixel
    if (px < 0 || py < 0 || px >= img.width || py >= img.height) continue;
    if (img.pixels[py * img.width + px] != oldColor) continue;

    // Preenche o pixel e adiciona vizinhos à fila
    img.pixels[py * img.width + px] = newColor;
    queue.add(new int[]{px + 1, py});
    queue.add(new int[]{px - 1, py});
    queue.add(new int[]{px, py + 1});
    queue.add(new int[]{px, py - 1});
  }
  img.updatePixels();
}

// Remove pequenos objetos ou ruídos da imagem binária
void removeNoise(PImage img) {
  img.loadPixels();
  int w = img.width;
  int h = img.height;
  int[] labels = new int[w * h];
  int label = 1;

  HashMap<Integer, Integer> labelSizes = new HashMap<Integer, Integer>();

  // Inicializa os rótulos
  for (int i = 0; i < labels.length; i++) {
    labels[i] = 0;
  }

  // Primeira passagem: rotula os componentes
  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      int index = x + y * w;
      if (brightness(img.pixels[index]) < 128) {  
        int labelLeft = x > 0 ? labels[index - 1] : 0;
        int labelAbove = y > 0 ? labels[index - w] : 0;

        // Verifica vizinhos e atribui rótulos
        if (labelLeft > 0 || labelAbove > 0) {
          if (labelLeft > 0 && labelAbove > 0) {
            labels[index] = min(labelLeft, labelAbove);
            // Une componentes se necessário
            int larger = max(labelLeft, labelAbove);
            if (larger != labels[index]) {
              for (int i = 0; i <= index; i++) {
                if (labels[i] == larger) labels[i] = labels[index];
              }
            }
          } else {
            labels[index] = max(labelLeft, labelAbove);
          }
        } else {
          labels[index] = label++;
        }
      }
    }
  }

  // Conta os tamanhos dos componentes
  for (int i = 0; i < labels.length; i++) {
    int l = labels[i];
    if (l > 0) {
      if (!labelSizes.containsKey(l)) {
        labelSizes.put(l, 1);
      } else {
        labelSizes.put(l, labelSizes.get(l) + 1);
      }
    }
  }

  // Segunda passagem: remove pequenas áreas
  for (int i = 0; i < labels.length; i++) {
    if (labels[i] > 0 && labelSizes.get(labels[i]) < 100) {  
      img.pixels[i] = color(255);  
    }
  }

  img.updatePixels();
}
