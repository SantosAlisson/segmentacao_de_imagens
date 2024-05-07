PImage maskBackgroundToBlack(PImage source) {
  PImage result = source.copy();
  float threshold = 218;  // Definir um limiar de similaridade para a cor do fundo

  source.loadPixels();
  result.loadPixels();
  for (int i = 0; i < source.pixels.length; i++) {
    if (brightness(source.pixels[i]) > threshold) {
      result.pixels[i] = color(0);  // Mudar para preto
    }
  }
  result.updatePixels();
  return result;
}
