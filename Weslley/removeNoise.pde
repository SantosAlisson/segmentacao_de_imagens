// Remover pequenos objetos ou ruídos da imagem.
void removeNoise(PImage img) {
  img.loadPixels();
  int w = img.width;
  int h = img.height;
  int[] labels = new int[w * h];
  int label = 1;

  HashMap<Integer, Integer> labelSizes = new HashMap<Integer, Integer>();

  // Inicializar labels
  for (int i = 0; i < labels.length; i++) {
    labels[i] = 0;
  }

  // Primeira passagem: rotular componentes
  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      int index = x + y * w;
      if (brightness(img.pixels[index]) < 128) {  // assume que preto é a cor das áreas a serem possivelmente removidas
        // Checar vizinhos (apenas acima e à esquerda para um componente 4-conectado)
        int labelLeft = x > 0 ? labels[index - 1] : 0;
        int labelAbove = y > 0 ? labels[index - w] : 0;

        if (labelLeft > 0 || labelAbove > 0) {
          if (labelLeft > 0 && labelAbove > 0) {
            labels[index] = min(labelLeft, labelAbove);
            // Unir componentes se necessário
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

  // Contar tamanhos dos componentes
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

  // Segunda passagem: remover pequenas áreas
  for (int i = 0; i < labels.length; i++) {
    if (labels[i] > 0 && labelSizes.get(labels[i]) < 100) {  // ajuste este limiar conforme necessário
      img.pixels[i] = color(255);  // Mudar para branco
    }
  }

  img.updatePixels();
}
